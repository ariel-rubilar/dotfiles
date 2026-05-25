#!/bin/bash

# Dotfiles installation script
# Symlinks configuration files from this repo to your home directory

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing dotfiles from $DOTFILES_DIR..."

# Create necessary directories
mkdir -p ~/.config
mkdir -p ~/.local/bin
mkdir -p ~/.local/share
mkdir -p ~/.cache

# Link home directory files
echo "Linking home files..."
ln -sfv "$DOTFILES_DIR/home/.zshenv" ~/.zshenv

# Link config files
echo "Linking config files..."
ln -sfv "$DOTFILES_DIR/config/zsh" ~/.config/zsh
ln -sfv "$DOTFILES_DIR/config/oh-my-posh" ~/.config/oh-my-posh
ln -sfv "$DOTFILES_DIR/config/zed" ~/.config/zed

# Link local bin (if exists)
if [ -d "$DOTFILES_DIR/local/bin" ]; then
    echo "Linking local/bin scripts..."
    ln -sfv "$DOTFILES_DIR/local/bin"/* ~/.local/bin/ 2>/dev/null || true
fi

echo "✅ Dotfiles installed successfully!"
echo ""
echo "Next steps:"
echo "1. Restart your terminal or run: exec zsh"
echo "2. Review ~/.config/zed/settings.json if you made changes"
