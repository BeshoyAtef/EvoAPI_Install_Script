#!/bin/bash
# Font colour variables
YL='\033[1;33m' # Yellow
RED='\033[1;31m' # Red
GR='\033[0;32m' # Green

# Script for Automation of Evolution API Installation
# Prompt for configuration variables
read -p "Enter an access secret key. Use at least 30 characters between uppercase, lowercase and numbers. Do not use special characters (e.g. Bgk3cyNatd8AJNCHJDXI9SfADJCGFa7JXUSn7jSXKM9tSJC): " AUTHENTICATION_API_KEY
echo -e "${YL}Your authentication key is set to: $AUTHENTICATION_API_KEY"
echo -e "${RED}Save it, preferably in a password vault like BitWarden. ${GR}"
read -p "Enter the domain name (e.g. example. com): " DOMAIN_NAME
read -p "Enter the subdomain (e.g. evo): " SUBDOMAIN
read -p "Enter the email for SSL certificates (e.g. user@example.com): " SSL_EMAIL
echo -e "${YL}Your authentication key is set to: $AUTHENTICATION_API_KEY"
echo -e "${RED}Save it, preferably in a password vault like BitWarden.${GR}"


# Function to create the .env file
create_env_file() {
 echo -e "${YL}Creating .env file...${GR}"
 cat <<EOL > .env

AUTHENTICATION_API_KEY=$AUTHENTICATION_API_KEY

DOMAIN_NAME=${DOMAIN_NAME}

SUBDOMAIN=${SUBDOMAIN}

SSL_EMAIL=${SSL_EMAIL}

EOL
}


# Function to create docker-compose.yml file
create_docker_compose_file() {
 echo -e "Creating docker-compose.yml..."
 cat <<EOL > docker-compose.yml
services:
 traefik:
 image: "traefik"
 restart: always
 command:
      - "--api=true"
      - "--api.insecure=true"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.web.http.redirections.entryPoint.to=websecure"
      - "--entrypoints.web.http.redirections.entrypoint.scheme=https"
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.mytlschallenge.acme.tlschallenge=true"
      - "--certificatesresolvers.mytlschallenge.acme.email=${SSL_EMAIL}"
      - "--certificatesresolvers.mytlschallenge.acme.storage=/letsencrypt/acme.json"
 ports:
      - "80:80"
      - "443:443"
 volumes:
      - traefik_data:/letsencrypt
      - /var/run/docker.sock:/var/run/docker.sock:ro


  evolution-api:
 container_name: evolution_api
 image: atendai/evolution-api
 restart: always
 ports:
      - "8080:8080"
 env_file:
      - .env
 volumes:
      - evolution_store:/evolution/store
      - evolution_instances:/evolution/instances
 labels:
      - traefik.enable=true
      - traefik.http.routers.evolution_api.rule=Host("${SUBDOMAIN}.${DOMAIN_NAME}")
      - traefik.http.routers.evolution_api.tls=true
      - traefik.http.routers.evolution_api.entrypoints=web,websecure
      - traefik.http.routers.evolution_api.tls.certresolver=mytlschallenge
      - traefik.http.middlewares.evolution_api.headers.SSLRedirect=true
      - traefik.http.middlewares.evolution_api.headers.STSSeconds=315360000
      - traefik.http.middlewares.evolution_api.headers.browserXSSFilter=true
      - traefik.http.middlewares.evolution_api.headers.contentTypeNosniff=true
      - traefik.http.middlewares.evolution_api.headers.forceSTSHeader=true
      - traefik.http.middlewares.evolution_api.headers.SSLHost=${DOMAIN_NAME}
      - traefik.http.middlewares.evolution_api.headers.STSIncludeSubdomains=true
      - traefik.http.middlewares.evolution_api.headers.STSPreload=true
      - traefik.http.routers.evolution_api.middlewares=evolution_api@docker
volumes:
 evolution_store:
 evolution_instances:
 traefik_data:
 external: true 
EOL
}


# Function to create Docker volumes
create_docker_volumes() {
 echo -e "Creating Docker volume..."
 docker volume create traefik_data
 sleep 1
}

# Function to start the Evo API
start_evo() {
 echo -e "${YL}Starting Evolution API..."
 docker compose up -d
 sleep 10
}

# File functions
create_env_file
sleep 1

create_docker_compose_file
sleep 1

# Create docker volumes
create_docker_volumes

# Start Evo
start_evo

echo -e "${YL}The Evolution API installation has been completed. Log in at: https://${SUBDOMAIN}.${DOMAIN_NAME}/manager"
echo -e "${RED}If you have set different ports in the bind, use the URL:Port (e.g. https://evo.dominio.com.br:444)"
