#!/usr/bin/env bash

set -eo pipefail

OUTPUT=${1:-benchmark-bash-result.json}
ITERATIONS=${ITERATIONS:-20}

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

hyperfine \
    --warmup 3 \
    --runs "$ITERATIONS" \
    --shell=none \
    --style=basic \
    --export-csv "$tmpdir/result.csv" \
    'bash -i -c exit'

mean_seconds=$(awk -F, 'NR==2 { gsub(/"/, "", $2); print $2 }' "$tmpdir/result.csv")
mean_ms=$(awk -v m="$mean_seconds" 'BEGIN { printf "%.3f", m * 1000 }')

echo "Mean: ${mean_ms}ms"

cat > "$OUTPUT" <<EOF
[
  {
    "name": "bash startup time",
    "unit": "ms",
    "value": $mean_ms
  }
]
EOF
echo "Wrote $OUTPUT"
