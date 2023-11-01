#!/bin/bash

# Directory path
SSH_DIR="$HOME/.ssh"

# Check if .ssh directory exists
if [ ! -d "$SSH_DIR" ]; then
    # If it doesn't exist, create it with appropriate permissions
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
fi

# Check if the config file exists within the .ssh directory
CONFIG_FILE="$SSH_DIR/config"
if [ ! -f "$CONFIG_FILE" ]; then
    # If it doesn't exist, create it with appropriate permissions
    touch "$CONFIG_FILE"
    chmod 600 "$CONFIG_FILE"
fi

cat << EOF >> ~/.ssh/config

Host ${hostname}
   HostName ${hostname}
   User ${user}
   IdentityFile ${identityfile}
EOF
