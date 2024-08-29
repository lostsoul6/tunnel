#!/bin/bash

# Download the latest tunnel script
echo "Downloading the latest tunnel script..."
wget https://raw.githubusercontent.com/lostsoul6/tunnel/main/tunnel.sh -O /usr/local/bin/tunnel.sh

# Make the new script executable
chmod +x /usr/local/bin/tunnel.sh

# Execute the new script
echo "Executing the new tunnel script..."
sudo /usr/local/bin/tunnel.sh
