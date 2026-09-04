#!/usr/bin/env python3
import hashlib
import json
import os
import shutil
import subprocess
import sys
import tempfile
from collections import Counter

sys.dont_write_bytecode = True
import no_slop_check  # noqa: E402


def git(arguments, cwd):
    return subprocess.run(
        ["git"] + arguments, cwd=cwd, capture_output=True, text=True, timeout=2
    )


def candidates(root):
    names = set()
    for arguments in (
        ["diff", "--name-only", "-z", "HEAD", "--", "*.py", "*.md"],
        ["ls-files", "--others", "--exclude-standard", "-z", "--", "*.py", "*.md"],
    ):
        result = git(arguments, root)
        if result.returncode == 0:
            names.update(name for name in result.stdout.split("\0") if name)
    if not git(["rev-parse", "--verify", "HEAD"], root).returncode:
        return sorted(names)
    result = git(
        [
            "ls-files",
            "--cached",
            "--others",
            "--exclude-standard",
            "-z",
            "--",
            "*.py",
            "*.md",
        ],
        root,
    )
    if result.returncode == 0:
        names.update(name for name in result.stdout.split("\0") if name)
    return sorted(names)


def file_digest(path):
    digest = hashlib.sha256()
    with open(path, "rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def snapshot(root):
    files = {}
    for name in candidates(root):
        try:
            files[name] = file_digest(os.path.join(root, name))
        except OSError:
            continue
    return files


def scan(root, names=None):
    no_slop_check.DEGRADED.clear()
    checker = no_slop_check
    if names is None:
        names = candidates(root)

    findings = {}
    by_abspath = {}
    for name in sorted(set(names)):
        path = os.path.join(root, name)
        try:
            with open(path, encoding="utf-8", errors="replace") as handle:
                current = handle.read()
        except OSError:
            continue
        base = git(["show", f"HEAD:{name}"], root)
        lines = current.splitlines()
        added = checker.added_line_numbers(
            base.stdout.splitlines() if base.returncode == 0 else [], lines
        )
        if not added:
            continue
        by_abspath[os.path.abspath(path)] = (name, added)
        if name.endswith(".py"):
            findings[name] = checker.python_findings(current, lines, added)
        else:
            findings[name] = checker.markdown_findings(lines, added)

    for reported, alerts in checker.vale_report(list(by_abspath)).items():
        entry = by_abspath.get(reported)
        if entry is None:
            continue
        name, added = entry
        findings[name] += [(line, text) for line, text in alerts if line in added]
    return findings, bool(checker.DEGRADED)


def finding_key(root, name, line, message):
    try:
        with open(
            os.path.join(root, name), encoding="utf-8", errors="replace"
        ) as handle:
            text = next(
                (
                    value.rstrip("\n")
                    for number, value in enumerate(handle, 1)
                    if number == line
                ),
                "",
            )
    except OSError:
        text = ""
    return json.dumps([name, message, text], separators=(",", ":"))


def finding_counts(root, findings):
    return Counter(
        finding_key(root, name, line, message)
        for name, entries in findings.items()
        for line, message in set(entries)
    )


def digest_text(value):
    return hashlib.sha256(value.encode()).hexdigest()


def session_directory(payload):
    state_home = os.environ.get("XDG_STATE_HOME") or os.path.expanduser(
        "~/.local/state"
    )
    session = str(payload.get("session_id") or payload.get("transcript_path") or "none")
    return os.path.join(state_home, "agent-hooks", "runtime", digest_text(session))


def atomic_write(path, value):
    directory = os.path.dirname(path)
    os.makedirs(directory, mode=0o700, exist_ok=True)
    descriptor, temporary = tempfile.mkstemp(dir=directory)
    try:
        os.fchmod(descriptor, 0o600)
        with os.fdopen(descriptor, "w", encoding="utf-8") as handle:
            handle.write(value)
        os.replace(temporary, path)
    finally:
        try:
            os.unlink(temporary)
        except OSError:
            pass


def write_json(path, value):
    atomic_write(path, json.dumps(value, sort_keys=True))


def read_json(path, default):
    try:
        with open(path, encoding="utf-8") as handle:
            value = json.load(handle)
    except (OSError, ValueError):
        return default
    return value


def scope_directory(session, root):
    return os.path.join(session, "scopes", digest_text(os.path.realpath(root)))


def initialize_scope(session, root, baseline_current):
    os.makedirs(session, mode=0o700, exist_ok=True)
    os.chmod(session, 0o700)
    scopes = os.path.join(session, "scopes")
    os.makedirs(scopes, mode=0o700, exist_ok=True)
    os.chmod(scopes, 0o700)
    scope = scope_directory(session, root)
    if os.path.isdir(scope):
        return scope, False
    initializing = tempfile.mkdtemp(prefix=".scope-", dir=scopes)
    os.chmod(initializing, 0o700)
    os.makedirs(os.path.join(initializing, "before"), mode=0o700)
    os.makedirs(os.path.join(initializing, "touched"), mode=0o700)
    findings, degraded = scan(root) if baseline_current else ({}, False)
    atomic_write(os.path.join(initializing, "root"), root)
    write_json(
        os.path.join(initializing, "baseline.json"),
        dict(finding_counts(root, findings)),
    )
    try:
        os.rename(initializing, scope)
        return scope, degraded
    except OSError:
        if not os.path.isdir(scope):
            raise
        shutil.rmtree(initializing, ignore_errors=True)
        return scope, False


def tool_key(payload):
    identity = str(
        payload.get("tool_use_id")
        or payload.get("tool_call_id")
        or payload.get("agent_id")
        or "unknown"
    )
    return digest_text(identity)


def mark_touched(scope, names):
    directory = os.path.join(scope, "touched")
    for name in names:
        atomic_write(os.path.join(directory, digest_text(name)), name)


def touched_names(scope):
    directory = os.path.join(scope, "touched")
    try:
        paths = [os.path.join(directory, name) for name in os.listdir(directory)]
    except OSError:
        return []
    names = []
    for path in paths:
        try:
            with open(path, encoding="utf-8") as handle:
                names.append(handle.read())
        except OSError:
            continue
    return names


def scope_roots(session):
    directory = os.path.join(session, "scopes")
    try:
        scopes = [os.path.join(directory, name) for name in os.listdir(directory)]
    except OSError:
        return []
    roots = []
    for scope in scopes:
        try:
            with open(os.path.join(scope, "root"), encoding="utf-8") as handle:
                roots.append((scope, handle.read()))
        except OSError:
            continue
    return roots


def report_findings(session):
    report = []
    degraded = False
    for scope, root in scope_roots(session):
        findings, scan_degraded = scan(root, touched_names(scope))
        degraded = degraded or scan_degraded
        baseline = Counter(read_json(os.path.join(scope, "baseline.json"), {}))
        for name, entries in findings.items():
            for line, message in sorted(set(entries)):
                key = finding_key(root, name, line, message)
                if baseline[key]:
                    baseline[key] -= 1
                else:
                    report.append(f"  {name}:{line}  {message}")
    if not report:
        return 1 if degraded else 0
    sys.stderr.write(
        "BLOCKED by the no-slop gate. These findings appeared in files changed "
        "during this agent session. These are hard rules from CLAUDE.md. They outrank your own "
        "judgement about this code, and they are not open to discussion.\n"
        + "\n".join(report)
        + "\nFix every line above before you do anything else. Do not defend the "
        "finding to the user and do not ask for an exception.\n"
    )
    return 2


def repository_root(cwd):
    top = git(["rev-parse", "--show-toplevel"], cwd)
    return top.stdout.strip() if top.returncode == 0 else None


def main():
    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return 0
    event = payload.get("hook_event_name", "")
    if event == "Stop" and payload.get("stop_hook_active"):
        return 0
    session = session_directory(payload)
    if event == "SessionEnd":
        shutil.rmtree(session, ignore_errors=True)
        return 0
    if event == "SessionStart":
        if payload.get("source") == "compact":
            return 0
        shutil.rmtree(session, ignore_errors=True)
        root = repository_root(payload.get("cwd") or os.getcwd())
        if root is None:
            return 0
        _, degraded = initialize_scope(session, root, True)
        return 1 if degraded else 0
    if event == "Stop":
        return report_findings(session)
    if payload.get("tool_name") not in (
        "Bash",
        "PowerShell",
        "apply_patch",
        "Write",
        "Edit",
    ):
        return 0
    root = repository_root(payload.get("cwd") or os.getcwd())
    if root is None:
        return 0
    scope, degraded = initialize_scope(session, root, event == "PreToolUse")
    before_path = os.path.join(scope, "before", tool_key(payload) + ".json")
    if event == "PreToolUse":
        write_json(before_path, snapshot(root))
        return 1 if degraded else 0
    if event not in ("PostToolUse", "PostToolUseFailure"):
        return 0
    before = read_json(before_path, None)
    current = snapshot(root)
    changed = (
        set(current)
        if before is None
        else {
            name
            for name in set(before) | set(current)
            if before.get(name) != current.get(name)
        }
    )
    mark_touched(scope, changed)
    try:
        os.unlink(before_path)
    except OSError:
        pass
    return report_findings(session)


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as error:
        sys.stderr.write(
            f"no-slop changed-file hook degraded: {type(error).__name__}: {error}\n"
        )
        sys.exit(1)
