#!/bin/bash
# Font colour variables
YL='\033[1;33m' # Yellow
RED='\033[1;31m' # Red
GR='\033[0;32m' # Green

# Script to Automate Docker Installation from the Official Repository
# Function to install Docker
install_docker() {
 echo -e "${YL}Installing Docker...${GR}"
 sudo apt-get remove docker docker-engine docker. io containerd runc -y
 sudo apt-get update
 sudo apt-get install ca-certificates curl gnupg lsb-release -y
 sleep 3
 sudo mkdir -p /etc/apt/keyrings
 curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker. gpg
 echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
 sleep 1
 sudo apt-get update
 sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
}

# Function to add a non-root user to the Docker group (optional)
setup_non_root_user() {
 echo -e "${GR}Adding the current user to the Docker group..."
 sudo usermod -aG docker $USER
 sleep 1
 newgrp docker
}

# Installation functions
install_docker
echo -e "${YL}Your Docker suite has been successfully installed and will always be up to date with the latest features, directly from the official repository."
echo -e "${RED}Remember to NEVER RUN CONTAINERS AS ROOT OR USING THE SUDO COMMAND. This is a serious security breach."
echo -e "${YL}Then run the Evolution API configuration script."

# Call function for non-root user
setup_non_root_user
