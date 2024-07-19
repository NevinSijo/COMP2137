#!/bin/bash


echo "Updating package list and installing necessary software..."
sudo apt-get update
sudo apt-get install -y apache2 squid ufw


echo "Configuring network interface..."
cat <<EOF | sudo tee /etc/netplan/01-netcfg.yaml
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - 192.168.16.21/24
      gateway4: 192.168.16.2
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
EOF

sudo netplan apply


echo "Updating /etc/hosts file..."
sudo sed -i '/server1/d' /etc/hosts
echo "192.168.16.21 server1" | sudo tee -a /etc/hosts


echo "Enabling and starting apache2 and squid..."
sudo systemctl enable apache2
sudo systemctl start apache2
sudo systemctl enable squid
sudo systemctl start squid


echo "Configuring UFW firewall..."
sudo ufw allow in on eth0 to any port 22 proto tcp
sudo ufw allow in on any to any port 80 proto tcp
sudo ufw allow in on any to any port 3128 proto tcp
sudo ufw enable


create_user() {
  local user=$1
  local key=$2

  if id "$user" &>/dev/null; then
    echo "User $user already exists."
  else
    echo "Creating user $user..."
    sudo adduser --disabled-password --gecos "" $user
    echo "$user:password" | sudo chpasswd
  fi

  echo "Configuring SSH for $user..."
  sudo mkdir -p /home/$user/.ssh
  echo "$key" | sudo tee /home/$user/.ssh/authorized_keys
  sudo chown -R $user:$user /home/$user/.ssh
  sudo chmod 600 /home/$user/.ssh/authorized_keys
}

echo "Creating and configuring users..."
create_user dennis "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm"
for user in aubrey captain snibbles brownie scooter sandy perrier cindy tiger yoda; do
  create_user $user ""
done

echo "Adding dennis to sudoers..."
sudo usermod -aG sudo dennis

echo "Script completed successfully."
