#!/bin/bash

kubectl kustomize juicefs/ | tee juicefs.yaml &>/dev/null
kubectl kustomize redis/ | tee redis.yaml &>/dev/null
