#!/bin/bash

# Populated via variables.tf -> end_user variable
USERNAME="${VM_USERNAME}"

touch /home/$USERNAME/.hushlogin
chown $USERNAME:$USERNAME /home/$USERNAME/.hushlogin

# Setup directory structore for RSYSLOG 
# (Syslog Collector -> /etc/rsyslog.d/00-remotelog.conf)
sudo mkdir -p /var/log/remote/auth
sudo mkdir -p /var/log/remote/msg

sleep 5
sudo dnf update -y

sleep 60
# Install EPEL repository
sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

sudo dnf install -y \
     yum-utils \
     python3-devel \
     rsyslog \
     vim \
     git \
     java-11-openjdk-devel \
     btop \
     nnn


# Copy the rsyslog config files to their correct locations
sudo mv /home/$USERNAME/00-remotelog.conf /etc/rsyslog.d/00-remotelog.conf
sudo chown root:root /etc/rsyslog.d/00-remotelog.conf
sudo /sbin/restorecon -v /etc/rsyslog.d/00-remotelog.conf

sudo mv /home/$USERNAME/rsyslog.conf /etc/rsyslog.conf
sudo chown root:root /etc/rsyslog.conf
sudo /sbin/restorecon -v /etc/rsyslog.conf

sudo systemctl restart rsyslog.service

# Register the Microsoft RedHat repository
curl -sSL -O https://packages.microsoft.com/config/rhel/8/packages-microsoft-prod.rpm

# Register the Microsoft repository keys
sudo rpm -i packages-microsoft-prod.rpm

# Delete the repository keys after installing
sudo rm packages-microsoft-prod.rpm

sudo dnf install -y powershell
sudo pwsh -c Install-Module -Name Az -Scope AllUsers -Force
sudo pwsh -c Install-Module -Name Az.ConnectedMachine -Scope AllUsers -Force


# Install Azure CLI
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo dnf install -y https://packages.microsoft.com/config/rhel/8/packages-microsoft-prod.rpm
sudo dnf install -y azure-cli

# Install Terraform (RHEL 8)
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum install -y terraform

# Update pip and install ansible and other popular python modules
# sudo -H python3 -m pip install --upgrade pip
# sudo -H python3 -m pip install ansible
# sudo -H python3 -m pip install beautifulsoup4
# sudo -H python3 -m pip install arrow
# sudo -H python3 -m pip install rainbowstream
# sudo -H python3 -m pip install tensorflow

# Install Azure CLI Extensions
sudo su - $USERNAME -c 'az bicep install'

# Setup JAVA_HOME ENV for user $USERNAME
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk/' >> /home/$USERNAME/.bashrc
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /home/$USERNAME/.bashrc
sudo su - $USERNAME
source ~/$USERNAME/.bashrc

# Disabling Firewall until I can figure out how to get it to work with rsyslog and syslog-ng
sudo systemctl disable firewalld.service
sudo systemctl stop firewalld.service

# Setup Firewall to allow rsyslog (514 UDP) and (514 TCP)
# Be sure to further restrict as you deem necessary
# sudo firewall-cmd --new-zone=rsyslog-access --permanent
# sudo firewall-cmd --reload
# sudo firewall-cmd --zone=rsyslog-access --add-source=YOUR_WAN_IP/32 --permanent
# sudo firewall-cmd --zone=rsyslog-access --add-port=514/tcp  --permanent
# sudo firewall-cmd --zone=rsyslog-access --add-port=514/udp  --permanent

# Setup Firewall to allow syslog-ng (28330 UDP) and (28330 TCP)
# This DOES NOT FIX THE ISSUE when the firewall is enabled.
# When the firewall is disabled, the syslog-ng server works as expected.
# sudo firewall-cmd --permanent --zone=internal --add-rich-rule='rule family="ipv4" source address="127.0.0.1" port port="28330" protocol="tcp" accept'
# sudo firewall-cmd --permanent --zone=internal --add-rich-rule='rule family="ipv4" source address="127.0.0.1" port port="28330" protocol="udp" accept'
# sudo firewall-cmd --reload

#sudo firewall-cmd --add-rich-rule='rule syslog=ipv4 forward-port to-port=28330 protocol=tcp port=514' --permanent
#sudo firewall-cmd --add-rich-rule='rule syslog=ipv4 forward-port to-port=28330 protocol=udp port=514' --permanent

# firewall-cmd --permanent --zone=internal --add-forward-port=port=20514:proto=tcp:toaddr=127.0.0.1:toport=28330
# firewall-cmd --permanent --zone=internal --add-forward-port=port=514:proto=udp:toaddr=127.0.0.1:toport=28330
# firewall-cmd --reload
# firewall-cmd --list-forward-ports
     
# sudo firewall-cmd --add-port=514/udp --permanent
# sudo firewall-cmd --add-port=20514/tcp --permanent
# sudo firewall-cmd --add-port=28330/tcp --permanent
# sudo firewall-cmd --reload

sleep 1
sudo logger "Initialization installation script (init_script.sh) completed successfully."

sleep 2
sudo reboot
