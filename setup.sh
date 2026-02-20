#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()    { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# ---------------------------------------------------
# Homebrew
# ---------------------------------------------------
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add brew to PATH for the rest of this script
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  info "Homebrew already installed"
fi

# ---------------------------------------------------
# Formulae & Casks
# ---------------------------------------------------
FORMULAE=(
  stow
  neovim
  oh-my-posh
  eza
  bat
  fzf
  zoxide
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
)

CASKS=(
  ghostty
  font-jetbrains-mono-nerd-font
)

info "Updating Homebrew..."
brew update

info "Installing formulae..."
for formula in "${FORMULAE[@]}"; do
  if brew list "$formula" &>/dev/null; then
    warn "$formula already installed"
  else
    info "Installing $formula..."
    brew install "$formula"
  fi
done

info "Installing casks..."
for cask in "${CASKS[@]}"; do
  if brew list --cask "$cask" &>/dev/null; then
    warn "$cask already installed"
  else
    info "Installing $cask..."
    brew install --cask "$cask" || {
      # brew install --cask may fail if already installed but not detected by brew list
      warn "$cask already installed or install failed"
    }
  fi
done

# ---------------------------------------------------
# Stow dotfiles
# ---------------------------------------------------
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
info "Stowing dotfiles from $DOTFILES_DIR..."
cd "$DOTFILES_DIR"
stow .

info "Done! Restart your shell or run: source ~/.zshrc"
