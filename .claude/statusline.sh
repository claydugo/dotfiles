#!/usr/bin/env bash
# Claude Code status line — receives session JSON on stdin.
# Fields: https://code.claude.com/docs/en/statusline.md
export LC_ALL=C

# \x1f delimiter: unlike tab, non-whitespace IFS preserves empty fields
IFS=$'\x1f' read -r model effort fast ctx_pct in_tok out_tok win vim cost five five_reset seven version cache_rate pr_num pr_url pr_state <<<"$(jq -r '
  [
    (.model.display_name // "?"),
    (.effort.level // ""),
    (if .fast_mode then "1" else "" end),
    (.context_window.used_percentage // 0 | floor),
    (.context_window.total_input_tokens // 0),
    (.context_window.total_output_tokens // 0),
    (.context_window.context_window_size // 200000),
    (.vim.mode // ""),
    (.cost.total_cost_usd // 0),
    (.rate_limits.five_hour.used_percentage // -1 | floor),
    (.rate_limits.five_hour.resets_at // 0),
    (.rate_limits.seven_day.used_percentage // -1 | floor),
    (.version // "?"),
    (.context_window.current_usage as $u |
      (($u.input_tokens // 0) + ($u.cache_creation_input_tokens // 0) + ($u.cache_read_input_tokens // 0)) as $tot |
      if $tot == 0 then -1 else ($u.cache_read_input_tokens // 0) * 100 / $tot | floor end),
    (.pr.number // ""),
    (.pr.url // ""),
    (.pr.review_state // "")
  ] | map(tostring) | join("\u001f")')"

[[ -n $model ]] || exit 0

DIM=$'\033[2m' RST=$'\033[0m' GRN=$'\033[32m' YLW=$'\033[33m' RED=$'\033[31m' BLU=$'\033[34m' MAG=$'\033[35m'

pct_color() {
    if (($1 >= 80)); then printf '%s' "$RED"
    elif (($1 >= 50)); then printf '%s' "$YLW"
    else printf '%s' "$GRN"; fi
}

link() { # OSC 8 hyperlink: $1=url $2=text (degrades to plain text elsewhere)
    local st=$'\033\\' # ESC + backslash: OSC string terminator
    printf '\033]8;;%s%s%s\033]8;;%s' "$1" "$st" "$2" "$st"
}

bar() {
    local filled=$(($1 / 20)) out="" i
    ((filled > 5)) && filled=5
    for ((i = 0; i < 5; i++)); do
        ((i < filled)) && out+="▰" || out+="▱"
    done
    printf '%s' "$out"
}

seg=()

m="$model"
[[ -n $effort ]] && m+=" ${DIM}${effort}${RST}"
[[ -n $fast ]] && m+=" ⚡"
seg+=("$m")

tok_k=$(((in_tok + out_tok) / 1000))
if ((win >= 1000000)); then win_h="$((win / 1000000))M"; else win_h="$((win / 1000))k"; fi
seg+=("$(pct_color "$ctx_pct")$(bar "$ctx_pct") ${ctx_pct}%${RST} ${DIM}${tok_k}k/${win_h}${RST}")

((cache_rate >= 0)) && seg+=("${DIM}cache ${cache_rate}%${RST}")

cost_fmt=$(printf '%.2f' "$cost")
[[ $cost_fmt != 0.00 ]] && seg+=("${DIM}\$${cost_fmt}${RST}")

if ((five >= 0)); then
    s="$(pct_color "$five")5h ${five}%${RST}"
    if ((five_reset > 0)); then
        printf -v reset_fmt '%(%H:%M)T' "$five_reset"
        s+=" ${DIM}↻${reset_fmt}${RST}"
    fi
    ((seven >= 0)) && s+=" ${DIM}·${RST} $(pct_color "$seven")7d ${seven}%${RST}"
    seg+=("$(link 'https://claude.ai/settings/usage' "$s")")
fi

if [[ -n $pr_num ]]; then
    case $pr_state in
        approved) pc=$GRN ;;
        changes_requested) pc=$RED ;;
        *) pc=$YLW ;;
    esac
    p="${pc}PR #${pr_num}${RST}"
    [[ -n $pr_url ]] && p="$(link "$pr_url" "$p")"
    seg+=("$p")
fi

case $vim in
    NORMAL) seg+=("${BLU}N${RST}") ;;
    INSERT) seg+=("${GRN}I${RST}") ;;
    "VISUAL LINE") seg+=("${MAG}VL${RST}") ;;
    VISUAL) seg+=("${MAG}V${RST}") ;;
    *) [[ -n $vim ]] && seg+=("${DIM}${vim}${RST}") ;;
esac

seg+=("$(link 'https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md' "${DIM}v${version}${RST}")")

out=""
for s in "${seg[@]}"; do
    [[ -n $out ]] && out+=" ${DIM}|${RST} "
    out+="$s"
done
printf '%s' "$out"
