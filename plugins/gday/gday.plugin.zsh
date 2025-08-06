# gday plugin for oh-my-zsh
# Provides integration with gday-cli calendar tool

# Add gday-cli to PATH if it exists
if [[ -d "$HOME/workspace/gday-cli/bin" ]]; then
  export PATH="$HOME/workspace/gday-cli/bin:$PATH"
fi

# Aliases for common gday commands
alias gd='gday'
alias gday-later='gday later'
alias gday-filtered='gday filtered'
alias gday-yesterday='gday yesterday'
alias gday-yday='gday yday'

# Day-specific aliases
alias gday-mon='gday monday'
alias gday-tue='gday tuesday'
alias gday-wed='gday wednesday'
alias gday-thu='gday thursday'
alias gday-fri='gday friday'
alias gday-sat='gday saturday'
alias gday-sun='gday sunday'

# Function to show gday help
gday-help() {
  gday --help
}

# Function to re-authenticate with Google Calendar
gday-auth() {
  gday auth
}