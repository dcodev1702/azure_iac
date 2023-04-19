#!/bin/bash

AZ_REPO=$(lsb_release -cs)
USER='dcodev-1702'

touch /home/$USER/.hushlogin &&
chown $USER:$USER /home/$USER/.hushlogin && 
sudo apt update && sudo apt upgrade -y &&
sudo apt install -y \
apt-transport-https \
ca-certificates \
curl \
software-properties-common \
gnupg \
net-tools \
wget \
gcc \
g++ \
rustc \
btop \
neofetch \
gdu \
nnn \
openjdk-11-jdk-headless \
python3-dev \
python3-pip &&

# Install Docker && Docker-Compose
curl -sSL https://raw.githubusercontent.com/docker/docker-install/master/install.sh | sudo bash &&
sudo usermod -aG docker $USER &&
curl -sSL https://raw.githubusercontent.com/dcodev1702/install_docker/main/install_docker-compose.sh | sudo bash &&


# Install PowerShell and Azure Modules
wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb" &&
sudo dpkg -i packages-microsoft-prod.deb &&
rm packages-microsoft-prod.deb &&
sudo apt-get update &&

if [ ! $(command -v pwsh) ]; then
    sudo apt-get install -y powershell
fi &&

sudo pwsh -c 'if (-not (Get-Module -Name Az -ListAvailable)) { Install-Module -Name Az -Scope AllUsers -Force }' &&
sudo pwsh -c 'if (-not (Get-Module -Name Az.ConnectedMachine -ListAvailable)) { Install-Module -Name Az.ConnectedMachine -Scope AllUsers -Force }' &&

# Install Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg &&
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list &&
sudo apt-get update && 
sudo apt-get install -y terraform &&

# Install Azure CLI
sudo mkdir -p /etc/apt/keyrings &&
curl -sLS https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null &&
sudo chmod go+r /etc/apt/keyrings/microsoft.gpg &&
echo "deb [arch=`dpkg --print-architecture` signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list &&
sudo apt-get update &&
sudo apt-get install -y azure-cli &&

# Update pip and install ansible and other popular python modules
sudo python3 -m pip install --upgrade pip &&
sudo python3 -m pip install ansible &&
sudo python3 -m pip install beautifulsoup4 &&
sudo python3 -m pip install arrow &&
sudo python3 -m pip install rainbowstream &&
sudo python3 -m pip install tensorflow &&

# Install Azure Bicep
su - $USER -c 'az bicep install' &&

# Setup JAVA_HOME ENV for user $USERNAME
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/' >> /home/$USER/.bashrc &&
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /home/$USER/.bashrc &&
source ~$USER/.bashrc
