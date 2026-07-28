#!/bin/bash

# Comprehensive Claude Code status line.
#
# Line 1: model · directory · effort/thinking
# Line 2: git branch + status + clickable repo/PR links   (only inside a repo)
# Line 3: context-usage bar · cost · duration · rate limits
#
# Reads the session JSON that Claude Code pipes to stdin and prints these rows.
# All icons are standard emoji or block characters — no Nerd Font required.
# Git state is cached per-session (see CACHE_MAX_AGE) so large repos stay fast.
# See https://code.claude.com/docs/en/statusline

input=$(cat)

# ---- Extract every field we need in a single jq pass ----
# Fields are joined with the unit-separator byte (0x1f) rather than a tab: a
# non-whitespace IFS makes `read` preserve empty fields instead of collapsing
# them, so an absent field never shifts the ones after it.
SEP=$'\x1f'
IFS="$SEP" read -r MODEL CWD SESSION_ID COST DURATION_MS PCT CTX_SIZE \
	FIVE_H WEEK EFFORT THINKING PR_NUM PR_URL PR_STATE \
	< <(echo "$input" | jq -r '[
      .model.display_name                       // "?",
      .workspace.current_dir                    // ".",
      .session_id                               // "nosession",
      (.cost.total_cost_usd                     // 0),
      (.cost.total_duration_ms                  // 0),
      (.context_window.used_percentage          // 0),
      (.context_window.context_window_size      // 0),
      (.rate_limits.five_hour.used_percentage   // ""),
      (.rate_limits.seven_day.used_percentage   // ""),
      (.effort.level                            // ""),
      (.thinking.enabled                        // false),
      (.pr.number                               // ""),
      (.pr.url                                  // ""),
      (.pr.review_state                         // "")
    ] | map(tostring) | join("")')

# ---- Colors and terminal control bytes (real ESC/BEL so plain printf works) ----
ESC=$'\033'
BEL=$'\007'
RESET=$'\033[0m'
DIM=$'\033[2m'
BOLD=$'\033[1m'
RED=$'\033[31m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
BLUE=$'\033[34m'
MAGENTA=$'\033[35m'
CYAN=$'\033[36m'

# OSC 8 hyperlink: $(hyperlink URL TEXT) -> clickable TEXT (Cmd/Ctrl+click)
hyperlink() { printf '%s]8;;%s%s%s%s]8;;%s' "$ESC" "$1" "$BEL" "$2" "$ESC" "$BEL"; }

# ---- Git state, cached per session for 15 seconds ----
# TTL sits above the 5s statusLine refreshInterval so idle refreshes mostly
# re-render from cache; git commands actually run ~once every 15s.
CACHE_FILE="/tmp/claude-statusline-git-${SESSION_ID}"
CACHE_MAX_AGE=15

cache_is_stale() {
	[ ! -f "$CACHE_FILE" ] ||
		[ "$(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)))" -gt "$CACHE_MAX_AGE" ]
}

if cache_is_stale; then
	BRANCH=""
	STAGED=0
	MODIFIED=0
	UNTRACKED=0
	AHEAD=0
	BEHIND=0
	REPO_URL=""
	REPO_LABEL=""
	if git -C "$CWD" rev-parse --git-dir >/dev/null 2>&1; then
		BRANCH=$(git -C "$CWD" branch --show-current 2>/dev/null)
		STAGED=$(git -C "$CWD" diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
		MODIFIED=$(git -C "$CWD" diff --numstat 2>/dev/null | wc -l | tr -d ' ')
		UNTRACKED=$(git -C "$CWD" ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
		# rev-list --left-right --count @{u}...HEAD prints "<behind>\t<ahead>"
		if COUNTS=$(git -C "$CWD" rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null); then
			BEHIND=$(echo "$COUNTS" | cut -f1)
			AHEAD=$(echo "$COUNTS" | cut -f2)
		fi
		# Web URL for the origin remote (git@host:o/r.git and ssh:// both -> https://)
		REMOTE=$(git -C "$CWD" remote get-url origin 2>/dev/null)
		if [ -n "$REMOTE" ]; then
			REPO_URL=$(echo "$REMOTE" | sed -E 's#^git@([^:]+):#https://\1/#; s#^ssh://git@#https://#; s#\.git$##')
			# Label as owner/repo (the last two path segments of the URL)
			_rname=${REPO_URL##*/}
			_rowner=${REPO_URL%/*}
			_rowner=${_rowner##*/}
			REPO_LABEL="${_rowner}/${_rname}"
		fi
	fi
	printf '%s'"$SEP"'%s'"$SEP"'%s'"$SEP"'%s'"$SEP"'%s'"$SEP"'%s'"$SEP"'%s'"$SEP"'%s\n' \
		"$BRANCH" "$STAGED" "$MODIFIED" "$UNTRACKED" "$AHEAD" "$BEHIND" "$REPO_URL" "$REPO_LABEL" >"$CACHE_FILE"
fi
IFS="$SEP" read -r BRANCH STAGED MODIFIED UNTRACKED AHEAD BEHIND REPO_URL REPO_LABEL <"$CACHE_FILE"

# ==================== LINE 1 ====================
L1="${BOLD}${CYAN}🔷 ${MODEL}${RESET}"
L1+="  ${BLUE}📁 ${CWD##*/}${RESET}"

# All git info lives together on its own row (branch, status, and links).
GIT=""
if [ -n "$BRANCH" ]; then
	GIT="${MAGENTA}🌿 ${BRANCH}${RESET}"

	STATUS=""
	[ "${STAGED:-0}" -gt 0 ] && STATUS+=" ${GREEN}+${STAGED}${RESET}"
	[ "${MODIFIED:-0}" -gt 0 ] && STATUS+=" ${YELLOW}~${MODIFIED}${RESET}"
	[ "${UNTRACKED:-0}" -gt 0 ] && STATUS+=" ${CYAN}?${UNTRACKED}${RESET}"
	[ "${AHEAD:-0}" -gt 0 ] && STATUS+=" ⬆️${AHEAD}"
	[ "${BEHIND:-0}" -gt 0 ] && STATUS+=" ⬇️${BEHIND}"
	[ -z "$STATUS" ] && STATUS=" ✅"
	GIT+="$STATUS"
fi

# Reasoning effort + extended thinking (stay on the info line)
[ -n "$EFFORT" ] && L1+="  ${DIM}⚡${EFFORT}${RESET}"
[ "$THINKING" = "true" ] && L1+="  ${DIM}💭${RESET}"

# Clickable repository + pull-request links, appended to the same git row.
[ -n "$REPO_URL" ] && GIT+="${GIT:+  }🔗 ${CYAN}$(hyperlink "$REPO_URL" "$REPO_LABEL")${RESET}"
if [ -n "$PR_URL" ]; then
	case "$PR_STATE" in
	approved) PR_MARK="✅" ;;
	changes_requested) PR_MARK="❌" ;;
	pending) PR_MARK="🟡" ;;
	draft) PR_MARK="⚪" ;;
	*) PR_MARK="" ;;
	esac
	GIT+="${GIT:+  }🔀 ${MAGENTA}$(hyperlink "$PR_URL" "#${PR_NUM}")${RESET}${PR_MARK:+ $PR_MARK}"
fi

# ==================== LINE 2 ====================
# Context-usage bar, color-coded by fullness
PCT_INT=${PCT%%.*}
PCT_INT=${PCT_INT:-0}
[ "$PCT_INT" -gt 100 ] && PCT_INT=100
FILLED=$((PCT_INT / 10))
EMPTY=$((10 - FILLED))
if [ "$PCT_INT" -ge 90 ]; then
	BAR_COLOR="$RED"
elif [ "$PCT_INT" -ge 70 ]; then
	BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi
printf -v FILL "%${FILLED}s"
printf -v PAD "%${EMPTY}s"
BAR="${FILL// /▓}${PAD// /░}"
L2="${BAR_COLOR}${BAR}${RESET} ${PCT_INT}%"
# Mark extended (1M) context windows
[ "${CTX_SIZE:-0}" -ge 1000000 ] && L2+=" ${DIM}(1M)${RESET}"

# Cost
COST_FMT=$(printf '$%.2f' "${COST:-0}")
L2+="  ${YELLOW}💰 ${COST_FMT}${RESET}"

# Duration: Hh Mm or Mm Ss
DUR_S=$((${DURATION_MS:-0} / 1000))
if [ "$DUR_S" -ge 3600 ]; then
	DUR_FMT="$((DUR_S / 3600))h $(((DUR_S % 3600) / 60))m"
elif [ "$DUR_S" -ge 60 ]; then
	DUR_FMT="$((DUR_S / 60))m $((DUR_S % 60))s"
else DUR_FMT="${DUR_S}s"; fi
L2+="  ⏱️ ${DUR_FMT}"

# Rate limits (Claude.ai Pro/Max only; absent otherwise)
LIMITS=""
[ -n "$FIVE_H" ] && LIMITS+=" 5h:$(printf '%.0f' "$FIVE_H")%"
[ -n "$WEEK" ] && LIMITS+=" 7d:$(printf '%.0f' "$WEEK")%"
[ -n "$LIMITS" ] && L2+="  ${DIM}🔄${LIMITS}${RESET}"

# ---- Emit (bytes are already real escapes, so plain printf is correct) ----
# Info line, then the git row (only when in a repo), then the usage line.
OUT="$L1"
[ -n "$GIT" ] && OUT+=$'\n'"$GIT"
OUT+=$'\n'"$L2"
printf '%s\n' "$OUT"
