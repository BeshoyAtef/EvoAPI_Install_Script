#!/bin/bash
# Variáveis cores de fontes
YL='\033[1;33m'      # Yellow
RED='\033[1;31m'         # Red
GR='\033[0;32m'        # Green

# Script para Automação da Instalação da Evolution API
# Prompt para variáveis de configuração
read -p "Insira uma secret key de acesso. Utilize pelo menos 30 caracteres entre letras maiúsculas, minúsculas e números. Não utilize caracteres especiais. (ex: Bgk3cyNatd8AJNCHJDXI9SfADJCGFa7JXUSn7jSXKM9tSJC): " AUTHENTICATION_API_KEY
echo -e "${YL}Sua chave de autenticação ficou definida como: $AUTHENTICATION_API_KEY"
echo -e "${RED}Salve-a, de preferência em um cofre de senhas como o BitWarden.${GR}"
read -p "Digite o nome do domínio (ex: example.com): " DOMAIN_NAME
read -p "Digite o subdomínio (ex: evo): " SUBDOMAIN
read -p "Digite o e-mail para certificados SSL (ex: user@example.com): " SSL_EMAIL
read -p "Digite o código UTC para fuso horário (ex: America/Sao_Paulo): " GENERIC_TIMEZONE
echo -e "${YL}Fuso horário padrão definido como: $GENERIC_TIMEZONE"
echo -e "${YL}Sua chave de autenticação ficou definida como: $AUTHENTICATION_API_KEY"
echo -e "${RED}Salve-a, de preferência em um cofre de senhas como o BitWarden.${GR}"


# Função para criar o arquivo .env
create_env_file() {
  echo -e "${YL}Criando arquivo .env...${GR}"
  cat <<EOL > .env

AUTHENTICATION_API_KEY=$AUTHENTICATION_API_KEY

DOMAIN_NAME=${DOMAIN_NAME}

SUBDOMAIN=${SUBDOMAIN}

GENERIC_TIMEZONE=${GENERIC_TIMEZONE}

SSL_EMAIL=${SSL_EMAIL}

EOL
}


# Função para criar o arquivo docker-compose.yml
create_docker_compose_file() {
  echo -e "Criando docker-compose.yml..."
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
      - traefik.http.routers.evolution_api.rule=Host(`${SUBDOMAIN}.${DOMAIN_NAME}`)
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


# Função para criar os volumes do Docker
create_docker_volumes() {
  echo -e "Criando volume do Docker..."
  docker volume create traefik_data
  sleep 1
}

# Função para iniciar a Evo API
start_evo() {
  echo -e "${YL}Iniciando Evolution API..."
  docker compose up -d
  sleep 10
}

# Funções de arquivo
create_env_file
sleep 1

create_docker_compose_file
sleep 1

# Criar volumes docker
create_docker_volumes

# Iniciar Evo
start_evo

echo -e "${YL}A instalação da Evolution API foi concluída. Acesse em: https://${SUBDOMAIN}.${DOMAIN_NAME}/manager"
echo -e "${RED}Caso você tenha setado portas diferentes no bind, utilize a URL:Porta (ex: https://evo.dominio.com.br:444)"
