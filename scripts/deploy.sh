#!/bin/bash

set -e
set -x

# Instalar Node.js, npm, git e supervisor
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get update -y
apt-get install -y nodejs git supervisor

# Corrige permissões do projeto
chown -R ubuntu:ubuntu /home/ubuntu/vnn-cicd-ec2-lab5

# Entrar na pasta do projeto
cd /home/ubuntu/vnn-cicd-ec2-lab5

# Instalar dependências e buildar como ubuntu
sudo -u ubuntu npm install
sudo -u ubuntu NODE_OPTIONS=--openssl-legacy-provider npm run build

# Criar/atualizar arquivo do Supervisor
SUPERVISOR_CONF="/etc/supervisor/conf.d/vnn-react.conf"
cat <<EOF > $SUPERVISOR_CONF
[program:vnn-react]
directory=/home/ubuntu/vnn-cicd-ec2-lab5
command=npx serve -s build -l 3000
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
stderr_logfile=/var/log/vnn-react.err.log
stdout_logfile=/var/log/vnn-react.out.log
user=ubuntu
environment=NODE_OPTIONS="--openssl-legacy-provider",HOME="/home/ubuntu",USER="ubuntu"
EOF

# Atualizar Supervisor e reiniciar o app
supervisorctl reread
supervisorctl update
supervisorctl stop vnn-react || true
supervisorctl start vnn-react
