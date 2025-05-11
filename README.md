# EvoAPI_Install_Script
Bash script for installing Docker Compose and the Evolution API on Ubuntu.

PREREQUISITE: TO USE THESE SCRIPTS, YOU MUST ALREADY HAVE A DNS ENTRY POINTING SUBDOMINIO.DOMINIO.COM.BR TO THE ADDRESS OF YOUR EVOLUTION API SERVER.

**Instructions for using these scripts **

1 - Create a folder in your /home/user directory with the name evo and enter it;

cd /home/user

mkdir evo

cd evo/

2 - Create the Docker installation script file and copy the contents of the installDocker.sh file in this repository into it;

nano installDocker.sh

right-click on the terminal screen with the file being edited (paste the contents)

ctrl + O (to save)

ctrl + X (to exit)

3 - Give the created file execute permission;

chmod a+x installDocker.sh

4 - Create the Evo API configuration script file and copy the contents of the configEvo.sh file in this repository into it;

nano configEvo.sh

right-click on the terminal screen with the file being edited (paste the contents)

ATTENTION, IMPORTANT! IF YOU ALREADY HAVE A SERVICE USING PORTS 80 AND 443 (SOME WEBSERVER OR REVERSE PROXY), YOU WILL NEED TO CONFIGURE THE BIND PORT IN THE docker-compose.yaml FILE.
You can use, for example:

ports:

      - "81:81"
      
      - "444:444"
      

ALSO TAKING CARE TO CHANGE THE COMMANDS IN THE TRAEFIK SERVICE:

 - "--entrypoints.web.address=:81"
  
 - "--entrypoints.websecure.address=:444"

Translated with DeepL.com (free version)
