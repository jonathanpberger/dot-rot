function add_to_path {
  export PATH="$1:$PATH"
}

function dotrot {
  source "$HOME/dot-rot/nakajima/$1"
}

# Load everything up
dotrot "gems"
dotrot "mysql"
dotrot "aliases"

# For stupid little hacky scripts
add_to_path '/Users/patnakajima/bin'
add_to_path "$HOME/dot-rot/bin"

# Color!
export CLICOLOR=1

# How it should look
export PS1="[\w]\[\e[1m\]\$(parse_git_branch)\[\e[0m\]$ "

# Setting PATH for MacPython 2.5
# The orginal version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/Current/bin:${PATH}"
export PATH

# Keep machine-specific stuff in .bash_local
touch ~/.bash_local
source ~/.bash_local
