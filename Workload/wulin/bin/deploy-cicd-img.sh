#!/bin/bash

VER="24.01"

sudo podman rmi 172.22.1.11:5000/alp.jkagent:${VER} &>/dev/null
[ "$?" == "0" ] && echo "172.22.1.11/alp.jkagent:${VER} removed"
sudo podman rmi alp.jkagent:${VER} &>/dev/null
[ "$?" == "0" ] && echo "alp.jkagent:${VER} removed"
sudo podman build --format=docker --build-arg="VER=3.19.1" --no-cache --force-rm --squash-all -t alp.jkagent:${VER} ~/wulin/images/jkagent &>/dev/null
[ "$?" == "0" ] && echo -e "alp.jkagent:${VER} image ok\n"
sudo podman tag localhost/alp.jkagent:${VER} 172.22.1.11:5000/alp.jkagent:${VER} &>/dev/null

sleep 5

sudo podman login --tls-verify=false 172.22.1.11:5000 -u bigred -p bigred &>/dev/null
[ "$?" != "0" ] && echo "docker registry not exist" && exit 1

im="172.22.1.11:5000/alp.jkagent:${VER}"
echo "[CI/CD images deploy]"
for n in $im
do
  sudo podman push --tls-verify=false $n &>/dev/null
  [ "$?" == "0" ] && echo "$n push ok"
done
sudo podman logout 172.22.1.11:5000 &>/dev/null
echo ""
