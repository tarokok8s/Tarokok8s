# README

## Apply xkadm

```bash
$ kubectl apply -f https://raw.githubusercontent.com/tarokok8s/Tarokok8s/main/examples/xkadm/xkadm.yaml

# wait
$ kubectl wait -n kube-system pod -l app=kube-xkadm --for=condition=Ready --timeout=360s

# check k8s service
$ kubectl get -n kube-system service kube-xkadm 
NAME             TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                  AGE
kube-kadm        LoadBalancer   10.96.114.194   10.89.0.222   22100/TCP                16h
```

## Windows connect

```bash
# https://github.com/marchaesen/vcxsrv
1. 下載 Windows X server 免安裝包 (VcXsrv)
https://drive.google.com/drive/folders/1ZicyiUnAquiSjlk9eox-10_7RqJ1D9Xn

2. 解壓縮 VcXsrv.zip
3. 編輯 env.bat


```
