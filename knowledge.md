# Dot-rot Knowledge

## Plugin Management

- All oh-my-zsh plugins are stored in `plugins/` directory
- Plugins are symlinked to `~/.oh-my-zsh/custom/plugins/` during setup
- gday plugin is managed in dot-rot repo and symlinked to oh-my-zsh
- Only edit plugin files in dot-rot repo, never edit symlinked versions directly

## Setup Process

1. Clone dot-rot repo to ~/workspace/dot-rot
2. Run setup.sh to:
   - Create necessary directories
   - Symlink plugins to oh-my-zsh
   - Enable plugins in .zshrc
   - Set up VS Code settings and extensions

## Development

- Make changes to plugins in dot-rot repo
- Changes are immediately reflected due to symlinks
- Keep all dotfiles and plugins in one repo for easier management
