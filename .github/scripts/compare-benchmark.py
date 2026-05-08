#!/usr/bin/env python3
"""Compare a benchmark result against a rolling-median baseline of recent runs.

History format is compatible with the github-action-benchmark
``benchmark-data.json`` layout so the file stays easy to inspect by hand.
"""

from __future__ import annotations

import argparse
import datetime
import json
import os
import sys
from pathlib import Path


def median(values: list[float]) -> float:
    s = sorted(values)
    n = len(s)
    return s[n // 2] if n % 2 else (s[n // 2 - 1] + s[n // 2]) / 2


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("current", type=Path, help="Path to current result JSON")
    p.add_argument("history_dir", type=Path, help="Directory holding benchmark-data.json")
    p.add_argument("suite", help="Benchmark suite name (history key)")
    p.add_argument("--record", action="store_true", help="Append current result to history")
    p.add_argument("--window", type=int, default=10, help="Recent entries to median (default: 10)")
    p.add_argument("--threshold", type=float, default=1.5, help="Regression ratio (default: 1.5)")
    p.add_argument("--max-entries", type=int, default=200, help="Cap stored history (default: 200)")
    args = p.parse_args()

    args.history_dir.mkdir(parents=True, exist_ok=True)
    history_path = args.history_dir / "benchmark-data.json"

    current = json.loads(args.current.read_text())[0]
    value = current["value"]
    unit = current["unit"]

    if history_path.exists():
        history = json.loads(history_path.read_text())
    else:
        history = {"entries": {}}

    entries = history["entries"].setdefault(args.suite, [])
    recent = entries[-args.window:]

    print(f"Suite: {args.suite}")
    print(f"Current: {value}{unit}")

    if recent:
        baseline = median([e["benches"][0]["value"] for e in recent])
        ratio = value / baseline
        print(f"Baseline (median of last {len(recent)}): {baseline:.3f}{unit}")
        print(f"Ratio: {ratio:.2f}x (regression threshold {args.threshold}x)")
        if ratio > args.threshold:
            print(
                f"::warning title=Benchmark regression::{args.suite}: "
                f"{value:.2f}{unit} is {ratio:.2f}x the median of the last "
                f"{len(recent)} runs ({baseline:.2f}{unit})"
            )
    else:
        print("Baseline: (no history yet — recording without comparison)")

    if args.record:
        entries.append({
            "commit": {"id": os.environ.get("GITHUB_SHA", "")},
            "date": int(datetime.datetime.now().timestamp() * 1000),
            "tool": "customSmallerIsBetter",
            "benches": [{"name": current["name"], "value": value, "unit": unit}],
        })
        history["entries"][args.suite] = entries[-args.max_entries:]
        history_path.write_text(json.dumps(history, indent=2))
        print(f"Recorded entry ({len(history['entries'][args.suite])} total) to {history_path}")
    else:
        print("Not recording (--record not set)")

    return 0


if __name__ == "__main__":
    sys.exit(main())
