#!/bin/bash

VER="24.01"

sudo podman rmi 172.22.1.11:5000/alp.base:${VER} &>/dev/null
[ "$?" == "0" ] && echo "172.22.1.11:5000/alp.base:${VER} removed"
sudo podman build --format=docker --build-arg="VER=3.19.1" --no-cache --force-rm --squash-all -t 172.22.1.11:5000/alp.base:${VER} ~/wulin/images/base &>/dev/null
[ "$?" == "0" ] && echo -e "172.22.1.11:5000/alp.base:${VER} image ok\n"

sudo podman rmi 172.22.1.11:5000/oracle.mysql:${VER} &>/dev/null
[ "$?" == "0" ] && echo "172.22.1.11:5000/oracle.mysql:${VER} removed"
sudo podman build --format=docker --build-arg="VER=8.3.0" --no-cache --force-rm --squash-all -t 172.22.1.11:5000/oracle.mysql:${VER} ~/wulin/images/mysql &>/dev/null
[ "$?" == "0" ] && echo -e "172.22.1.11:5000/oracle.mysql:${VER} image ok\n"

sudo podman rmi 172.22.1.11:5000/alpine.derby:${VER} &>/dev/null
[ "$?" == "0" ] && echo "172.22.1.11:5000/alpine.derby:${VER} removed"
sudo podman rmi quay.io/cloudwalker/alpine.derby &>/dev/null
[ "$?" == "0" ] && echo "quay.io/cloudwalker/alpine.derby removed"
sudo podman load < ~/wulin/images/derby.tar &>/dev/null
sudo podman tag quay.io/cloudwalker/alpine.derby 172.22.1.11:5000/alpine.derby:${VER} &>/dev/null
[ "$?" == "0" ] && echo -e "172.22.1.11:5000/alpine.derby:${VER} image ok\n"

sleep 5

sudo podman login --tls-verify=false 172.22.1.11:5000 -u bigred -p bigred &>/dev/null
[ "$?" != "0" ] && echo "docker registry not exist" && exit 1

im="172.22.1.11:5000/oracle.mysql:${VER} 172.22.1.11:5000/alp.base:${VER} 172.22.1.11:5000/alpine.derby:${VER}"

for n in $im
do
  sudo podman push --tls-verify=false $n &>/dev/null
  [ "$?" == "0" ] && echo "$n push ok"
done
sudo podman logout 172.22.1.11:5000 &>/dev/null
echo ""
