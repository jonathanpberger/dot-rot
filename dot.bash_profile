add_to_path() {
  export PATH="$PATH:$1"
}

# Load everything up
source "$HOME/dotrot/nakajima/aliases"
source "$HOME/dotrot/nakajima/gems"
source "$HOME/dotrot/nakajima/mysql"
source "$HOME/dotrot/nakajima/git_branch"

# For stupid little hacky scripts
add_to_path '/Users/patnakajima/bin'

# Color!
export CLICOLOR=1

# How it should look
export PS1="[\w] \u\$(parse_git_branch)$ "
