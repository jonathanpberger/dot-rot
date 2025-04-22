#!/bin/sh

# Install mas (Mac App Store CLI) if not already installed
if ! command -v mas &> /dev/null; then
    echo "Installing mas (Mac App Store CLI)..."
    brew install mas
fi

# Check if Xcode Command Line Tools are installed
if ! xcode-select -p &>/dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
    
    # Wait for Xcode Command Line Tools installation to complete
    echo "Waiting for Xcode Command Line Tools installation to complete..."
    while ! xcode-select -p &>/dev/null; do
        sleep 5
    done
else
    echo "Xcode Command Line Tools already installed"
fi

# Check if Xcode is installed
if [ ! -d "/Applications/Xcode.app" ]; then
    echo "Installing Xcode..."
    mas install 497799835
    
    # Wait for Xcode installation to complete
    echo "Waiting for Xcode installation to complete..."
    while [ ! -d "/Applications/Xcode.app" ]; do
        sleep 5
    done
else
    echo "Xcode already installed"
fi

# Accept Xcode license
echo "Accepting Xcode license..."
sudo xcodebuild -license accept

brew install --cask telegram
brew install ack
brew install cocoapods
brew install cowsay
brew install emojify
brew install firefox
brew install flycut
brew install font-noto
brew install font-noto-sans
brew install font-noto-serif
brew install font-san-francisco
brew install font-sanfrancisco
brew install font-sf
brew install imageoptim
brew install iterm2
brew install keycastr
brew install pd
brew install phoenix
brew install powerline-go
brew install rowanj-gitx
brew install signal
brew install skitch
brew install slack
brew install tree
brew install whatsapp
brew install zoom
brew install --cask visual-studio-code
brew install docker
brew tap homebrew/cask-fonts         # You only need to do this once!
brew install font-meslo-for-powerline
brew install --cask diffusionbee
brew install nvim
brew install wget
brew install gcalcli
brew install keith/formulae/reminders-cli

echo " ****\n ****** don't forget to install https://www.lazyvim.org/installation \n ****\n"
echo " ****\n ****** brew install chromeless is broken. DL the dmg: https://github.com/webcatalog/chromeless/releases \n ****\n"
echo " ****\n ****** go get -u github.com/open-pomodoro/openpomodoro-cli/cmd/pomodoro \n ****\n"
