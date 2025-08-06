# Based on robbyrussell theme with worktree support

PROMPT="%(?:%{$fg_bold[green]%}%1{➜%} :%{$fg_bold[red]%}%1{➜%} ) %{$fg[cyan]%}%c%{$reset_color%}"
PROMPT+=' $(git_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}%1{✗%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"

# Custom worktree info function - only show worktree if different from branch
parse_worktree_info() {
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        # Check if we're in a worktree (not the main repo)
        if [[ -f "$(git rev-parse --git-dir)" ]]; then
            local worktree=$(basename "$PWD")
            local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
            if [[ "$worktree" != "$branch" ]]; then
                echo "@${worktree}"
            fi
        fi
    fi
}

# Override git_prompt_info to include worktree
function git_prompt_info() {
  local ref
  if [[ "$(command git config --get oh-my-zsh.hide-status 2>/dev/null)" != "1" ]]; then
    ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
    ref=$(command git rev-parse --short HEAD 2> /dev/null) || return 0
    echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$(parse_worktree_info)$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_SUFFIX"
  fi
}