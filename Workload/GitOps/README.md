# GitOps

下載 Tarokok8s/Workload/GitOps

```bash
wget -qO - https://raw.githubusercontent.com/tarokok8s/Tarokok8s/main/Workload/GitOps/download | bash
```

進入 gitops 目錄

```
cd ~/gitops
```

Bootstrap Argo CD on the cluster

```
./bootstrap.sh
```