#!/bin/sh

echo " ######################################### Starting JPB custom stuff"

# symlink aliases
echo "#### symlink aliases"
ln -s ~/workspace/dot-rot/aliases.zsh ~/.oh-my-zsh/custom/aliases.zsh

# install vscode extensions
echo "##### install vscode extensions"
cat ./extensions.list | xargs -L1 code --install-extension

# symlink global vscode settings
echo "#### symlink global vscode settings"
cp ~/Library/Application\ Support/Code/User/settings.json ~/Library/Application\ Support/Code/User/settings.json.backup.$(date +%F_%R)
ln -sf ~/workspace/dot-rot/vscode-global-settings.json ~/Library/Application\ Support/Code/User/settings.json\ Support/Code/User/settings.json

# grab JPB avatar photo
echo "#### grab JPB avatar photo"
curl https://www.jonathanpberger.com/images/jpb-avatar.png . -o ~/Pictures/jpb-avatar.png

# grab Agile desktop backgrounds
echo "#### grab Agile desktop backgrounds"
curl https://www.jonathanpberger.com/agile-desktop-backgrounds.zip -o ~/Pictures/agile-desktop-backgrounds.zip

echo "############ you'll need to unzip, add to Settings > Wallpaper, and set to auto-rotate manually."

echo " ######################################### Finished JPB custom stuff"