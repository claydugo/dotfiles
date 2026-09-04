import json
import subprocess
import sys
from pathlib import Path

HOOK = str(Path(__file__).parents[1] / "no_slop_check.py")

THREE_SAME = """
def test_small():
    assert bounding_box([1, 2]) == (1, 2)


def test_medium():
    assert bounding_box([3, 4]) == (3, 4)


def test_large():
    assert bounding_box([5, 6]) == (5, 6)
"""
TWO_SAME = """
def test_small():
    assert bounding_box([1, 2]) == (1, 2)


def test_medium():
    assert bounding_box([3, 4]) == (3, 4)
"""
DIFFERENT_CALLEES = """
def test_load():
    assert load('a') == 1


def test_save():
    assert save('b') == 2
"""
DIFFERENT_FIXTURES = """
def test_read(tmp_path):
    assert probe(tmp_path) == 1


def test_write(monkeypatch):
    assert probe(monkeypatch) == 1
"""
DIFFERENT = """
def test_bounds():
    assert bounding_box([1, 2]) == (1, 2)


def test_raises():
    with pytest.raises(ValueError):
        bounding_box([])


def test_roundtrip():
    data = load(save(thing))
    assert data == thing
"""
PARAMETRIZED = """
@pytest.mark.parametrize("values,expected", [([1, 2], (1, 2))])
def test_small(values, expected):
    assert bounding_box(values) == expected


@pytest.mark.parametrize("values,expected", [([5, 6], (5, 6))])
def test_medium(values, expected):
    assert bounding_box(values) == expected


@pytest.mark.parametrize("values,expected", [([9, 1], (9, 1))])
def test_large(values, expected):
    assert bounding_box(values) == expected
"""

NEAR_DUPLICATE = """
def test_empty():
    assert count([]) == 0


def test_single():
    assert count([1]) == 1
    assert count([1]) > 0
"""
CONTRACT_ASSERTION = """
def test_returns_a_dict():
    assert isinstance(load('a'), dict)
"""
FOUR_DISTINCT = """
def test_alpha():
    assert alpha(1) == 1


def test_beta():
    with pytest.raises(ValueError):
        beta(2)


def test_gamma():
    data = gamma(3)
    assert data.width == 3


def test_delta():
    assert delta(4) == [4, 4]
"""
PUBLIC_HELPER = """
def build_case(value):
    return value * 2


def test_thing():
    assert probe(build_case(2)) == 4
"""

CASES = [
    (2, "3 tests, same shape", "/tmp/p/tests/test_box.py", THREE_SAME),
    (2, "2 tests, same shape", "/tmp/p/tests/test_box.py", TWO_SAME),
    (0, "3 tests, distinct", "/tmp/p/tests/test_box.py", DIFFERENT),
    (0, "different function under test", "/tmp/p/tests/test_box.py", DIFFERENT_CALLEES),
    (0, "different fixtures", "/tmp/p/tests/test_box.py", DIFFERENT_FIXTURES),
    (0, "already parametrized", "/tmp/p/tests/test_box.py", PARAMETRIZED),
    (0, "not a test file", "/tmp/p/owl/box.py", THREE_SAME.replace("test_", "check_")),
    (2, "near-duplicate, extra assert", "/tmp/p/tests/test_box.py", NEAR_DUPLICATE),
    (0, "contract assertion", "/tmp/p/tests/test_box.py", CONTRACT_ASSERTION),
    (0, "4 distinct tests", "/tmp/p/tests/test_box.py", FOUR_DISTINCT),
    (2, "public helper in a test file", "/tmp/p/tests/test_box.py", PUBLIC_HELPER),
]

failures = 0
for want, label, target, content in CASES:
    payload = json.dumps(
        {"tool_name": "Write", "tool_input": {"file_path": target, "content": content}}
    )
    proc = subprocess.run(
        [sys.executable, HOOK], input=payload, capture_output=True, text=True
    )
    ok = proc.returncode == want
    failures += not ok
    print(f"{'PASS' if ok else 'FAIL'} {label:24} exit={proc.returncode}")
print(f"\n{len(CASES) - failures}/{len(CASES)} passed")
raise SystemExit(failures > 0)
