function add_to_path {
  export PATH="$1:$PATH"
}

# Load everything up
source "$HOME/dot-rot/nakajima/j"
source "$HOME/dot-rot/nakajima/gems"
source "$HOME/dot-rot/nakajima/mysql"
source "$HOME/dot-rot/nakajima/aliases"

# Vendor files
source "$HOME/dot-rot/vendor/j2/j.sh"
source "$HOME/dot-rot/vendor/git_completions.sh"

# For stupid little hacky scripts
add_to_path '/Users/jpb/bin'
add_to_path "$HOME/dot-rot/bin"

# Color!
export CLICOLOR=1

# Edit!
export EDITOR='emacs'

# How it should look
export PS1="[\w]\[\e[1m\]\$(parse_git_branch)\[\e[0m\] "

# export LSCOLORS=GxFxCxDxBxegedabagacad # Pat colors
export LSCOLORS=ExFxCxDxBxegedabagacad # Corey colors


# Edit!
export EDITOR="mate -w"

# How it should look
# export PS1="[\w]\[\e[1m\]\$(parse_git_branch)\[\e[0m\]$ " # Pat's prompt

#  Corey's prompt http://www.cyberciti.biz/tips/howto-linux-unix-bash-shell-setup-prompt.html

# corey's "parse_svn_branch" kept giving me trouble, so I rm'd it
# export PS1="\[\033[00m\]\u@\h\[\033[01;34m\] \W\[\033[31m\] \$(parse_git_branch)\$(parse_svn_branch) \[\033[00m\]$\[\033[00m\] "

export PS1="\[\033[00m\]\u@\h\[\033[01;34m\] \W\[\033[31m\] \[\033[00m\]$\[\033[00m\] "


# Added some of CoreyTi's OSX-Install prefs

# Setting PATH for MacPython 2.5
# The orginal version is saved in .bash_profile.pysave
# PATH="/Library/Frameworks/Python.framework/Versions/Current/bin:${PATH}"
# export PATH

# Setup Rake tab completion
complete -C "$HOME/dot-rot/bin/rake_tabber" -o default rake

# Keep machine-specific stuff in .bash_local
touch ~/.bash_local
source ~/.bash_local

# -- start rip config -- #
RIPDIR="$HOME/.rip"
RUBYLIB="$RUBYLIB:$RIPDIR/active/lib"
PATH="$PATH:$RIPDIR/active/bin"
export RIPDIR RUBYLIB PATH
# -- end rip config -- #

# Make `$ ruby` start ruby
# put this in ~/.bash_profile or whatever
ruby_or_irb () {
  if [ "$1" == "" ]; then
    irb
  else
    ruby "$@"
  fi
}
alias rb="ruby_or_irb"

add_to_path "/usr/local/git/bin"
