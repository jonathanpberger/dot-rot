##
# Git Stuff

# get the name of the branch we are on
git_prompt_info() {
  ref=$(git-symbolic-ref HEAD 2> /dev/null) || return
  echo "(${ref#refs/heads/})"
}

##
# Prompt Stuff
# PROMPT='%{$fg_bold[green]%}%n@%m %{$fg[blue]%}%c %{$fg_bold[red]%}$(git_prompt_info)%{$fg[blue]%} %% %{$reset_color%}'
PROMPT='[%~] %{$(git_prompt_info)%'


##
# Colors
autoload colors
colors