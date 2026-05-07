#!/usr/bin/env bash

set -eo pipefail

OUTPUT=${1:-benchmark-result.json}
ITERATIONS=${ITERATIONS:-10}

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

nvim --headless +qa >/dev/null 2>&1

echo "Running $ITERATIONS iterations..."
times=()
for i in $(seq 1 "$ITERATIONS"); do
    log="$tmpdir/startup-$i.log"
    nvim --startuptime "$log" --headless +qa >/dev/null 2>&1
    elapsed=$(awk 'NF { last=$1 } END { print last }' "$log")
    times+=("$elapsed")
    printf '  iter %2d: %sms\n' "$i" "$elapsed"
done

avg=$(printf '%s\n' "${times[@]}" | awk '{ total += $1; count++ } END { printf "%.3f", total/count }')
echo "Average: ${avg}ms"

cat > "$OUTPUT" <<EOF
[
  {
    "name": "nvim startup time",
    "unit": "ms",
    "value": $avg
  }
]
EOF
echo "Wrote $OUTPUT"
