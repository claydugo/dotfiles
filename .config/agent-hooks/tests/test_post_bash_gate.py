import hashlib
import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

HOOK = str(Path(__file__).parents[1] / "no_slop_post_bash.py")
SLOP = 'def compute(value):\n    """Delve into the tapestry of values."""\n    return value\n'
CLEAN = "def compute(value):\n    return value\n"
made = []
state_home = tempfile.mkdtemp()


def repo():
    root = tempfile.mkdtemp()
    made.append(root)
    for arguments in (
        ["init", "-q", "."],
        ["config", "user.email", "t@t.t"],
        ["config", "user.name", "t"],
    ):
        subprocess.run(["git"] + arguments, cwd=root, capture_output=True)
    write(root, "seed.py", "x = 1\n")
    write(
        root,
        "prior.py",
        'def prior(x):\n    """Pre-existing tapestry of slop."""\n    return x\n',
    )
    subprocess.run(["git", "add", "seed.py"], cwd=root, capture_output=True)
    subprocess.run(["git", "commit", "-qm", "base"], cwd=root, capture_output=True)
    return root


def write(root, name, content):
    with open(os.path.join(root, name), "w") as handle:
        handle.write(content)


def fire(
    cwd,
    session,
    event="PostToolUse",
    tool="Bash",
    tool_use_id="tool-1",
    stop_hook_active=False,
):
    payload = {"cwd": cwd, "session_id": session, "hook_event_name": event}
    if event in ("PreToolUse", "PostToolUse", "PostToolUseFailure"):
        payload["tool_name"] = tool
        payload["tool_use_id"] = tool_use_id
    if event == "Stop":
        payload["stop_hook_active"] = stop_hook_active
    environment = os.environ.copy()
    environment["XDG_STATE_HOME"] = state_home
    process = subprocess.run(
        [sys.executable, HOOK],
        input=json.dumps(payload),
        capture_output=True,
        text=True,
        env=environment,
    )
    return process.returncode, process.stderr


results = []
try:
    work = repo()
    session = "s1"

    code, _ = fire(work, session, "SessionStart")
    results.append((code == 0, "SessionStart baselines quietly", code))
    active_session_path = os.path.join(
        state_home,
        "agent-hooks",
        "runtime",
        hashlib.sha256(session.encode()).hexdigest(),
    )
    mode = os.stat(active_session_path).st_mode & 0o777
    results.append(
        (mode == 0o700, "runtime state is private", 0 if mode == 0o700 else mode)
    )

    code, _ = fire(work, session)
    results.append((code == 0, "clean Bash call, pre-existing slop silent", code))

    fire(work, session, "PreToolUse", tool="apply_patch")
    write(work, "new.py", SLOP)
    code, error = fire(work, session, tool="apply_patch")
    results.append((code == 2, "apply_patch slop is reported", code))
    results.append(("new.py" in error, "  names the offending file", code))
    results.append(
        ("docstring" in error and "Slop." in error, "  both checkers ran", code)
    )
    results.append(
        ("prior.py" not in error, "  baselined dirty file stays silent", code)
    )

    code, error = fire(work, session)
    results.append((code == 2, "re-reports until fixed", code))

    fire(work, session, "PreToolUse")
    write(work, "new.py", CLEAN)
    code, _ = fire(work, session)
    results.append((code == 0, "fixing it clears the gate", code))

    fire(work, session, "PreToolUse")
    write(
        work,
        "seed.py",
        'x = 1\ndef helper():\n    """new docstring"""\n    return 1\n',
    )
    code, error = fire(work, session)
    results.append(
        (code == 2 and "seed.py" in error, "tracked file, added lines only", code)
    )

    code, _ = fire(work, session, "Stop")
    results.append((code == 2, "Stop catches remaining slop", code))
    code, _ = fire(work, session, "Stop", stop_hook_active=True)
    results.append((code == 0, "Stop retry guard prevents a loop", code))

    concurrent = repo()
    concurrent_session = "s2"
    fire(concurrent, concurrent_session, "SessionStart")
    write(concurrent, "human.py", SLOP)
    fire(concurrent, concurrent_session, "PreToolUse", tool_use_id="agent-a")
    write(concurrent, "agent-a.py", SLOP)
    fire(concurrent, concurrent_session, "PreToolUse", tool_use_id="agent-b")
    code, error = fire(concurrent, concurrent_session, tool_use_id="agent-a")
    results.append(
        (code == 2 and "agent-a.py" in error, "first parallel edit is checked", code)
    )
    write(concurrent, "agent-b.py", SLOP)
    code, error = fire(concurrent, concurrent_session, tool_use_id="agent-b")
    results.append(
        (code == 2 and "agent-b.py" in error, "second parallel edit is checked", code)
    )
    results.append(
        ("human.py" not in error, "between-tool human edit is ignored", code)
    )

    failed = repo()
    failed_session = "s3"
    fire(failed, failed_session, "SessionStart")
    fire(failed, failed_session, "PreToolUse", tool_use_id="failed")
    write(failed, "partial.py", SLOP)
    code, error = fire(
        failed,
        failed_session,
        "PostToolUseFailure",
        tool_use_id="failed",
    )
    results.append(
        (code == 2 and "partial.py" in error, "failed tool writes are checked", code)
    )

    duplicate = repo()
    duplicate_session = "s4"
    write(duplicate, "duplicate.md", "same — text\n")
    fire(duplicate, duplicate_session, "SessionStart")
    fire(duplicate, duplicate_session, "PreToolUse")
    write(duplicate, "duplicate.md", "same — text\nsame — text\n")
    code, error = fire(duplicate, duplicate_session)
    results.append(
        (
            code == 2 and "duplicate.md:2" in error,
            "duplicate finding beats baseline count",
            code,
        )
    )

    many = repo()
    many_session = "s5"
    fire(many, many_session, "SessionStart")
    fire(many, many_session, "PreToolUse")
    for index in range(30):
        write(many, f"f{index:02}.py", SLOP if index == 29 else "x = 1\n")
    code, error = fire(many, many_session)
    results.append(
        (code == 2 and "f29.py" in error, "all changed files are scanned", code)
    )

    cleanup_session = "s6"
    fire(work, cleanup_session, "SessionStart")
    code, _ = fire(work, cleanup_session, "SessionEnd")
    session_path = os.path.join(
        state_home,
        "agent-hooks",
        "runtime",
        hashlib.sha256(cleanup_session.encode()).hexdigest(),
    )
    results.append(
        (
            code == 0 and not os.path.exists(session_path),
            "SessionEnd removes runtime state",
            code,
        )
    )

    loose = tempfile.mkdtemp()
    made.append(loose)
    results.append((fire(loose, session)[0] == 0, "non-git directory skipped", 0))
    process = subprocess.run(
        [sys.executable, HOOK], input="garbage", capture_output=True, text=True
    )
    results.append(
        (process.returncode == 0, "malformed payload skipped", process.returncode)
    )
    payload = json.dumps(
        {"cwd": work, "tool_name": "Read", "hook_event_name": "PostToolUse"}
    )
    process = subprocess.run(
        [sys.executable, HOOK], input=payload, capture_output=True, text=True
    )
    results.append(
        (process.returncode == 0, "non-writing tool skipped", process.returncode)
    )
finally:
    for directory in made:
        shutil.rmtree(directory, ignore_errors=True)
    shutil.rmtree(state_home, ignore_errors=True)

for ok, label, code in results:
    print(f"{'PASS' if ok else 'FAIL'} {label:38} exit={code}")
print(f"\n{sum(1 for ok, _, _ in results if ok)}/{len(results)} passed")
raise SystemExit(any(not ok for ok, _, _ in results))
