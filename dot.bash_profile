function add_to_path {
  export PATH="$1:$PATH"
}

function dotrot {
  source "$HOME/dot-rot/nakajima/$1"
}

# Load everything up
dotrot "gems"
dotrot "mysql"
dotrot "git_branch"
dotrot "aliases"

# For stupid little hacky scripts
add_to_path '/Users/patnakajima/bin'

# Color!
export CLICOLOR=1

# How it should look
export PS1="[\w] \u\$(parse_git_branch)$ "
