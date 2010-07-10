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
add_to_path "/usr/local/git/bin"

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
# export LSCOLORS=GxFxCxDxBxegedabagacad # Pat colors
export LSCOLORS=ExFxCxDxBxegedabagacad # Corey colors


# Edit!
export EDITOR="mate -w"

# How it should look
# export PS1="[\w]\[\e[1m\]\$(parse_git_branch)\[\e[0m\]$ " # Pat's prompt

#  Corey's prompt http://www.cyberciti.biz/tips/howto-linux-unix-bash-shell-setup-prompt.html

# corey's "parse_svn_branch" kept giving me trouble, so I rm'd it
# export PS1="\[\033[00m\]\u@\h\[\033[01;34m\] \W\[\033[31m\] \$(parse_git_branch)\$(parse_svn_branch) \[\033[00m\]$\[\033[00m\] "
export PS1="\[\033[00m\]\u@\h\[\033[01;34m\] \W\[\033[31m\] \$(parse_git_branch) \[\033[00m\]$\[\033[00m\] "

# version of prompt w/o SVN parsing
# export PS1="\[\033[00m\]\u@\h\[\033[01;34m\] \W\[\033[31m\] \[\033[00m\]$\[\033[00m\] "



# Setting PATH for MacPython 2.5
# The orginal version is saved in .bash_profile.pysave
# PATH="/Library/Frameworks/Python.framework/Versions/Current/bin:${PATH}"
# export PATH


# Keep machine-specific stuff in .bash_local
touch ~/.bash_local
source ~/.bash_local


# MacPorts Installer addition on 2009-10-14_at_01:14:33: adding an appropriate PATH variable for use with MacPorts.
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
# Finished adapting your PATH environment variable for use with MacPorts.


##
# Your previous /Users/jpb/.profile file was backed up as /Users/jpb/.profile.macports-saved_2009-10-14_at_07:17:50
##

# MacPorts Installer addition on 2009-10-14_at_07:17:50: adding an appropriate PATH variable for use with MacPorts.
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
# Finished adapting your PATH environment variable for use with MacPorts.

