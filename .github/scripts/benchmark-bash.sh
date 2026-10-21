#!/usr/bin/env bash

set -eo pipefail

OUTPUT=${1:-benchmark-bash-result.json}
WARMUPS=${WARMUPS:-3}
RUNS=${RUNS:-30}

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

hyperfine \
    --warmup "$WARMUPS" \
    --runs "$RUNS" \
    --shell=none \
    --style=basic \
    --export-json "$tmpdir/result.json" \
    'bash -i -c exit'

python3 - "$tmpdir/result.json" "$OUTPUT" <<'PY'
import json, sys
with open(sys.argv[1]) as f:
    r = json.load(f)["results"][0]
median_ms = r["median"] * 1000
stddev_ms = r["stddev"] * 1000
min_ms = r["min"] * 1000
print(f"Median: {median_ms:.3f}ms (stddev {stddev_ms:.3f}ms, min {min_ms:.3f}ms)")
with open(sys.argv[2], "w") as f:
    json.dump(
        [{"name": "bash startup time", "unit": "ms", "value": round(median_ms, 3), "range": f"±{stddev_ms:.3f}"}],
        f,
        indent=2,
        allow_nan=False,
    )
PY
echo "Wrote $OUTPUT"
