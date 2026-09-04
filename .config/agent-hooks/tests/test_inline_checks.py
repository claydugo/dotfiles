import json
import subprocess
import sys
from pathlib import Path

HOOK = str(Path(__file__).parents[1] / "no_slop_check.py")
CASES = [
    (
        "BLOCK",
        2,
        "helper, 1 call site",
        "def _compute(x):\n    return x * 2\n\nresult = _compute(3)\n",
    ),
    (
        "BLOCK",
        2,
        "helper, 2 call sites",
        "def _compute(x):\n    return x * 2\n\na = _compute(1)\nb = _compute(2)\n",
    ),
    (
        "BLOCK",
        2,
        "constant, 1 use",
        "_THRESHOLD = 0.5\n\ndef check(v):\n    return v > _THRESHOLD\n",
    ),
    (
        "BLOCK",
        2,
        "private method, 1 call",
        "class Camera:\n    def _reset(self):\n        return None\n\n    def run(self):\n        self._reset()\n",
    ),
    (
        "PASS",
        0,
        "helper, 3 call sites",
        "def _compute(x):\n    return x * 2\n\na = _compute(1)\nb = _compute(2)\nc = _compute(3)\n",
    ),
    (
        "PASS",
        0,
        "constant, 3 uses",
        "_LIMIT = 8\n\ndef f(a, b, c):\n    return a > _LIMIT, b > _LIMIT, c > _LIMIT\n",
    ),
    (
        "PASS",
        0,
        "decorated fixture",
        "import pytest\n\n@pytest.fixture\ndef _dataset():\n    return 1\n",
    ),
    (
        "PASS",
        0,
        "dunder method",
        "class Camera:\n    def __init__(self):\n        self.x = 1\n",
    ),
    (
        "PASS",
        0,
        "_repr_html_ trailing _",
        "class Camera:\n    def _repr_html_(self):\n        return 'x'\n",
    ),
    (
        "PASS",
        0,
        "public helper",
        "def compute(x):\n    return x * 2\n\nr = compute(3)\n",
    ),
    (
        "PASS",
        0,
        "public constant",
        "THRESHOLD = 0.5\n\ndef check(v):\n    return v > THRESHOLD\n",
    ),
    (
        "PASS",
        0,
        "name in __all__",
        "__all__ = ['_compute']\n\ndef _compute(x):\n    return x * 2\n",
    ),
    (
        "PASS",
        0,
        "non-literal (getLogger)",
        "import logging\n_LOGGER = logging.getLogger(__name__)\n_LOGGER.info('hi')\n",
    ),
    (
        "PASS",
        0,
        "TypeVar",
        "from typing import TypeVar\n_T = TypeVar('_T')\n\ndef f(x: _T) -> _T:\n    return x\n",
    ),
    (
        "PASS",
        0,
        "decorator 3 uses",
        "def _cache(fn):\n    return fn\n\n@_cache\ndef a(): return 1\n\n@_cache\ndef b(): return 2\n\n@_cache\ndef c(): return 3\n",
    ),
    (
        "PASS",
        0,
        "qt slot connected once",
        "class Panel:\n    def _on_clicked(self):\n        return None\n\n    def build(self, button):\n        button.clicked.connect(self._on_clicked)\n",
    ),
    (
        "PASS",
        0,
        "callback passed to a helper",
        "def _handle(value):\n    return value\n\ndef build(widget):\n    widget.bind(_handle)\n",
    ),
    (
        "PASS",
        0,
        "override calling super",
        "class Array(Base):\n    def _updated_key(self, key, *, arrays=True):\n        return super()._updated_key(key, arrays=arrays)\n",
    ),
    (
        "BLOCK",
        2,
        "connected once and called once",
        "class Panel:\n    def _refresh(self):\n        return None\n\n    def build(self, button):\n        button.clicked.connect(self._refresh)\n        self._refresh()\n",
    ),
    (
        "BLOCK",
        2,
        "private method never referenced",
        "class Camera:\n    def _reset(self):\n        return None\n",
    ),
    (
        "PASS",
        0,
        "branch in the body",
        "class Panel:\n    def _name(self, key):\n        if key is None:\n            return 'all'\n        return str(key)\n\n    def run(self):\n        return self._name(1)\n",
    ),
    (
        "PASS",
        0,
        "loop in the body",
        "class Panel:\n    def _style(self, buttons):\n        for b in buttons:\n            b.setStyleSheet('')\n\n    def run(self, buttons):\n        self._style(buttons)\n",
    ),
    (
        "PASS",
        0,
        "four straight statements",
        "class Panel:\n    def _build(self):\n        self.a = 1\n        self.b = 2\n        self.c = 3\n        self.d = 4\n\n    def run(self):\n        self._build()\n",
    ),
    (
        "BLOCK",
        2,
        "three straight statements",
        "class Panel:\n    def _build(self):\n        self.a = 1\n        self.b = 2\n        self.c = 3\n\n    def run(self):\n        self._build()\n",
    ),
    (
        "PASS",
        0,
        "ternary is not a branch, 3 sites",
        "def _pick(x):\n    return 1 if x else 2\n\na = _pick(1)\nb = _pick(2)\nc = _pick(3)\n",
    ),
    (
        "BLOCK",
        2,
        "ternary is not a branch",
        "def _pick(x):\n    return 1 if x else 2\n\na = _pick(1)\n",
    ),
    (
        "PASS",
        0,
        "curried slot, lambda call sites",
        "class Panel:\n    def _set_source(self, files):\n        self.files = files\n        self.refresh()\n\n    def build(self, a, b):\n        a.clicked.connect(lambda: self._set_source(False))\n        b.clicked.connect(lambda: self._set_source(True))\n",
    ),
    (
        "BLOCK",
        2,
        "called in a lambda and directly",
        "class Panel:\n    def _set_source(self, files):\n        self.files = files\n        self.refresh()\n\n    def build(self, a):\n        a.clicked.connect(lambda: self._set_source(False))\n        self._set_source(True)\n",
    ),
]
failures = 0
for kind, want, label, content in CASES:
    payload = json.dumps(
        {
            "tool_name": "Write",
            "tool_input": {"file_path": "/nonexistent/t.py", "content": content},
        }
    )
    proc = subprocess.run(
        [sys.executable, HOOK], input=payload, capture_output=True, text=True
    )
    ok = proc.returncode == want
    failures += not ok
    detail = ""
    if proc.stderr:
        detail = proc.stderr.splitlines()[1].strip().replace("t.py:", "L")
    print(
        f"{'PASS' if ok else 'FAIL'} [{kind:5}] {label:26} exit={proc.returncode}  {detail}"
    )
print(f"\n{len(CASES) - failures}/{len(CASES)} passed")
raise SystemExit(failures > 0)
