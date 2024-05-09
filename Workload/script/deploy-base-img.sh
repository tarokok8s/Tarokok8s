#!/bin/bash

VER="24.01"

if [ "$1" == "init" ]; then
   # How to force delete all pods, podman images and children
   sudo podman rm -f -a &>/dev/null && sudo podman system prune --all --force &>/dev/null
   sudo podman rmi -f --all &>/dev/null

   sudo podman pull mysql:8.3.0 &>/dev/null
   [ "$?" == "0" ] && echo "mysql:8.3.0 ok"
   sudo podman pull alpine:3.19.1 &>/dev/null
   [ "$?" == "0" ] && echo "alpine:3.19.1 ok"
   sudo podman pull wordpress:php8.3-apache &>/dev/null
   [ "$?" == "0" ] && echo "wordpress:php8.3-apache ok"

   echo ""
   sudo rm /usr/bin/mc &>/dev/null
   sudo curl https://dl.min.io/client/mc/release/linux-amd64/mc -o /usr/bin/mc
   [ "$?" == "0" ] && echo "mc download ok"
   sudo chmod +x /usr/bin/mc
   cp -rP /usr/bin/mc ~/wulin/images/base/

   echo ""
   sudo rm /usr/bin/rclone &>/dev/null
   curl https://rclone.org/install.sh | sudo bash
   [ "$?" == "0" ] && echo "rclone download ok"
   cp -rP /usr/bin/rclone ~/wulin/images/base/ 

   wget -nv https://github.com/stackrox/kube-linter/releases/download/v0.6.8/kube-linter-linux.tar.gz -O /tmp/kll.tar.gz &>/dev/null && \
   cd /tmp && tar zxvf kll.tar.gz &>/dev/null && rm kll.tar.gz && mv kube-linter ~/wulin/images/base/ && chmod +x ~/wulin/images/base/kube-linter
   echo "kube-linter ok"
   exit 0
fi

sudo podman rmi 172.22.1.11:5000/oracle.mysql:${VER} &>/dev/null
[ "$?" == "0" ] && echo "172.22.1.11:5000/oracle.mysql:${VER} removed"
sudo podman rmi oracle.mysql:${VER} &>/dev/null
[ "$?" == "0" ] && echo "oracle.mysql:${VER} removed"
sudo podman build --format=docker --build-arg="VER=8.3.0" --no-cache --force-rm --squash-all -t oracle.mysql:${VER} ~/wulin/images/mysql &>/dev/null
[ "$?" == "0" ] && echo -e "oracle.mysql:${VER} image ok\n"
sudo podman tag localhost/oracle.mysql:${VER} 172.22.1.11:5000/oracle.mysql:${VER} &>/dev/null

sudo podman rmi 172.22.1.11:5000/alp.base:${VER} &>/dev/null
[ "$?" == "0" ] && echo "172.22.1.11/alp.base:${VER} removed"
sudo podman rmi alp.base:${VER} &>/dev/null
[ "$?" == "0" ] && echo "alp.base:${VER} removed"
sudo podman build --format=docker --build-arg="VER=3.19.1" --no-cache --force-rm --squash-all -t alp.base:${VER} ~/wulin/images/base &>/dev/null
[ "$?" == "0" ] && echo -e "alp.base:${VER} image ok\n"
sudo podman tag localhost/alp.base:${VER} 172.22.1.11:5000/alp.base:${VER} &>/dev/null

sudo podman rmi quay.io/cloudwalker/alp.kadm &>/dev/null
[ "$?" == "0" ] && echo "quay.io/cloudwalker/alp.kadm removed"
sudo podman rmi alp.kadm &>/dev/null
[ "$?" == "0" ] && echo "alp.kadm removed"
sudo podman build --format=docker --build-arg="VER=24.01" --no-cache --force-rm --squash-all -t alp.kadm ~/wulin/images/kadm &>/dev/null
[ "$?" == "0" ] && echo -e "alp.kadm image ok\n"
sudo podman tag localhost/alp.kadm quay.io/cloudwalker/alp.kadm &>/dev/null

sudo podman rmi 172.22.1.11:5000/deb.wp:${VER} &>/dev/null
[ "$?" == "0" ] && echo "172.22.1.11/deb.wp:${VER} removed"
sudo podman rmi deb.wp:${VER} &>/dev/null
[ "$?" == "0" ] && echo "deb.wp:${VER} removed"
sudo podman build --format=docker --build-arg="VER=3.19.1" --no-cache --force-rm --squash-all -t deb.wp:${VER} ~/wulin/images/wordpress &>/dev/null
[ "$?" == "0" ] && echo -e "deb.wp:${VER} image ok\n"
sudo podman tag localhost/deb.wp:${VER} 172.22.1.11:5000/deb.wp:${VER} &>/dev/null

sudo podman rmi 172.22.1.11:5000/alpine.derby &>/dev/null
[ "$?" == "0" ] && echo "172.22.1.11:5000/alpine.derby removed"
sudo podman rmi quay.io/cloudwalker/alpine.derby &>/dev/null
[ "$?" == "0" ] && echo "quay.io/cloudwalker/alpine.derby removed"
sudo podman load < ~/wulin/images/derby.tar &>/dev/null
sudo podman tag quay.io/cloudwalker/alpine.derby 172.22.1.11:5000/alpine.derby &>/dev/null
[ "$?" == "0" ] && echo -e "alpine.derby image ok\n"

sleep 5

sudo podman login --tls-verify=false 172.22.1.11:5000 -u bigred -p bigred &>/dev/null
[ "$?" != "0" ] && echo "docker registry not exist" && exit 1

im="172.22.1.11:5000/alp.base:${VER} 172.22.1.11:5000/oracle.mysql:${VER} 172.22.1.11:5000/alpine.derby 172.22.1.11:5000/deb.wp:${VER}"
echo "[base images deploy]"
for n in $im
do
  sudo podman push --tls-verify=false $n &>/dev/null
  [ "$?" == "0" ] && echo "$n push ok"
done
sudo podman logout 172.22.1.11:5000 &>/dev/null
echo ""
