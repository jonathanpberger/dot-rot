#!/bin/sh

echo " ######################################### Starting JPB custom stuff"

# `git pull` strategy should be `rebase`
echo "#### `git pull` strategy should be `rebase`"
git config pull.rebase true

# symlink aliases and enable plugins
echo "#### symlink aliases and enable plugins"
ln -s ~/workspace/dot-rot/aliases.zsh ~/.oh-my-zsh/custom/aliases.zsh

# Enable gday plugin
if ! grep -q "plugins=(.*gday.*)" ~/.zshrc; then
  sed -i '' 's/plugins=(/plugins=(gday /' ~/.zshrc
fi

# install vscode extensions
echo "##### install vscode extensions"
cat ./extensions.list | xargs -L1 code --install-extension

# symlink global vscode settings
echo "#### symlink global vscode settings"
cp ~/Library/Application\ Support/Code/User/settings.json ~/Library/Application\ Support/Code/User/settings.json.backup.$(date +%F_%R)
ln -sf ~/workspace/dot-rot/vscode-global-settings.json ~/Library/Application\ Support/Code/User/settings.json\ Support/Code/User/settings.json

# symlink vscode keybindings
echo "#### symlink vscode keybindings"
ln -s ~/workspace/dot-rot/keybindings.json ~/Library/Application\ Support/Code/User

# symlink vscode snippets
echo "#### symlink vscode snippets"
mkdir -p ~~/Library/Application\ Support/Code/User/snippets
ln -s ~/workspace/dot-rot/keybindings.json ~/Library/Application\ Support/Code/User/snippets/markdown.json

# grab JPB avatar photo
echo "#### grab JPB avatar photo"
curl https://www.jonathanpberger.com/images/jpb-avatar.png . -o ~/Pictures/jpb-avatar.png

# grab Agile desktop backgrounds
echo "#### grab Agile desktop backgrounds"
curl https://www.jonathanpberger.com/agile-desktop-backgrounds.zip -o ~/Pictures/agile-desktop-backgrounds.zip

echo "############ you'll need to unzip, add to Settings > Wallpaper, and set to auto-rotate manually."

echo "####### copy secrets manually, e.g. ~/.gcalclirc and ~/.gcalcli_oauth"

echo " ######################################### Finished JPB custom stuff"