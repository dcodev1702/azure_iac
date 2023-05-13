#!/bin/bash

AZ_REPO=$(lsb_release -cs)
USERNAME=${1:-"dcodev-1702"}

touch /home/$USERNAME/.hushlogin
chown $USERNAME:$USERNAME /home/$USERNAME/.hushlogin

# Update and upgrade all packages without receiving any prompts
sed -i "s/#\$nrconf{kernelhints} = -1;/\$nrconf{kernelhints} = -1;/g" /etc/needrestart/needrestart.conf
sed -i "s/#\$nrconf{restart} = 'i';/\$nrconf{restart} = 'a';/g" /etc/needrestart/needrestart.conf 

export DEBIAN_FRONTEND=noninteractive 
sudo apt update && sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y 
sudo DEBIAN_FRONTEND=noninteractive apt install -y \
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
python3-pip

# Install Docker && Docker-Compose
curl -sSL https://raw.githubusercontent.com/docker/docker-install/master/install.sh | sudo bash 
sudo usermod -aG docker $USERNAME 
curl -sSL https://raw.githubusercontent.com/dcodev1702/install_docker/main/install_docker-compose.sh | sudo bash 


# Install PowerShell and Azure Modules
wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb" 
sudo dpkg -i packages-microsoft-prod.deb 
rm packages-microsoft-prod.deb 
sudo apt-get update 

# Install PowerShell and Azure Modules
sudo apt-get install -y powershell 
sudo pwsh -c Install-Module -Name Az -Scope AllUsers -Force
sudo pwsh -c Install-Module -Name Az.ConnectedMachine -Scope AllUsers -Force


# Install R
wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo gpg --dearmor -o /usr/share/keyrings/r-project.gpg 
echo "deb [signed-by=/usr/share/keyrings/r-project.gpg] https://cloud.r-project.org/bin/linux/ubuntu jammy-cran40/" | sudo tee -a /etc/apt/sources.list.d/r-project.list 
sudo apt update 
sudo DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends r-base 

# Install Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg 
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list 
sudo apt-get update  
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y terraform 

# Install Azure CLI
sudo mkdir -p /etc/apt/keyrings 
curl -sLS https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null 
sudo chmod go+r /etc/apt/keyrings/microsoft.gpg 
echo "deb [arch=`dpkg --print-architecture` signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list 
sudo apt-get update 
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y azure-cli 

# Update pip and install ansible and other popular python modules
sudo python3 -m pip install --upgrade pip 
sudo python3 -m pip install ansible 
sudo python3 -m pip install beautifulsoup4 
sudo python3 -m pip install arrow 
sudo python3 -m pip install rainbowstream 
sudo python3 -m pip install tensorflow 

# Install Azure Bicep
su - $USERNAME -c 'az bicep install' 

# Setup JAVA_HOME ENV for user $USERNAME
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/' >> /home/$USERNAME/.bashrc
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /home/$USERNAME/.bashrc
su - $USERNAME
source ~/$USERNAME/.bashrc

sleep 1
sudo logger "Initialization installation script (init_script.sh) completed successfully."

sleep 2
sudo reboot
