## Directpv
* Directpv 目的就是要來取代 hostpath，讓資料可以直接儲存到 Disk(SSD、Nvme)，可以提高 IO 效能。
* 主要提供給物件儲存、資料庫和需要高效能環境而設計的。

![image](https://hackmd.io/_uploads/HkAlpZxJC.png)

## 安裝 krew
* 安裝 krew
```
$ curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/download/v0.4.4/krew-linux_amd64.tar.gz"
      
$ tar zxvf krew-linux_amd64.tar.gz 

$ ./krew-linux_amd64 install krew 

$ echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' | sudo tee -a /etc/profile

$ rm krew-linux_amd64.tar.gz krew-linux_amd64 LICENSE
```
* 重新 login 後測試
```
$ kubectl krew
krew is the kubectl plugin manager.
You can invoke krew through kubectl: "kubectl krew [command]..."

Usage:
  kubectl krew [command]

Available Commands:
  help        Help about any command
  index       Manage custom plugin indexes
  info        Show information about an available plugin
  install     Install kubectl plugins
  list        List installed kubectl plugins
  search      Discover kubectl plugins
  uninstall   Uninstall plugins
  update      Update the local copy of the plugin index
  upgrade     Upgrade installed plugins to newer versions
  version     Show krew version and diagnostics

Flags:
  -h, --help      help for krew
  -v, --v Level   number for the log level verbosity

Use "kubectl krew [command] --help" for more information about a command.
```
## 安裝 Directpv

* 透過 krew 安裝 directpv plugin
```
$ kubectl krew install directpv
```
* 安裝 directpv 到 k8s
```
$ kubectl directpv install
```
* 顯示安裝完成畫面
```
$ kubectl directpv info
```
* directpv 運作流程

![image](https://hackmd.io/_uploads/SJ9_QNZyC.png)
```
# 可自行調整 controller 數量
$ kubectl -n directpv get all
NAME                              READY   STATUS    RESTARTS   AGE
pod/controller-58df549f48-d288q   3/3     Running   0          178m
pod/controller-58df549f48-mqr9g   3/3     Running   0          178m
pod/controller-58df549f48-s8xnd   3/3     Running   0          178m
pod/node-server-7zhz9             4/4     Running   0          178m
pod/node-server-f9l2k             4/4     Running   0          178m
pod/node-server-ljpgh             4/4     Running   0          178m
pod/node-server-zpww7             4/4     Running   0          178m

NAME                         DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/node-server   4         4         4       4            4           <none>          178m

NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/controller   3/3     3            3           178m

NAME                                    DESIRED   CURRENT   READY   AGE
replicaset.apps/controller-58df549f48   3         3         3       178m


$ kubectl get sc
NAME                 PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
directpv-min-io      directpv-min-io         Delete          WaitForFirstConsumer   true                   3h
```
* 檢查 DirectPV discover driver
```
$ kubectl directpv discover --nodes=cilium-w{1...3} --drives=sd{b...f}

 Discovered node 'cilium-w3' ✔
 Discovered node 'cilium-w1' ✔
 Discovered node 'cilium-w2' ✔

┌─────────────────────┬───────────┬───────┬────────┬────────────┬────────────────────┬───────────┬─────────────┐
│ ID                  │ NODE      │ DRIVE │ SIZE   │ FILESYSTEM │ MAKE               │ AVAILABLE │ DESCRIPTION │
├─────────────────────┼───────────┼───────┼────────┼────────────┼────────────────────┼───────────┼─────────────┤
│ 8:48$jHViBmYbA0Q... │ cilium-w1 │ sdd   │ 30 GiB │ -          │ QEMU QEMU_HARDDISK │ YES       │ -           │
│ 8:64$fW3WQftFoXo... │ cilium-w1 │ sde   │ 30 GiB │ -          │ QEMU QEMU_HARDDISK │ YES       │ -           │
│ 8:32$QQwAiXmZknC... │ cilium-w2 │ sdc   │ 30 GiB │ -          │ QEMU QEMU_HARDDISK │ YES       │ -           │
│ 8:48$NKcJ3N3TaE8... │ cilium-w2 │ sdd   │ 30 GiB │ -          │ QEMU QEMU_HARDDISK │ YES       │ -           │
│ 8:16$EHcAYec/Wa7... │ cilium-w3 │ sdb   │ 30 GiB │ -          │ QEMU QEMU_HARDDISK │ YES       │ -           │
│ 8:32$xrd5+hDeqje... │ cilium-w3 │ sdc   │ 30 GiB │ -          │ QEMU QEMU_HARDDISK │ YES       │ -           │
└─────────────────────┴───────────┴───────┴────────┴────────────┴────────────────────┴───────────┴─────────────┘

Generated 'drives.yaml' successfully.
```
* DirectPV add driver
```
$ cat drives.yaml
version: v1
nodes:
    - name: cilium-w1
      drives:
        - id: 8:64$fW3WQftFoXorsSbSQFO4UvvRi6OqxYkAe+Bxa/F41PY=
          name: sde
          size: 32212254720
          make: QEMU QEMU_HARDDISK
          select: "yes"
        - id: 8:48$jHViBmYbA0Q3zrvycywUHNO6SuGJCHclmeBVwHeHVXk=
          name: sdd
          size: 32212254720
          make: QEMU QEMU_HARDDISK
          select: "yes"
    - name: cilium-w2
      drives:
        - id: 8:48$NKcJ3N3TaE8/14aOuJeeqrjLmf3y4sgWFO3L0dm7EbQ=
          name: sdd
          size: 32212254720
          make: QEMU QEMU_HARDDISK
          select: "yes"
        - id: 8:32$QQwAiXmZknCllNQJfYoTt4AxcUIR4EsNl6MCJ5nJIQk=
          name: sdc
          size: 32212254720
          make: QEMU QEMU_HARDDISK
          select: "yes"
    - name: cilium-w3
      drives:
        - id: 8:32$xrd5+hDeqje4AlsYeMKeAu840b3FOoPnfZQ7ZsVrRYQ=
          name: sdc
          size: 32212254720
          make: QEMU QEMU_HARDDISK
          select: "yes"
        - id: 8:16$EHcAYec/Wa76OFbhSSWRMDf0jFdw+t+uKiWGv86tD5Q=
          name: sdb
          size: 32212254720
          make: QEMU QEMU_HARDDISK
          select: "yes"
```
* 加入 driver
```
$ kubectl directpv init --dangerous drives.yaml

 ███████████████████████████████████████████████████████████████████████████ 100%

 Processed initialization request '72cc955c-2b29-4618-9974-d70385305aa9' for node 'cilium-w1' ✔
 Processed initialization request 'fdc82163-3109-4e1e-8bdf-5a753f4db4b7' for node 'cilium-w2' ✔
 Processed initialization request '72e8fd44-408b-4cbc-a473-e745d5525828' for node 'cilium-w3' ✔

┌──────────────────────────────────────┬───────────┬───────┬─────────┐
│ REQUEST_ID                           │ NODE      │ DRIVE │ MESSAGE │
├──────────────────────────────────────┼───────────┼───────┼─────────┤
│ 72cc955c-2b29-4618-9974-d70385305aa9 │ cilium-w1 │ sdd   │ Success │
│ 72cc955c-2b29-4618-9974-d70385305aa9 │ cilium-w1 │ sde   │ Success │
│ fdc82163-3109-4e1e-8bdf-5a753f4db4b7 │ cilium-w2 │ sdc   │ Success │
│ fdc82163-3109-4e1e-8bdf-5a753f4db4b7 │ cilium-w2 │ sdd   │ Success │
│ 72e8fd44-408b-4cbc-a473-e745d5525828 │ cilium-w3 │ sdb   │ Success │
│ 72e8fd44-408b-4cbc-a473-e745d5525828 │ cilium-w3 │ sdc   │ Success │
└──────────────────────────────────────┴───────────┴───────┴─────────┘
```
* 列出 directpv 使用的 driver
```
$ kubectl directpv list drives
┌───────────┬──────┬────────────────────┬────────┬────────┬─────────┬────────┐
│ NODE      │ NAME │ MAKE               │ SIZE   │ FREE   │ VOLUMES │ STATUS │
├───────────┼──────┼────────────────────┼────────┼────────┼─────────┼────────┤
│ cilium-w1 │ sdd  │ QEMU QEMU_HARDDISK │ 30 GiB │ 30 GiB │ -       │ Ready  │
│ cilium-w1 │ sde  │ QEMU QEMU_HARDDISK │ 30 GiB │ 30 GiB │ -       │ Ready  │
│ cilium-w2 │ sdc  │ QEMU QEMU_HARDDISK │ 30 GiB │ 30 GiB │ -       │ Ready  │
│ cilium-w2 │ sdd  │ QEMU QEMU_HARDDISK │ 30 GiB │ 30 GiB │ -       │ Ready  │
│ cilium-w3 │ sdb  │ QEMU QEMU_HARDDISK │ 30 GiB │ 30 GiB │ -       │ Ready  │
│ cilium-w3 │ sdc  │ QEMU QEMU_HARDDISK │ 30 GiB │ 30 GiB │ -       │ Ready  │
└───────────┴──────┴────────────────────┴────────┴────────┴─────────┴────────┘
```
* 移除 Driver
```
$ kubectl directpv remove --drives=sdd --nodes=cilium-w1
Removing cilium-w1/sdd

$ kubectl directpv remove --drives=sde --nodes=cilium-w1
Removing cilium-w1/sde

$ kubectl directpv remove --drives=sdc --nodes=cilium-w2
Removing cilium-w2/sdc

$ kubectl directpv remove --drives=sdd --nodes=cilium-w2
Removing cilium-w2/sdd

$ kubectl directpv remove --drives=sdb --nodes=cilium-w3
Removing cilium-w3/sdb

$ kubectl directpv remove --drives=sdc --nodes=cilium-w3
Removing cilium-w3/sdc
```

## 測試 Directpv

* 建立 Directpv pvc
```
$ echo 'apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-directpv-nginx
spec:
  storageClassName: directpv-min-io
  accessModes: [ "ReadWriteOnce" ]
  resources:
    requests:
      storage: 5Gi' | kubectl apply -f -
```
* 只有建立 pvc 時，pv 還不會 Bound，要等 pod 出來才會產生 pv
```
$ kubectl get pvc
NAME                                       STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS      AGE
persistentvolumeclaim/pvc-directpv-nginx   Pending                                                                        directpv-min-io   6s
```
* 建立 pod
```
$ echo 'apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: deppod
spec:
  replicas: 1
  selector:
    matchLabels:
      app: deppod
  template:
    metadata:
      labels:
        app: deppod
    spec:
      containers:
      - name: nginx
        image: quay.io/cooloo9871/nginx
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 80
        volumeMounts:
        - mountPath: /usr/share/nginx/html
          name: html
      volumes:
        - name: html
          persistentVolumeClaim:
            claimName: pvc-directpv-nginx' | kubectl apply -f -
```
* 檢查 pvc,pv
```
$ kubectl get pvc,pv
NAME                                       STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS      AGE
persistentvolumeclaim/pvc-directpv-nginx   Bound    pvc-d1d0a330-e47d-44d5-8e68-73ead48e8e49   10Gi       RWO            directpv-min-io   85s

NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                                               STORAGECLASS      REASON   AGE
persistentvolume/pvc-d1d0a330-e47d-44d5-8e68-73ead48e8e49   5Gi       RWO            Delete           Bound    default/pvc-directpv-nginx                                          directpv-min-io            17s
```

* 產生 10G 檔案
```
$ kubectl get po
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-68bbdf4f57-vjpdg   1/1     Running   0          88s

# 確認 directpv 會限制實際硬碟空間
$ kubectl exec -it nginx-deployment-68bbdf4f57-vjpdg -- sh -c "dd count=10k bs=1M if=/dev/zero of=/usr/share/nginx/html/test10g.img"
dd: error writing '/usr/share/nginx/html/test10g.img': No space left on device
5121+0 records in
5120+0 records out
5368709120 bytes (5.4 GB, 5.0 GiB) copied, 70.3826 s, 76.3 MB/s
command terminated with exit code 1

# 最多只能產生 5G 檔案
$ kubectl exec -it nginx-deployment-68bbdf4f57-vjpdg -- ls -alh /usr/share/nginx/html/
total 5.0G
drwxr-xr-x 2 root root   25 May 29 08:51 .
drwxr-xr-x 1 root root    8 Apr 24 00:50 ..
-rw-r--r-- 1 root root 5.0G May 29 08:52 test10g.img
```



