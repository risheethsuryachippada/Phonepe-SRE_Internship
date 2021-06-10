#!/bin/bash -eux
echo vagrant
echo vagrant
sudo apt-get install adduser
sleep 1
echo vagrant
sleep 10
echo y 
# Add vagrant user to sudoers.
echo "packer        ALL=(ALL)       ALL" >> /etc/sudoers
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

# Disable daily apt unattended updates.
echo 'APT::Periodic::Enable "0";' >> /etc/apt/apt.conf.d/10periodic

apt update
apt upgrade -y

