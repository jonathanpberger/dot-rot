# Priority: Homebrew gday over dev version
export PATH="/opt/homebrew/bin:$PATH"
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell-worktree"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(gday rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(gday git)

source $ZSH/oh-my-zsh.sh

# User configuration

# Clear out PATH first to avoid duplicates
PATH=""


# Then add other paths in order of priority
export PATH="$PATH:$HOME/.cargo/bin"
export PATH="$PATH:$HOME/.bun/bin"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:/opt/homebrew/bin"
export PATH="$PATH:/usr/local/bin"
export PATH="$PATH:/usr/bin"
export PATH="$PATH:/bin"
export PATH="$PATH:/usr/sbin"
export PATH="$PATH:/sbin"

# Add any other specific paths you need
export PATH="$PATH:/Library/TeX/texbin"
export PATH="$PATH:/Applications/iTerm.app/Contents/Resources/utilities"
export PATH="$PATH:$HOME/.orbstack/bin"

# for SL Multisig
export MY_NAME=jon

[[ -r "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# Source machine-local secrets and overrides when present.
[[ -r "$HOME/workspace/dot-rot/.secrets" ]] && source "$HOME/workspace/dot-rot/.secrets"

# set up poetry
export PATH="/Users/jpb/.local/bin:$PATH"

# bun completions
[ -s "/Users/jpb/.bun/_bun" ] && source "/Users/jpb/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

command -v pkgx >/dev/null 2>&1 && eval "$(pkgx --quiet dev --shellcode)"  # https://github.com/pkgxdev/dev

# Go via homebrew (mise Go causes version conflicts)
export GOROOT="/opt/homebrew/opt/go/libexec"
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
export PATH="$GOROOT/bin:$GOPATH/bin:$PATH"

# Define claude function silently
function claude {
  "/Users/jpb/.claude/local/claude" "$@"
}

# Task Master aliases added on 4/23/2025
alias tm='task-master'
alias taskmaster='task-master'


# mise setup (should be first)
eval "$(mise activate zsh)"

# Prevent accidental mise go install (use homebrew Go instead)
# To bypass: comment out this function or run `command mise install go@X.Y.Z`
# Location: ~/.zshrc (search for "mise go install")
mise() {
  if [[ "$1" == "install" && "$2" == go* ]]; then
    echo "ERROR: Don't install Go via mise - use homebrew instead"
    echo "  brew install go"
    echo "  (To bypass this check, see ~/.zshrc and search for 'mise go install')"
    return 1
  fi
  command mise "$@"
}

# Override mise's Go with homebrew Go (mise Go has version conflicts)
export GOROOT="/opt/homebrew/opt/go/libexec"
export GOBIN="$HOME/go/bin"


export PATH="$PWD/bin:$PATH"

# Added by Windsurf
export PATH="/Users/jpb/.codeium/windsurf/bin:$PATH"
export PATH="/Users/jpb/.claude/local:$PATH"
export PATH="$HOME/bin:$PATH"

[[ -r /Users/jpb/.docker/init-zsh.sh ]] && source /Users/jpb/.docker/init-zsh.sh # Added by Docker Desktop

# Prioritize Homebrew gday over development version
export PATH="/opt/homebrew/bin:$PATH"


# Added by Antigravity
export PATH="/Users/jpb/.antigravity/antigravity/bin:$PATH"

# Amp CLI
export PATH="/Users/jpb/.amp/bin:$PATH"

# Git worktree helper - create worktree with new branch in .worktrees/
gwtab() {
  local branch="${1:?Branch name required}"
  if git show-ref --verify --quiet "refs/heads/$branch"; then
    git worktree add ".worktrees/$branch" "$branch"
  else
    git worktree add ".worktrees/$branch" -b "$branch"
  fi
}

# Claude Code skill pairing (pair-with ralph|gsd|powers|solo)
source ~/.claude/pair-with.sh


# Gas town (deprecated — superseded by Gas City, installed via Homebrew: brew install gascity)
export PATH="$PATH:$HOME/go/bin"

# gas city cleanup
unalias gc 2>/dev/null; alias gc="/opt/homebrew/Cellar/gascity/1.2.1/bin/gc"

# Git-duet for AI pair programming attribution
export GIT_DUET_CO_AUTHORED_BY=1
export GIT_DUET_GLOBAL=true
export MAXIMOFF_URL="https://wanda.discovery.works"

unalias br 2>/dev/null  # br installer - remove conflicting alias

# >>> MCP Agent Mail br path /Users/jpb/.local/bin
if [[ ":$PATH:" != *":/Users/jpb/.local/bin:"* ]]; then
  export PATH="/Users/jpb/.local/bin:$PATH"
fi
# <<< MCP Agent Mail br path

# >>> MCP Agent Mail bd alias
alias bd='br'
# <<< MCP Agent Mail bd alias
alias am="cd ~/workspace/mcp_agent_mail && uv run python -m mcp_agent_mail.cli serve-http"

eval "$(starship init zsh)"
