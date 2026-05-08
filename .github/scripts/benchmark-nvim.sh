#!/usr/bin/env bash

set -eo pipefail

OUTPUT=${1:-benchmark-result.json}
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
    'nvim --headless +qa'

read -r median_ms stddev_ms min_ms <<<"$(python3 - "$tmpdir/result.json" <<'PY'
import json, sys
with open(sys.argv[1]) as f:
    r = json.load(f)["results"][0]
print(f"{r['median']*1000:.3f} {r['stddev']*1000:.3f} {r['min']*1000:.3f}")
PY
)"

echo "Median: ${median_ms}ms (stddev ${stddev_ms}ms, min ${min_ms}ms)"

cat > "$OUTPUT" <<EOF
[
  {
    "name": "nvim startup time",
    "unit": "ms",
    "value": $median_ms,
    "range": "±$stddev_ms"
  }
]
EOF
echo "Wrote $OUTPUT"
