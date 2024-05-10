#!/bin/bash

VER="24.01"

# How to force delete all pods, podman images and children
sudo podman rm -f -a &>/dev/null && sudo podman system prune --all --force &>/dev/null
sudo podman rmi -f --all &>/dev/null

sudo podman pull mysql:8.3.0 &>/dev/null
[ "$?" == "0" ] && echo "mysql:8.3.0 ok"
sudo podman pull alpine:3.19.1 &>/dev/null
[ "$?" == "0" ] && echo "alpine:3.19.1 ok"
sudo podman pull wordpress:php8.3-apache &>/dev/null
[ "$?" == "0" ] && echo "wordpress:php8.3-apache ok"
sudo podman pull ubuntu:22.04 &>/dev/null
[ "$?" == "0" ] && echo "ubuntu:22.04 ok"

echo ""
sudo rm /usr/bin/mc &>/dev/null
sudo curl https://dl.min.io/client/mc/release/linux-amd64/mc -o /usr/bin/mc
[ "$?" == "0" ] && echo "mc download ok"
sudo chmod +x /usr/bin/mc
cp -rP /usr/bin/mc ~/wulin/images/base/
cp -rP /usr/bin/mc ~/wulin/images/jkagent/

sudo rm /usr/bin/rclone &>/dev/null
curl https://rclone.org/install.sh | sudo bash
[ "$?" == "0" ] && echo "rclone download ok"
cp -rP /usr/bin/rclone ~/wulin/images/base/ 
cp -rP /usr/bin/rclone ~/wulin/images/jkagent/ 

wget -nv https://github.com/stackrox/kube-linter/releases/download/v0.6.8/kube-linter-linux.tar.gz -O /tmp/kll.tar.gz &>/dev/null
cd /tmp && tar zxvf kll.tar.gz &>/dev/null && rm kll.tar.gz && mv kube-linter ~/wulin/images/base/  
chmod +x ~/wulin/images/base/kube-linter && cp -rP ~/wulin/images/base/kube-linter ~/wulin/images/jkagent/
echo "kube-linter ok"
