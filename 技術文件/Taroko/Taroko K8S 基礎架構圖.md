# Taroko K8s 基礎架構圖

* 在 Windows 使用 VMware Workstation 進行 VM 建置
* 建立一台 Alpine 虛擬機作為外部管理主機(tkadm)
* 建立三台 Talos Linux 虛擬機作為 K8s 節點
* tkadm 設置兩個虛擬網路介面
  - 其一設為 NAT 使其能夠連接外部網路
  - 其一作為 Host-only 內部網路的 Gateway，讓 Tarlos K8s 叢集的節點進行 IP forward，使他們能夠上網

![未命名](https://github.com/tarokok8s/Tarokok8s/assets/62133915/96872c9f-3cf0-4025-9655-a5e0bfe652f2)

## Windows 實體機最低資源規格

| Server CPU | Server RAM | Server Disk |
| -------- | -------- | -------- |
| 8+ Core     | 32 GB     | 1T | 


[返回首頁](https://github.com/tarokok8s/Tarokok8s)
