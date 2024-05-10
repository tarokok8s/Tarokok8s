#!/bin/bash

VER="24.01"

sudo podman rmi 172.22.1.11:5000/us.dt:${VER} &>/dev/null
[ "$?" == "0" ] && echo "172.22.1.11/us.dt:${VER} removed"
sudo podman build --format=docker --no-cache --force-rm --squash-all -t 172.22.1.11:5000/us.dt:${VER} ~/wulin/images/usdt &>/dev/null
[ "$?" == "0" ] && echo -e "172.22.1.11:5000/us.dt:${VER} image ok\n"

sudo podman rmi 172.22.1.11:5000/spark:${VER} &>/dev/null
[ "$?" == "0" ] && echo "172.22.1.11/spark:${VER} removed"
sudo podman build --format=docker --no-cache --force-rm --squash-all -t 172.22.1.11:5000/spark:${VER} ~/wulin/images/spark &>/dev/null
[ "$?" == "0" ] && echo -e "172.22.1.11:5000/spark:${VER} image ok\n"

sudo podman login --tls-verify=false 172.22.1.11:5000 -u bigred -p bigred &>/dev/null
[ "$?" != "0" ] && echo "docker registry not exist" && exit 1

im="172.22.1.11:5000/us.dt:${VER} 172.22.1.11:5000/spark:${VER}"
echo "[base images deploy]"
for n in $im
do
  sudo podman push --tls-verify=false $n &>/dev/null
  [ "$?" == "0" ] && echo "$n push ok"
done
sudo podman logout 172.22.1.11:5000 &>/dev/null
echo ""
