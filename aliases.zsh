# This probably wants to go in ~/.oh-my-zsh/custom/aliases.zsh

# Generally helpful
alias hg="history | grep"
alias g="gcalcli"
alias pomo="pomodoro"

# Some alias / shell housekeeping
alias zsh.reload="source ~/.zshrc"
alias zsh.edit="vi ~/.zshrc"
alias zsh.alias="vi ~/.oh-my-zsh/custom/aliases.zsh"

# An alias for dvorak typists
alias aoeu='asdf'

# Some todo apps
alias r='reminders'
alias t='reminders'
alias ra='reminders add'
alias ta='reminders add'
alias rc='reminders complete Reminders'
alias td='reminders complete Reminders'
alias rsl='reminders show-lists'
alias tl='reminders show Reminders'
alias rs='reminders show Reminders'

# Now.md convenience methods
alias todos="ack '^.[^|\[]\[[^x]\]\s\w' ~/Dropbox/Notes-and-docs/JPB-monthly-notes/foam/now.md -C2" 
alias prev-todos="ack '^.[^|\[]\[[^x]\]\s\w' prev.md -C2" 
alias h2s="ack '^\#{2}\s' ~/Dropbox/Notes-and-docs/JPB-monthly-notes/foam/now.md -C1"           
alias projects="ack  '(\+\+\w.*)'  ~/Dropbox/Notes-and-docs/JPB-monthly-notes/foam/now.md --output '$1'"
alias prev-projects="ack  '(\+\+\w.*)'  ~/Dropbox/Notes-and-docs/JPB-monthly-notes/foam/prev.md --output '$1'"
alias foam="cd ~/Dropbox/Notes-and-docs/JPB-monthly-notes/foam"
