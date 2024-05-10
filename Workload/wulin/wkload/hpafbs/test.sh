#!/bin/bash

trap 'kill $(jobs -p)' EXIT

while true; do
  curl 192.168.61.4:4000 > /dev/null 2>&1
done &

while true; do
  curl 192.168.61.4:4000 > /dev/null 2>&1
done &

while true; do
  sleep 2
  clear
  kubectl get hpa hpa-fbs
  echo "關閉請按 ctrl-c"
done

