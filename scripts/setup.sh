#!/bin/bash
set -e

echo "==> Installing Docker..."
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

echo "==> Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

echo "==> Configuring UFW firewall..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from 192.168.0.0/16   # LAN
sudo ufw allow from 100.64.0.0/10   # Tailscale
sudo ufw allow ssh
sudo ufw --force enable

echo "==> Disabling lid-close suspend..."
sudo sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=ignore/' /etc/systemd/logind.conf
sudo sed -i 's/#HandleLidSwitchExternalPower=suspend/HandleLidSwitchExternalPower=ignore/' /etc/systemd/logind.conf
sudo systemctl restart systemd-logind

echo "==> Creating media directories..."
mkdir -p ~/media/{movies,tv,downloads}
mkdir -p ~/homestudio/config

echo ""
echo "Done. Log out and back in for Docker group to take effect."
echo "Then: cp .env.example .env && nano .env && docker compose up -d"
