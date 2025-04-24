#!/bin/bash

set -e

# This script is for installing Caddy with Cloudflare DNS provider
# It will download the Caddy binary and set up a systemd service for it
# Make sure to run this script as root
# Usage: ./install.sh
if [ "$EUID" -ne 0 ]
then echo "Please run as root"
    exit
fi

CADDY_BINARY_PATH="/usr/local/bin/caddy"

if [ -f "$CADDY_BINARY_PATH" ]; then
    echo "It seems you already have Caddy installed at $CADDY_BINARY_PATH"
    echo "If you want to reinstall, please remove it first."
    exit 1
else
    wget "https://caddyserver.com/api/download?os=linux&arch=amd64&p=github.com%2Fcaddy-dns%2Fcloudflare" -O $CADDY_BINARY_PATH
    chmod +x $CADDY_BINARY_PATH
fi

echo "Downloading Caddy binary to $CADDY_BINARY_PATH"
wget "https://raw.githubusercontent.com/aroxu/caddy-setup/refs/heads/main/static/caddy.service" -O "/etc/systemd/system/caddy.service"
echo "Setting up systemd service for Caddy"
systemctl daemon-reload
echo "Adding caddy user..."
useradd caddy
mkdir /home/caddy
mkdir -p /etc/caddy
wget "https://raw.githubusercontent.com/aroxu/caddy-setup/refs/heads/main/static/Caddyfile" -O "/etc/caddy/Caddyfile"
mkdir -p /var/www/html

chown -R caddy:users /home/caddy
chown -R caddy:users /etc/caddy
chown -R caddy:users /var/www/html

echo 'Caddy installed successfully!'
echo 'You can now edit `/etc/caddy/Caddyfile`'
echo 'Then run `systemctl start caddy` to start the service'
echo 'You can also run `systemctl enable caddy` to start the service on boot'
echo 'If you want to start and enable the service, run `systemctl enable caddy --now`'
