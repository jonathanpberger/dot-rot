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

# make RVM work
[[ -s $HOME/.rvm/scripts/rvm ]] && source $HOME/.rvm/scripts/rvm

# Functions to put the version control branch in the prompt
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(git::\1)/'
}
parse_svn_branch() {
  parse_svn_url | sed -e 's#^'"$(parse_svn_repository_root)"'##g' | awk -F / '{print "(svn::"$1 "/" $2 ")"}'
}
parse_svn_url() {
  svn info 2>/dev/null | grep -e '^URL*' | sed -e 's#^URL: *\(.*\)#\1#g '
}
parse_svn_repository_root() {
  svn info 2>/dev/null | grep -e '^Repository Root:*' | sed -e 's#^Repository Root: *\(.*\)#\1\/#g'
}

# Color!
export CLICOLOR=1

# Edit!
export EDITOR='mvim'

# export LSCOLORS=GxFxCxDxBxegedabagacad # Pat colors
export LSCOLORS=ExFxCxDxBxegedabagacad # Corey colors


## How it should look
# export PS1="[\w]\[\e[1m\]\$(parse_git_branch)\[\e[0m\]$ " # Pat's prompt
#  Corey's prompt http://www.cyberciti.biz/tips/howto-linux-unix-bash-shell-setup-prompt.html

# corey's "parse_svn_branch" kept giving me trouble, so I rm'd it
export PS1="\[\033[00m\]\u@\h\[\033[01;34m\] \W\[\033[31m\] \$(parse_git_branch)\$(parse_svn_branch) \[\033[00m\]$\[\033[00m\] "

# version of prompt w/o SVN parsing
# export PS1="\[\033[00m\]\u@\h\[\033[01;34m\] \W\[\033[31m\] \[\033[00m\]$\[\033[00m\] "


# Added some of CoreyTi's OSX-Install prefs

# Setup Rake tab completion
complete -C "$HOME/dot-rot/bin/rake_tabber" -o default rake

# Keep machine-specific stuff in .bash_local
touch ~/.bash_local
source ~/.bash_local

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
