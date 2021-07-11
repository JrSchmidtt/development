#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

# Add Docker's GPG key and configure the repository
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Perform the installation of the required software.
apt -y update
apt -y --no-install-recommends install iputils-ping tar zip unzip make gcc g++ gdb python docker-ce docker-ce-cli containerd.io

curl -OL https://golang.org/dl/go1.16.5.linux-amd64.tar.gz
tar xvf go1.16.5.linux-amd64.tar.gz -C /usr/local
chown -R root:root /usr/local/go
rm -rf go1.16.5.linux-amd64.tar.gz

# Install delve for Go debugging support.
GOBIN=/usr/local/go/bin go get github.com/go-delve/delve/cmd/dlv

# Configure the vagrant user to have permission to use Docker.
usermod -aG docker vagrant

# Ensure docker is started and will continue to start up.
systemctl enable docker --now

# Install ctop for easy container metrics visualization.
curl -fsSL https://github.com/bcicen/ctop/releases/download/v0.7.1/ctop-0.7.1-linux-amd64 -o /usr/local/bin/ctop
chmod +x /usr/local/bin/ctop

# create config directory
mkdir -p /etc/pterodactyl /var/log/pterodactyl
cp /etc/ssl/pterodactyl/root_ca.pem /etc/ssl/certs/mkcert.pem

# ensure permissions are set correctly
chown -R vagrant:vagrant /home/vagrant /etc/pterodactyl /var/log/pterodactyl

# map pterodactyl.test to the host system
echo "$(ip route | grep default | cut -d' ' -f3,3) pterodactyl.test" >> /etc/hosts

cat >> /etc/profile <<EOF
export PATH=$PATH:/usr/local/go/bin
EOF
