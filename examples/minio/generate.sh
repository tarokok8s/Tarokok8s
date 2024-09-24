#!/bin/bash

kubectl kustomize minio/ | tee minio.yaml &>/dev/null
