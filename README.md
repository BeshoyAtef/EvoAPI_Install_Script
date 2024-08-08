# EvoAPI_Install_Script
Bash script para instalação do Docker Compose e da Evolution API no Ubuntu.

**Intruções para utilização desses scripts **

1 - Crie uma pasta em seu diretório /home/user com o nome de evo e entre nela;

cd /home/user

mkdir evo

cd evo/

2 - Crie o arquivo do script de instalação do Docker e copie para ele o conteúdo do arquivo installDocker.sh que está nesse repositório;

nano installDocker.sh

clique com botão direito do mouse na tela do terminal com o arquivo em edição (cola o conteúdo)

ctrl + O (para salvar)

ctrl + X (para sair)

3 - Dê permissão de execução para o arquivo criado;

chmod a+x installDocker.sh

4 - Crie o arquivo do script de configuração da Evo API e copie para ele o conteúdo do arquivo configEvo.sh que está nesse repositório;

nano configEvo.sh

clique com botão direito do mouse na tela do terminal com o arquivo em edição (cola o conteúdo)

ctrl + O (para salvar)

ctrl + X (para sair)

5 - Dê permissão de execução para o arquivo criado;

chmod a+x configEvo.sh

6 - Execute o script de instalação do Docker;

./installDocker.sh

7 - Execute o script de configuração da Evo API.

./configEvo.sh

P.S.: Todos os comandos e scripts devem ser executados com usuário padrão.

P.S.2: Durante a execução do script de instalação do docker, será solicitada a senha de root para execução do gerenciador de pacotes.
