# Dot Rot - Personal Development Environment Setup

This repository contains scripts and configurations for setting up a new development machine. The scripts are designed to be user-specific and won't affect other users on the same machine.

## Prerequisites

1. Install [Homebrew](https://brew.sh/)
2. Install [Oh My Zsh](https://ohmyz.sh/)

## Setup Order

Run these scripts in the following order:

### 1. macOS Defaults (`macos_defaults.sh`)

Sets up user-specific macOS preferences:
- Keyboard and input settings
  - Caps Lock key mapped to Control
  - Fast keyboard repeat rate
  - Disabled press-and-hold for keys
- Trackpad and mouse settings
- Screen and display settings
- Finder preferences
- Dock settings
- Mail.app settings
- Calendar settings
- Terminal settings
- Activity Monitor settings
- Software update preferences

```bash
./macos_defaults.sh
```

Note: Some keyboard settings may require a logout/login to take effect.

### 2. Install Applications (`brew.sh`)

Installs applications and tools via Homebrew:
- Development tools (VS Code, Docker, etc.)
- Communication apps (Slack, Signal, etc.)
- Utilities (Flycut, Keycastr, etc.)
- Fonts

```bash
./brew.sh
```

### 3. Development Environment Setup (`setup.sh`)

Sets up your development environment:
- Git configuration
- Oh My Zsh plugins and aliases
- VS Code extensions and settings
- Downloads personal assets (avatar, backgrounds)

```bash
./setup.sh
```

To skip VS Code extension installation:
```bash
./setup.sh --no-vscode
```

## Post-Setup Tasks

After running the scripts, you'll need to:

1. **Desktop Backgrounds**
   - Unzip `~/Pictures/agile-desktop-backgrounds.zip`
   - Add to System Settings > Wallpaper
   - Set to auto-rotate manually

2. **Additional Tools**
   - Install [LazyVim](https://www.lazyvim.org/installation)
   - Download [Chromeless](https://github.com/webcatalog/chromeless/releases) manually (brew install is broken)
   - Install OpenPomodoro CLI: `go get -u github.com/open-pomodoro/openpomodoro-cli/cmd/pomodoro`

3. **Secrets**
   - Copy your secrets manually:
     - `~/.gcalclirc`
     - `~/.gcalcli_oauth`
     - Other personal configuration files

## Notes

- All scripts are user-specific and won't affect other users on the same machine
- Scripts use `~` or `$HOME` to ensure configurations are installed in your user directory
- No system-wide settings are modified
- No `sudo` commands are used in the setup process

## Troubleshooting

If you encounter any issues:
1. Check that Homebrew and Oh My Zsh are properly installed
2. Ensure you have write permissions in your home directory
3. Verify that all required directories exist before running the scripts 