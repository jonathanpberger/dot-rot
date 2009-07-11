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
add_to_path '/Users/jpb/bin'
add_to_path "$HOME/dot-rot/bin"

# Color!
export CLICOLOR=1
# export LSCOLORS=GxFxCxDxBxegedabagacad # Pat colors
export LSCOLORS=ExFxCxDxBxegedabagacad # Corey colors


# Edit!
export EDITOR="mate -w"

# How it should look
# export PS1="[\w]\[\e[1m\]\$(parse_git_branch)\[\e[0m\]$ " # Pat's prompt

#  Corey's prompt http://www.cyberciti.biz/tips/howto-linux-unix-bash-shell-setup-prompt.html
export PS1="\[\033[00m\]\u@\h\[\033[01;34m\] \W\[\033[31m\] \$(parse_git_branch)\$(parse_svn_branch) \[\033[00m\]$\[\033[00m\] "



# Setting PATH for MacPython 2.5
# The orginal version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/Current/bin:${PATH}"
export PATH


add_to_path "/usr/local/git/bin"

# Keep machine-specific stuff in .bash_local
touch ~/.bash_local
source ~/.bash_local

