#!/bin/bash

# Define the path for the scripts
TUNNEL_SCRIPT_PATH="/usr/local/bin/tunnel.sh"
UPDATE_SCRIPT_PATH="/usr/local/bin/update_script.sh"

# Download the tunnel script
echo "Downloading the latest tunnel script..."
wget https://raw.githubusercontent.com/lostsoul6/tunnel/main/tunnel.sh -O $TUNNEL_SCRIPT_PATH

# Download the update script
echo "Downloading the update script..."
wget https://raw.githubusercontent.com/lostsoul6/tunnel/main/update_script.sh -O $UPDATE_SCRIPT_PATH

# Make the scripts executable
chmod +x $TUNNEL_SCRIPT_PATH
chmod +x $UPDATE_SCRIPT_PATH

# Execute the tunnel script
echo "Executing the tunnel script..."
sudo $TUNNEL_SCRIPT_PATH
