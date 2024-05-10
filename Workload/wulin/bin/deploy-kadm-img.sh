#!/bin/bash

VER="24.01"

sudo podman rmi quay.io/cloudwalker/alp.kadm &>/dev/null
[ "$?" == "0" ] && echo "quay.io/cloudwalker/alp.kadm removed"
sudo podman build --format=docker --build-arg="VER=24.01" --no-cache --force-rm --squash-all -t quay.io/cloudwalker/alp.kadm ~/wulin/images/kadm &>/dev/null
[ "$?" != "0" ] && echo "quay.io/cloudwalker/alp.kadm image error" && exit 1 
echo -e "quay.io/cloudwalker/alp.kadm image ok\n"

sudo podman rmi quay.io/cloudwalker/alp.s3fs &>/dev/null
[ "$?" == "0" ] && echo "quay.io/cloudwalker/alp.s3fs removed"
sudo podman build --build-arg VER=${VER} --format=docker --no-cache --force-rm  --squash -t quay.io/cloudwalker/alp.s3fs ~/wulin/images/s3fs/ &>/dev/null
[ "$?" == "0" ] && echo -e "quay.io/cloudwalker/alp.s3fs image ok\n"

sudo podman rmi docker.io/library/registry:2 &>/dev/null
[ "$?" == "0" ] && echo "docker.io/library/registry:2 removed"
sudo podman pull docker.io/library/registry:2 &>/dev/null
sudo podman tag docker.io/library/registry:2 quay.io/cloudwalker/registry:2 &>/dev/null
[ "$?" == "0" ] && echo -e "quay.io/cloudwalker/registry:2 image ok\n"

echo ""
sudo podman login quay.io

sudo podman push quay.io/cloudwalker/alp.kadm
[ "$?" == "0" ] && sudo podman rmi quay.io/cloudwalker/alp.kadm

sudo podman push quay.io/cloudwalker/alp.s3fs
[ "$?" == "0" ] && sudo podman rmi quay.io/cloudwalker/alp.s3fs

sudo podman push quay.io/cloudwalker/registry:2
[ "$?" == "0" ] && sudo podman rmi quay.io/cloudwalker/registry:2

sudo podman logout quay.io
