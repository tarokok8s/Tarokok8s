# Reset Taroko K8s
## 在 Windows 執行以下命令

* 開啟 cmd，進入 VMTK2024v1.6.7 目錄
```
$ cd VMTK2024v1.6.7
```
* 將 Taroko K8s VM 都關機
```
$ k stop
```
* 確認 VM 都已關機
```
$ k list
[vm\]
ISO
k1.vmdk
k1m1
k1m2
k1m3
k1w1
k1w2
k1w3
k1w4
k1wk-0.vmdk
k1wk-1.vmdk
TKAdm
[VM runnig]
```
* 將 VM reset
```
$ k reset
reset yes/no = yes
```
