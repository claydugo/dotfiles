import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

HOOK = str(Path(__file__).parents[1] / "no_slop_check.py")
REPO = "/tmp/no-slop-tests"
CASES = [
    (
        2,
        "vale: LLM vocabulary",
        f"{REPO}/owl/x.py",
        "# We delve into the tapestry here\nx = 1\n",
    ),
    (
        2,
        "vale: RestatesCode",
        f"{REPO}/owl/x.py",
        "# This function performs addition\ndef add(a, b):\n    return a + b\n",
    ),
    (2, "vale: SelfPraise", f"{REPO}/owl/x.py", "# Seamlessly handles it\nx = 1\n"),
    (
        2,
        "vale: markdown STE",
        f"{REPO}/architecture/x.md",
        "This is a very long sentence that keeps going well past any reasonable limit and should be flagged by the sentence length rule for sure.\n",
    ),
    (
        2,
        "every comment blocks",
        f"{REPO}/owl/x.py",
        "# n = 2 * k + 1\ndef bounding_box(points):\n    return min(points), max(points)\n",
    ),
    (
        0,
        "clean python, no comment",
        f"{REPO}/owl/x.py",
        "def bounding_box(points):\n    return min(points), max(points)\n",
    ),
    (
        0,
        "vale: numpy shape ok",
        f"{REPO}/architecture/x.md",
        "The kernel keeps the shape of the input array.\n",
    ),
    (
        0,
        "vale: 'the given pixel' ok",
        f"{REPO}/architecture/x.md",
        "The offset applies to the given pixel.\n",
    ),
    (
        2,
        "global config applies anywhere",
        "/tmp/nowhere/x.py",
        "# tapestry of options\nx = 1\n",
    ),
]
bad = 0
for want, label, target, content in CASES:
    payload = json.dumps(
        {"tool_name": "Write", "tool_input": {"file_path": target, "content": content}}
    )
    p = subprocess.run(
        [sys.executable, HOOK], input=payload, capture_output=True, text=True
    )
    ok = p.returncode == want
    bad += not ok
    error_lines = p.stderr.splitlines()
    detail = (
        error_lines[min(1, len(error_lines) - 1)].strip()[:78] if error_lines else ""
    )
    print(f"{'PASS' if ok else 'FAIL'} {label:26} exit={p.returncode}  {detail}")

degraded_home = tempfile.mkdtemp()
environment = os.environ.copy()
environment["HOME"] = degraded_home
environment["XDG_STATE_HOME"] = os.path.join(degraded_home, "state")
environment["PATH"] = "/usr/bin:/bin"
payload = json.dumps(
    {
        "tool_name": "Write",
        "tool_input": {"file_path": "/tmp/no-vale.py", "content": "value = 1\n"},
    }
)
process = subprocess.run(
    [sys.executable, HOOK],
    input=payload,
    capture_output=True,
    text=True,
    env=environment,
)
log_path = os.path.join(degraded_home, "state", "agent-hooks", "no-slop.log")
mode = os.stat(log_path).st_mode & 0o777
ok = (
    process.returncode == 1
    and "vale is not installed" in process.stderr
    and mode == 0o600
)
bad += not ok
print(
    f"{'PASS' if ok else 'FAIL'} {'missing Vale is visible':26} exit={process.returncode}"
)
shutil.rmtree(degraded_home)

total = len(CASES) + 1
print(f"\n{total - bad}/{total} passed")
raise SystemExit(bad > 0)
