#!/bin/bash
echo "Dont Forget to chmod run.sh and run it as sudo"
chmod +x menu/manage.sh
chmod +x menu/dockermenu.sh
chmod +x menu/managesystemctl.sh
chmod +x menu/managedocker.sh
chmod +x menu/install.sh
chmod +x scripts/c9-maker.sh
chmod +x scripts/ioncubesc.sh
chmod +x scripts/c9-deluser.sh
chmod +x scripts/c9-maker-docker.sh
chmod +x scripts/c9-deluser-docker.sh
chmod +x scripts/c9-status.sh
chmod +x scripts/c9-restart.sh
chmod +x scripts/schedule.sh
chmod +x scripts/firstinstall.sh
chmod +x scripts/c9-maker-dockermemlimit.sh
chmod +x run.sh
sudo apt update -y
sudo apt upgrade -y
sudo apt update -y
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.36.0/install.sh | bash
source ~/.profile
nvm install node
sudo apt install -y curl at git npm build-essential php php-exif php-gd php-mbstring php-curl php-mysqli php-json php-dom php-fpm python-pip python3-pip python python2.7 python-pyfiglet build-essential zip unzip unp unrar unrar-free unar p7zip dos2unix
pip install requests selenium colorama bs4 wget
systemctl start atd
sudo apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common docker docker.io docker-compose
sudo adduser c9users
sudo wget https://raw.githubusercontent.com/gvoze32/C9IDECoreDeploy/master/misc/dockeryml/docker-compose.yml -O /home/c9users/docker-compose.yml
sudo adduser c9usersmemlimit
sudo wget https://raw.githubusercontent.com/gvoze32/C9IDECoreDeploy/master/misc/dockeryml-memlimit/docker-compose.yml -O /home/c9usersmemlimit/docker-compose.yml
echo "blank" >> /home/c9users/.env
echo "blank" >> /home/c9usersmemlimit/.env

#Run as sudo or root user
read -p "Input User : " user
read -p "Input Password : " password
read -p "Input Port (Recomend Range : 1000-5000) : " port

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get update -y

#Create User
sudo adduser --disabled-password --gecos "" $user

#echo "$password" | passwd --stdin $user
sudo echo -e "$password\n$password" | passwd $user
mkdir -p /home/$user/my-projects
cd /home/$user/my-projects

#Get script to user directory
git clone https://github.com/c9/core.git /home/$user/c9sdk
sudo chown $user.$user /home/$user -R
sudo -u $user -H sh -c "cd /home/$user/c9sdk; scripts/install-sdk.sh"
sudo chown $user.$user /home/$user/ -R
sudo chmod 700 /home/$user/ -R
sudo cat > /lib/systemd/system/c9-$user.service << EOF
# Run:
# - systemctl enable c9
# - systemctl {start,stop,restart} c9
#
[Unit]
Description=c9
After=syslog.target network.target
[Service]
Type=simple
ExecStart=/usr/bin/node /home/${user}/c9sdk/server.js -a $user:$password --listen 0.0.0.0 -w /home/$user/my-projects
Environment=NODE_ENV=production PORT=$port
User=$user
Group=$user
UMask=0002
Restart=on-failure
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=c9
[Install]
WantedBy=multi-user.target
#End
EOF

sudo systemctl daemon-reload
sudo systemctl enable c9-$user.service
sudo systemctl restart c9-$user.service
sleep 10
sudo systemctl status c9-$user.service
