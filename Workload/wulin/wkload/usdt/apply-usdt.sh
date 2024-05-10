#!/bin/bash

kubectl get job/job-dtp-bucket &>/dev/null
[ "$?" == "0" ] && echo "job/job-dtp-bucket exist" && exit 1
kubectl get pods -n kube-system | grep 'dtm1' &>/dev/null
[ "$?" == "0" ] && echo "dtm1 exist" && exit 1

mc ls mios/dtp &>/dev/null 
if [ "$?" == "0" ]; then
   echo "ok"
   mc rm -r --force mios/dtp &>/dev/null
   mc rb mios/dtp &>/dev/null
   [ "$?" == "0" ] && echo "mios/dtp removed"
fi

kubectl apply -f ~/wulin/wkload/usdt/job-dtp-bucket.yaml

echo -n "waiting $n "
while true; do
  status=$(kubectl get job/job-dtp-bucket -n kube-system -o jsonpath='{.status.conditions[0].type}')
  echo "$status" | grep -qi 'Complete' && break
  echo "$status" | grep -qi 'Failed' && echo "$n error" && exit 1
  sleep 5 && echo -n "."
done

echo 
kubectl apply -f ~/wulin/wkload/usdt/svc-dt.yaml
sleep 60
kubectl apply -f ~/wulin/wkload/usdt/pod-dtm1.yaml
sleep 60
kubectl apply -f ~/wulin/wkload/usdt/pod-dtm2.yaml
sleep 30
kubectl apply -f ~/wulin/wkload/usdt/pod-dtw1.yaml
sleep 30
kubectl apply -f ~/wulin/wkload/usdt/pod-dtw2.yaml
echo "deploy usdt ok"
