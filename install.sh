#!/bin/bash

# Set destination paths
BIN_DIR="/usr/local/bin"
CONFIG_DIR="$HOME/.config/gitlog"
MAN_DIR="/usr/local/share/man/man1"
COMPLETION_DIR="/usr/share/bash-completion/completions"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
	echo "Please run as root to install the binaries and man pages"
	exit 1
fi

# Create configuration directory if it doesn't exist
echo "Creating configuration directory at $CONFIG_DIR..."
mkdir -p "$CONFIG_DIR/repositories"

# Copy the main script to /usr/local/bin
echo "Installing gitlog script to $BIN_DIR..."
install -m 755 bin/gitlog "$BIN_DIR/gitlog"

# Copy configuration files to ~/.config/gitlog
echo "Copying configuration files..."
install -m 644 config/setting.conf "$CONFIG_DIR/setting.conf"
cp -r config/repositories/* "$CONFIG_DIR/repositories/"

# Install man page to /usr/local/share/man/man1
echo "Installing man page..."
install -m 644 share/man/man1/gitlog.1 "$MAN_DIR/gitlog.1"
mandb # Update the man database

# Install completion script for Bash
echo "Installing completion script..."
install -m 644 share/bash-completion/completions/gitlog "$COMPLETION_DIR/gitlog"

echo "Installation complete. You can now use the 'gitlog' command."
