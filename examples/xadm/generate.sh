#!/bin/bash

kubectl kustomize xadm/ | tee xadm.yaml &>/dev/null
