#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
PACKAGES=(thunar picom kitty firefox feh)

install_packages() {
  echo "Installing packages: ${PACKAGES[*]}..."
  if command -v pacman &>/dev/null; then
    sudo pacman -Syu --needed --noconfirm "${PACKAGES[@]}"
  elif command -v apt &>/dev/null; then
    sudo apt update && sudo apt install -y "${PACKAGES[@]}"
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y "${PACKAGES[@]}"
  else
    echo "Unsupported package manager. Install manually: ${PACKAGES[*]}"
  fi
}

link_item() {
  local src="$1"
  local dest="$2"

  if [ ! -e "$src" ]; then
    echo "Skipping missing source: $src"
    return
  fi

  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mkdir -p "$BACKUP_DIR"
    mv "$dest" "$BACKUP_DIR/"
    echo "Backed up $dest -> $BACKUP_DIR/"
  fi

  mkdir -p "$(dirname "$dest")"
  ln -sfn "$src" "$dest"
  echo "Linked $dest -> $src"
}

install_packages

link_item "$DOTFILES_DIR/i3" "$HOME/.config/i3"
link_item "$DOTFILES_DIR/i3status" "$HOME/.config/i3status"
link_item "$DOTFILES_DIR/kitty" "$HOME/.config/kitty"
link_item "$DOTFILES_DIR/wallpapers" "$HOME/.config/wallpapers"

echo "Setup complete!"
