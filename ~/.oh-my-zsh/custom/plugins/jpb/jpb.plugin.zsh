# JPB's custom oh-my-zsh plugin
# Load all components

source ${0:A:h}/lib/calendar.zsh
source ${0:A:h}/lib/github.zsh
source ${0:A:h}/lib/utils.zsh
source ${0:A:h}/lib/vscode.zsh
source ${0:A:h}/lib/todo.zsh

# Export calendar configuration
export GCAL_CALENDARS=(
  "JPB-DW"
  "Pomo"
  "JPB Private"
)
