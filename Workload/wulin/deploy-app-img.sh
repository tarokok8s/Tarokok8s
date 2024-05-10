#!/bin/bash

export ver="24.01"
#im="alp.fbs:${ver} alp.fbsro:${ver} alp.sshd:${ver} alp.goweb:${ver} alp.bind:${ver} alp.fbs-s3fs:${ver}"
im="alp.fbs:${ver} alp.fbsro:${ver} alp.sshd:${ver} alp.goweb:${ver} alp.bind:${ver}"

sudo podman rmi $im &>/dev/null

echo "[APP images build]"
sudo podman build --build-arg VER=$ver --format=docker --no-cache --force-rm  --squash -t alp.fbs:${ver} ~/wulin/images/fbs/ &>/dev/null && echo "alp.fbs:${ver} image ok"
sudo podman build --build-arg VER=$ver --format=docker --no-cache --force-rm  --squash -t alp.fbsro:${ver} ~/wulin/images/fbsro/ &>/dev/null && echo "alp.fbsro:${ver} image ok"
sudo podman build --build-arg VER=$ver --format=docker --no-cache --force-rm  --squash -t alp.sshd:${ver} ~/wulin/images/sshd/ &>/dev/null && echo "alp.sshd:${ver} image ok"
sudo podman build --build-arg VER=$ver --format=docker --no-cache --force-rm  --squash -t alp.goweb:${ver} ~/wulin/images/goweb/ &>/dev/null && echo "alp.goweb:${ver} image ok"
sudo podman build --build-arg VER=$ver --format=docker --no-cache --force-rm  --squash -t alp.bind:${ver} ~/wulin/images/bind/ &>/dev/null && echo "alp.bind:${ver} image ok"

sudo podman login --tls-verify=false 172.22.1.11:5000 -u bigred -p bigred &>/dev/null
[ "$?" != "0" ] && echo "docker registry not exist" && exit 1
echo ""
echo "[APP images deploy]"
for n in $im
do
  sudo podman tag $n "172.22.1.11:5000/$n" &>/dev/null
  sudo podman push --tls-verify=false "172.22.1.11:5000/$n" &>/dev/null
  [ "$?" == "0" ] && echo "172.22.1.11:5000/$n push ok"
  sudo podman rmi "172.22.1.11:5000/$n" &>/dev/null
done
sudo podman logout 172.22.1.11:5000 &>/dev/null
echo ""

# curl -X GET -s -u bigred:bigred http://172.22.1.11:5000/v2/_catalog | jq ".repositories[]"
