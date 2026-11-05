# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository for automating macOS development environment setup. It contains shell scripts, configuration files, and custom tools for productivity and development workflow automation.

## Common Development Commands

### Initial Setup
```bash
./setup.sh              # Full setup including VS Code extensions
./setup.sh --no-vscode  # Setup without VS Code extensions
./brew.sh               # Install all Homebrew packages
./macos_defaults.sh     # Configure macOS system preferences
```

### Daily Workflow Commands
```bash
gday                    # Show today's calendar with git activity
gday yesterday          # Show yesterday's calendar and git commits
yday-semantic           # Show semantic git activity for yesterday
git-weekly              # Show git activity for the past week
```

### GitHub Project Management
```bash
ghi                     # List all open GitHub issues assigned to you
pmtl                    # Product Management Task List from GitHub Projects
ppi                     # Combined view of projects and issues
```

## Architecture and Structure

### Core Components

1. **Setup Scripts**: Automated environment configuration
   - `setup.sh`: Main setup orchestrator (git config, Oh My Zsh, VS Code)
   - `brew.sh`: Package installation via Homebrew
   - `macos_defaults.sh`: macOS system preferences

2. **Oh My Zsh Custom Plugins** (`plugins/`):
   - `gday/`: Calendar integration with Google Calendar via gcalcli, formats daily schedules with emoji, breaks appointments into pomodoros
   - `gh_project/`: GitHub CLI integrations for project and issue management

3. **Custom Tools** (`bin/`):
   - Git activity reporters with semantic commit analysis
   - Calendar and scheduling utilities
   - Development workflow scripts

4. **VS Code Configuration**:
   - Global settings with markdown focus and productivity tools
   - Custom keybindings for navigation and daily planning
   - 94 extensions for various languages and tools
   - Foam knowledge management integration

### Key Integrations

- **Calendar System**: gcalcli fetches Google Calendar events, formatted into markdown tables with time blocks
- **Git Workflow**: Custom scripts analyze commit messages semantically and provide daily/weekly summaries
- **Task Management**: Integration with macOS Reminders, GitHub Projects, and markdown-based "foam" notes
- **Development Tools**: Ruby scripts for Trello integration, email processing, and data transformations

### Important Files and Locations

- `aliases.zsh`: Custom shell aliases and functions
- `vscode-global-settings.json`: VS Code configuration
- `keybindings.json`: VS Code keyboard shortcuts
- `snippets/`: VS Code code snippets
- Ruby utilities: `fairplay_*.rb`, `trello_todos.rb`, `get_starred_emails.rb`

## Development Notes

- All configurations are user-specific (use `~` or `$HOME`)
- No system-wide changes or sudo commands required
- Primary languages: Shell (Bash/Zsh), Ruby, Markdown
- No formal testing framework - scripts are manually tested
- GitHub Actions workflow for automatic project management