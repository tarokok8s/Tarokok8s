#!/bin/bash

name='juicefs'
kubectl kustomize juicefs/ | tee ${name}.yaml &>/dev/null
