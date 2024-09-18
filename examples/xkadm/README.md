# README

## Apply xkadm

```bash
$ kubectl apply -f https://raw.githubusercontent.com/tarokok8s/Tarokok8s/main/examples/xkadm/xkadm.yaml

# wait
$ kubectl wait -n kube-system pod -l app=kube-xkadm --for=condition=Ready --timeout=360s

# check k8s service
# xkadm 提供兩種連線
# 1. LoadBalancer
# 2. HostPort (control-plane ip)
$ kubectl get -n kube-system service kube-xkadm 
NAME             TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                  AGE
kube-xkadm       LoadBalancer   10.96.114.194   10.89.0.223   22102/TCP                16h
```

## Windows connect

```bash
# https://github.com/marchaesen/vcxsrv
1. 下載 Windows X server 免安裝包 (VcXsrv)
https://drive.google.com/drive/folders/1ZicyiUnAquiSjlk9eox-10_7RqJ1D9Xn

2. 解壓縮 VcXsrv.zip
3. 編輯 env.bat，修改 serverIp 為 LoadBalancer ip 或 control-plane ip，其餘不變
@echo off

:: ssh profile
set username=bigred
set password=bigred
set serverIp=172.20.0.157
set serverPort=22102

4. 點擊 testEnv.bat
testEnv ok

等候  2 秒後，請按任何一個鍵繼續 ...

5. 點擊 startLxqt.bat

# xkadm
$ kubectl get node
kubectl get node
NAME                 STATUS   ROLES           AGE   VERSION
c30c-control-plane   Ready    control-plane   30h   v1.30.4
c30c-worker          Ready    <none>          30h   v1.30.4
c30c-worker2         Ready    <none>          30h   v1.30.4

$ cat ~/.kube/config
apiVersion: v1
clusters:
  - cluster:
      certificate-authority-data:
...


```
