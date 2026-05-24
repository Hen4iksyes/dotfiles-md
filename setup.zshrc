#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.

echo "Setting up the DOTFILES"

# 1. Updating and Installing core packages
echo "Updating system..."
sudo apt update && sudo apt upgrade -y

echo "Installing packages..."
PACKAGES=(
    "vim"
    "gh"
    "curl"
    "wget"
    "btop"
    "neovim"
    "fzf"
    "eza"
    "zsh"
    "git"
    "build-essential"
    "python3"
    "python3-pip"
    "python3-venv"
)

sudo apt install -y "${PACKAGES[@]}"

# 2. Setup Dotfiles repository
DOTFILES_DIR="$HOME/DOTFILES2D"
REPO_URL="https://github.com/FrameBard/DOTFILES2D.git"

if [ -d "$DOTFILES_DIR" ]; then
    echo "📂 Updating dotfiles repository..."
    cd "$DOTFILES_DIR"
    git pull origin main
else
    echo "📥 Cloning dotfiles repository..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
fi

# 3. Installing Oh My Zsh (if not installed)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# Plugins for Zsh
echo "Setting up Zsh plugins..."

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# Powerlevel10k theme
P10K_DIR="$ZSH_CUSTOM/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

# 4. Creating symbolic links
echo "Creating symbolic links..."

create_symlink() {
    local source_file="$1"
    local target_file="$2"

    if [ -e "$target_file" ] || [ -L "$target_file" ]; then
        echo "Backing up $target_file -> ${target_file}.backup"
        mv "$target_file" "${target_file}.backup"
    fi
    
    ln -sf "$source_file" "$target_file"
    echo "Symbolic link created: $target_file"
}

# Izveido saiti uz .zshrc
create_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

# 5. Set Zsh as default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "🔄 Changing default shell to Zsh..."
    sudo chsh -s "$(which zsh)" "$USER"
fi

echo "---------------------------------------------------"
echo "✅ Setup.sh completed successfully!"
echo "Lūdzu, aizver un atver termināli vēlreiz vai izlogojies un ielogojies, lai izmaiņas stātos spēkā."