#!/bin/bash

talosctl machineconfig patch /home/bigred/k1/v1.6.7/controlplane.yaml --patch @/home/bigred/k1/v1.6.7/k1m1.patch --output /home/bigred/k1/v1.6.7/k1m1.yaml
[ "$?" == "0" ] && echo "k1m1.yaml patch ok"
talosctl machineconfig patch /home/bigred/k1/v1.6.7/worker.yaml --patch @/home/bigred/k1/v1.6.7/k1w1.patch --output /home/bigred/k1/v1.6.7/k1w1.yaml
[ "$?" == "0" ] && echo "k1w1.yaml patch ok"
talosctl machineconfig patch /home/bigred/k1/v1.6.7/worker.yaml --patch @/home/bigred/k1/v1.6.7/k1w2.patch --output /home/bigred/k1/v1.6.7/k1w2.yaml
[ "$?" == "0" ] && echo "k1w2.yaml patch ok"
