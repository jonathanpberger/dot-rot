#!/bin/sh

echo " ######################################### Starting JPB custom stuff"

# `git pull` strategy should be `rebase`
echo "#### Setting git pull strategy to rebase"
git config --global pull.rebase true

# Remove existing symlinks if they exist
echo "#### Setting up symlinks"
rm -f ~/.oh-my-zsh/custom/aliases.zsh
rm -f ~/.oh-my-zsh/custom/plugins/gday/gday.plugin.zsh
rm -f ~/.oh-my-zsh/custom/plugins/gh_project/gh_project.plugin.zsh

# Create directories if they don't exist
mkdir -p ~/.oh-my-zsh/custom/plugins/gday
mkdir -p ~/.oh-my-zsh/custom/plugins/gh_project

# Create new symlinks
ln -s ~/workspace/dot-rot/aliases.zsh ~/.oh-my-zsh/custom/aliases.zsh
ln -s ~/workspace/dot-rot/plugins/gday/gday.plugin.zsh ~/.oh-my-zsh/custom/plugins/gday/gday.plugin.zsh
ln -s ~/workspace/dot-rot/plugins/gh_project/gh_project.plugin.zsh ~/.oh-my-zsh/custom/plugins/gh_project/gh_project.plugin.zsh

# Enable gday plugin
if ! grep -q "plugins=(.*gday.*)" ~/.zshrc; then
  sed -i '' 's/plugins=(/plugins=(gday /' ~/.zshrc
fi

# install vscode extensions (skip if --no-vscode flag is passed)
if [[ "$1" != "--no-vscode" ]]; then
  echo "##### Installing VS Code extensions (this may take a while)"
  echo "##### Skip this step by running with --no-vscode flag"
  cat ./extensions.list | xargs -L1 code --install-extension
else
  echo "##### Skipping VS Code extensions installation"
fi

# VS Code setup
if [[ "$1" != "--no-vscode" ]]; then
  echo "#### Setting up VS Code configuration"
  
  # Backup and symlink settings
  VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
  mkdir -p "$VSCODE_USER_DIR"
  
  if [ -f "$VSCODE_USER_DIR/settings.json" ]; then
    cp "$VSCODE_USER_DIR/settings.json" "$VSCODE_USER_DIR/settings.json.backup.$(date +%F_%R)"
  fi
  ln -sf ~/workspace/dot-rot/vscode-global-settings.json "$VSCODE_USER_DIR/settings.json"
  
  # Symlink keybindings
  ln -sf ~/workspace/dot-rot/keybindings.json "$VSCODE_USER_DIR/keybindings.json"
  
  # Symlink snippets
  mkdir -p "$VSCODE_USER_DIR/snippets"
  ln -sf ~/workspace/dot-rot/snippets/markdown.json "$VSCODE_USER_DIR/snippets/markdown.json"
fi

# Download assets
echo "#### Downloading assets"
mkdir -p ~/Pictures

# Download avatar
if [ ! -f ~/Pictures/jpb-avatar.png ]; then
  echo "Downloading JPB avatar..."
  curl -L https://www.jonathanpberger.com/images/jpb-avatar.png -o ~/Pictures/jpb-avatar.png
fi

# Download backgrounds
if [ ! -f ~/Pictures/agile-desktop-backgrounds.zip ]; then
  echo "Downloading Agile desktop backgrounds..."
  curl -L https://www.jonathanpberger.com/agile-desktop-backgrounds.zip -o ~/Pictures/agile-desktop-backgrounds.zip
fi

echo "############ you'll need to unzip, add to Settings > Wallpaper, and set to auto-rotate manually."

echo "####### copy secrets manually, e.g. ~/.gcalclirc and ~/.gcalcli_oauth"

echo " ######################################### Finished JPB custom stuff"