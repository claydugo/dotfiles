#!/usr/bin/env python3
import json
import os
import re
import sys

DIRECTIVE = (
    "noqa",
    "type:",
    "pragma",
    "ruff:",
    "fmt:",
    "mypy:",
    "pyright:",
    "isort:",
    "!",
)
ALLOWLIST_ASSIGN = re.compile(r"\b_?VALID_[A-Z0-9_]+\s*[:=]")
GLOSSARY_BULLET = re.compile(r"^\s*[-*+]\s+\*\*[^*]+\*\*\s*[—–]")
DEGRADED = []


def report_degraded(detail):
    import time

    DEGRADED.append(detail)
    stamp = time.strftime("%Y-%m-%d %H:%M:%S")
    state_home = os.environ.get("XDG_STATE_HOME") or os.path.expanduser(
        "~/.local/state"
    )
    directory = os.path.join(state_home, "agent-hooks")
    try:
        os.makedirs(directory, mode=0o700, exist_ok=True)
        os.chmod(directory, 0o700)
        path = os.path.join(directory, "no-slop.log")
        with open(path, "a", encoding="utf-8") as handle:
            handle.write(f"{stamp}  {detail}\n")
        os.chmod(path, 0o600)
    except OSError:
        pass
    sys.stderr.write(f"no-slop hook degraded, checks were skipped: {detail}\n")


def added_line_numbers(old_lines, new_lines):
    import difflib

    added = set()
    matcher = difflib.SequenceMatcher(None, old_lines, new_lines)
    for tag, _i1, _i2, j1, j2 in matcher.get_opcodes():
        if tag in ("insert", "replace"):
            added.update(range(j1 + 1, j2 + 1))
    return added


def reference_counts(tree):
    import ast

    names = {}
    attributes = {}
    strings = set()
    called = {}
    curried = {}
    lambda_calls = set()
    for node in ast.walk(tree):
        if not isinstance(node, ast.Lambda):
            continue
        for child in ast.walk(node):
            if isinstance(child, ast.Call):
                lambda_calls.add(id(child))
    for node in ast.walk(tree):
        if isinstance(node, ast.Name) and isinstance(node.ctx, ast.Load):
            names[node.id] = names.get(node.id, 0) + 1
        elif isinstance(node, ast.Attribute):
            attributes[node.attr] = attributes.get(node.attr, 0) + 1
        elif isinstance(node, ast.Constant) and isinstance(node.value, str):
            strings.add(node.value)
        if isinstance(node, ast.Call):
            if isinstance(node.func, ast.Name):
                target = node.func.id
            elif isinstance(node.func, ast.Attribute):
                target = node.func.attr
            else:
                continue
            called[target] = called.get(target, 0) + 1
            if id(node) in lambda_calls:
                curried[target] = curried.get(target, 0) + 1
    return names, attributes, strings, called, curried


def is_literal(node):
    import ast

    try:
        ast.literal_eval(node)
    except (ValueError, TypeError, SyntaxError, MemoryError, RecursionError):
        return False
    return True


def calls_super(node):
    import ast

    for child in ast.walk(node):
        if not isinstance(child, ast.Call):
            continue
        func = child.func
        if not isinstance(func, ast.Attribute) or func.attr != node.name:
            continue
        inner = func.value
        if (
            isinstance(inner, ast.Call)
            and isinstance(inner.func, ast.Name)
            and inner.func.id == "super"
        ):
            return True
    return False


def is_shapeless(node):
    import ast

    body = [
        stmt
        for stmt in node.body
        if not (isinstance(stmt, ast.Expr) and isinstance(stmt.value, ast.Constant))
    ]
    if len(body) > 3:
        return False
    structure = (
        ast.If,
        ast.For,
        ast.AsyncFor,
        ast.While,
        ast.Try,
        ast.With,
        ast.AsyncWith,
    )
    if hasattr(ast, "Match"):
        structure += (ast.Match,)
    return not any(
        isinstance(child, structure) for stmt in body for child in ast.walk(stmt)
    )


def inline_findings(tree, added, in_tests):
    import ast

    findings = []
    names, attributes, strings, called, curried = reference_counts(tree)
    functions = []
    for node in tree.body:
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            functions.append((node, names))
        elif isinstance(node, ast.ClassDef):
            for child in node.body:
                if isinstance(child, (ast.FunctionDef, ast.AsyncFunctionDef)):
                    functions.append((child, attributes))

    for node, counts in functions:
        name = node.name
        if name.endswith("_") or name.startswith("test"):
            continue
        if not in_tests and not name.startswith("_"):
            continue
        if node.decorator_list or name in strings or node.lineno not in added:
            continue
        sites = counts.get(name, 0)
        if sites and name not in called:
            continue
        if called.get(name) and curried.get(name) == called.get(name):
            continue
        if calls_super(node):
            continue
        if not is_shapeless(node):
            continue
        if sites < 3:
            findings.append(
                (
                    node.lineno,
                    f"helper {name}() has {sites} call site(s); paste its body at each "
                    "call site and delete the definition",
                )
            )

    for node in tree.body:
        if isinstance(node, ast.Assign):
            if len(node.targets) != 1 or not isinstance(node.targets[0], ast.Name):
                continue
            target, value = node.targets[0], node.value
        elif isinstance(node, ast.AnnAssign):
            if not isinstance(node.target, ast.Name):
                continue
            target, value = node.target, node.value
        else:
            continue
        name = target.id
        if value is None or not name.startswith("_") or name.endswith("_"):
            continue
        if name in strings or node.lineno not in added or not is_literal(value):
            continue
        uses = names.get(name, 0)
        if uses < 3:
            findings.append(
                (
                    node.lineno,
                    f"constant {name} has {uses} use(s); write the literal at each site "
                    "and delete the assignment",
                )
            )
    return findings


def test_shape(node):
    import ast

    pieces = []
    for child in ast.walk(node):
        if isinstance(child, ast.Constant):
            pieces.append("Constant")
        elif isinstance(child, ast.Call):
            func = child.func
            if isinstance(func, ast.Name):
                pieces.append(f"Call:{func.id}")
            elif isinstance(func, ast.Attribute):
                pieces.append(f"Call:{func.attr}")
            else:
                pieces.append("Call")
        elif isinstance(child, ast.Attribute):
            pieces.append(f"Attr:{child.attr}")
        elif isinstance(child, ast.arg):
            pieces.append(f"arg:{child.arg}")
        elif isinstance(child, ast.Name):
            pieces.append("Name")
        else:
            pieces.append(type(child).__name__)
    return tuple(pieces)


def call_identity(shape):
    return frozenset(
        piece for piece in shape if piece.startswith(("Call:", "arg:", "Attr:"))
    )


def duplicate_test_findings(tree, added):
    import ast
    import difflib

    tests = []
    scopes = [tree]
    for node in tree.body:
        if isinstance(node, ast.ClassDef) and node.name.startswith("Test"):
            scopes.append(node)
    for scope in scopes:
        for node in scope.body:
            if not isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
                continue
            if not node.name.startswith("test"):
                continue
            if any("parametrize" in ast.dump(d) for d in node.decorator_list):
                continue
            tests.append(node)

    findings = []
    groups = []
    for node in tests:
        shape = test_shape(node)
        identity = call_identity(shape)
        for other_identity, other_shape, members in groups:
            if not identity or not other_identity:
                continue
            if not (identity <= other_identity or other_identity <= identity):
                continue
            shorter, longer = sorted((shape, other_shape), key=len)
            matched = sum(
                block.size
                for block in difflib.SequenceMatcher(
                    None, shorter, longer, autojunk=False
                ).get_matching_blocks()
            )
            if matched / len(shorter) >= 0.85:
                members.append(node)
                break
        else:
            groups.append((identity, shape, [node]))

    for _identity, _shape, members in groups:
        if len(members) < 2 or not any(node.lineno in added for node in members):
            continue
        names = ", ".join(node.name for node in members[:4])
        findings.append(
            (
                min(node.lineno for node in members),
                f"{len(members)} tests share one shape ({names}); "
                "merge into one @pytest.mark.parametrize",
            )
        )
    return findings


def python_findings(source, new_lines, added, path_text):
    import ast
    import io
    import tokenize

    findings = []
    try:
        tree = ast.parse(source)
    except SyntaxError:
        tree = None
    if tree is not None:
        scopes = (ast.Module, ast.ClassDef, ast.FunctionDef, ast.AsyncFunctionDef)
        for node in ast.walk(tree):
            if not isinstance(node, scopes) or not node.body:
                continue
            first = node.body[0]
            if not isinstance(first, ast.Expr) or not isinstance(
                first.value, ast.Constant
            ):
                continue
            if not isinstance(first.value.value, str):
                continue
            if first.lineno in added:
                findings.append(
                    (
                        first.lineno,
                        "docstring in new code; delete it (CLAUDE.md: no docstrings, ever)",
                    )
                )
        name = os.path.basename(path_text)
        in_tests = name.startswith("test_") or os.sep + "tests" + os.sep in path_text
        findings.extend(inline_findings(tree, added, in_tests))
        if in_tests:
            findings.extend(duplicate_test_findings(tree, added))
    try:
        for token in tokenize.generate_tokens(io.StringIO(source).readline):
            if token.type != tokenize.COMMENT:
                continue
            line = token.start[0]
            if line not in added:
                continue
            body = token.string.lstrip("#").strip()
            if not body:
                continue
            if not body.lower().startswith(DIRECTIVE):
                findings.append(
                    (
                        line,
                        f"comment in new code; delete it (CLAUDE.md: no comments): {body[:60]!r}",
                    )
                )
            elif "—" in body:
                findings.append(
                    (line, "em-dash in comment; use a period, comma, colon or parens")
                )
    except (tokenize.TokenError, IndentationError, SyntaxError):
        pass
    total = len(new_lines)
    for line in added:
        if line <= total and ALLOWLIST_ASSIGN.search(new_lines[line - 1]):
            findings.append(
                (
                    line,
                    "_VALID_* allowlist; let the consumer raise or import the live source",
                )
            )
    return findings


def markdown_findings(new_lines, added):
    findings = []
    total = len(new_lines)
    for line in added:
        if line > total:
            continue
        text = new_lines[line - 1]
        if GLOSSARY_BULLET.match(text):
            findings.append((line, "**Term** — definition glossary bullet"))
        elif "—" in text:
            findings.append(
                (line, "em-dash connector; use a period, comma, colon or parens")
            )
    return findings


def vale_report(paths):
    import subprocess

    config_home = os.environ.get("XDG_CONFIG_HOME") or os.path.expanduser("~/.config")
    config = os.path.join(config_home, "vale", ".vale.ini")
    binary = os.path.expanduser("~/.pixi/bin/vale")
    if not os.path.isfile(binary):
        import shutil

        binary = shutil.which("vale")
    if not paths:
        return {}
    if not binary:
        report_degraded("vale is not installed")
        return {}
    if not os.path.isfile(config):
        report_degraded(f"vale config is missing: {config}")
        return {}
    try:
        result = subprocess.run(
            [binary, f"--config={config}", "--output=JSON"] + list(paths),
            capture_output=True,
            text=True,
            timeout=5,
        )
        if result.returncode != 0 and not result.stdout.strip():
            detail = result.stderr.strip().splitlines()
            report_degraded(
                f"vale exited {result.returncode}: {detail[0] if detail else 'no error output'}"
            )
            return {}
        report = json.loads(result.stdout or "{}")
    except subprocess.TimeoutExpired:
        report_degraded(f"vale exceeded its 5s budget on {len(paths)} file(s)")
        return {}
    except (OSError, ValueError, subprocess.SubprocessError) as error:
        report_degraded(f"vale failed: {type(error).__name__}: {error}")
        return {}
    if not isinstance(report, dict):
        report_degraded("vale returned a non-object JSON report")
        return {}
    alerts = {}
    for reported, entries in report.items():
        if not isinstance(entries, list):
            continue
        alerts[os.path.abspath(reported)] = [
            (
                entry.get("Line", 0),
                f"{entry.get('Check', 'vale')}: {entry.get('Message', '')}",
            )
            for entry in entries
            if isinstance(entry, dict)
        ]
    return alerts


def vale_findings(new_text, suffix, added):
    import tempfile

    handle = tempfile.NamedTemporaryFile(
        "w", suffix=suffix, delete=False, encoding="utf-8"
    )
    try:
        handle.write(new_text)
        handle.close()
        alerts = vale_report([handle.name])
    finally:
        try:
            os.unlink(handle.name)
        except OSError:
            pass
    return [
        (line, message)
        for line, message in alerts.get(os.path.abspath(handle.name), [])
        if line in added
    ]


def main():
    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return 0
    tool = payload.get("tool_name", "")
    tool_input = payload.get("tool_input", {})
    path = tool_input.get("file_path", "")
    if tool not in ("Write", "Edit") or not path.endswith((".py", ".md")):
        return 0

    old_text = ""
    if os.path.isfile(path):
        with open(path, encoding="utf-8", errors="replace") as handle:
            old_text = handle.read()

    if tool == "Write":
        new_text = tool_input.get("content", "")
    else:
        old_string = tool_input.get("old_string", "")
        if old_string not in old_text:
            return 0
        count = -1 if tool_input.get("replace_all") else 1
        new_text = old_text.replace(old_string, tool_input.get("new_string", ""), count)

    if new_text == old_text:
        return 0
    new_lines = new_text.splitlines()
    added = added_line_numbers(old_text.splitlines(), new_lines)
    if not added:
        return 0

    if path.endswith(".py"):
        findings = python_findings(new_text, new_lines, added, path)
        findings.extend(vale_findings(new_text, ".py", added))
    else:
        findings = markdown_findings(new_lines, added)
        findings.extend(vale_findings(new_text, ".md", added))
    if not findings:
        return 1 if DEGRADED else 0

    name = os.path.basename(path)
    report = "\n".join(
        f"  {name}:{line}  {message}" for line, message in sorted(set(findings))[:15]
    )
    sys.stderr.write(
        "BLOCKED by the no-slop gate. These are hard rules from CLAUDE.md. "
        "They outrank your own judgement about this code, and they are not open "
        "to discussion.\n"
        f"{report}\n"
        "Apply the stated fix and retry the edit. Do not defend the finding to "
        "the user, do not ask for an exception, and do not evade it by renaming "
        "a private helper to a public one or by inventing extra call sites.\n"
        "No comment survives this gate except a tool directive (noqa, type:, "
        "ruff:). Do not edit pre-existing lines to pass.\n"
    )
    return 2


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as error:
        report_degraded(f"{type(error).__name__}: {error}")
        sys.exit(1)
