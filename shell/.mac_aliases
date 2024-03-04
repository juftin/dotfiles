# notifications for when script finishes:
function notify() {
  NOTIFICATION_MESSAGE=${1:-Alert}
  NOTIFICATION_TITLE=${2:-Terminal Notification}
  NOTIFICATION_SCRIPT_PREFACE="osascript -e "
  NOTIFICATION_SCRIPT_SUFFIX='display notification "'${NOTIFICATION_MESSAGE}'" with title "'${NOTIFICATION_TITLE}'" sound name "Submarine"'
  NOTIFICATION_SCRIPT=${NOTIFICATION_SCRIPT_PREFACE}"'${NOTIFICATION_SCRIPT_SUFFIX}'"
  eval ${NOTIFICATION_SCRIPT}
}

# x86_64 Homebrew for Apple Silicon
alias xbrew="arch -x86_64 /usr/local/bin/brew"
