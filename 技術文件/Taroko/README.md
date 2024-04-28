# 認識 Talos Linux

## 前言
Kubernetes 實現了對 貨櫃 (Container) 的管理和操作的擴展性，但並沒有辦法管理它所依賴的基礎設施，不管 Kubernetes 在哪個平台建置，例如 AWS、GCE 等雲端商或是 VMware 虛擬化平台，依然需要作業系統。
縱使 Kubernetes 會定期打補丁和升級，但是底層作業系統的維護、更新、安全和操作容易被遺忘或忽視，並且會增加工程師同時管理 Linux 和 Kubernetes 的工作負擔。因此選擇合適的底層作業系統，可以很大程度上減少維護作業系統的工作量，減輕不及時更新的影響。

貨櫃 (Container) 專用作業系統設計的目的就是為了執行貨櫃，因此它執行的軟體和套件越少，漏洞也越少並採用唯讀根檔案系統，使得貨櫃 (Container) 專用作業系統更安全。

當前的貨櫃 (Container) 專用作業系統有:
1. Google 的 Container-Optimized OS 採用唯獨檔案系統，支援 SSH，但僅能在 GCP 使用。
2. AWS 的 Bottlerocket，支援 SSH 並且不可變更根檔案系統。
3. SUSE 的 SUSE Linux Enterprise Micro ，支援 SSH 並且不可變更根檔案系統。

## 為什麼使用 Talos Linux
Talos Linux 是極簡的作業系統，專門設計給 Kubernetes 使用，沒有 package manager，並且採用唯讀檔案系統(除了/var 與 /etc/目錄區是可寫的)。

Talos Linux 相較於其他的貨櫃專用作業系統最大的特色，它取消了所有 SSH 和終端機介面，通過 API(gRPC) 管理與存取 Talos Linux，以此限制不該做的事情，比如 umount 檔案系統。

透過 API 存取的作業系統可以進行大規模的操作和管理，並且與 Kubernetes 緊密結合，允許使用 API 升級 K8S 的版本。
Talos Linux 完全重寫 Linux Init 系統，只為做一件事 -- 啟動 Kubernetes。不能建立自定義的服務(服務只能由 Kubernetes 管理)，也進一步提高安全性（沒有 SSH，沒有終端機介面），降低維護成本，及降低了任何 CVE 的影響（檔案系統是不可變的）。

## Talos Linux Components
![image](https://github.com/tarokok8s/Tarokok8s/assets/62133915/90e47f3b-b624-48e2-a7fb-c99d10f397c8)

* apid
  - 與 Talos 互動時，直接與之互動的 gRPC API 端點由 apid 提供。 apid 充當所有元件互動的網關，並將請求轉發給 machined。
* containerd
  - 業界標準的貨櫃運作，強調簡單性、健壯性和可移植性。
* machined
  - Talos 傳統 Linux init-process 的替代品。專為運行 Kubernetes 而設計，不允許啟動任意用戶服務。
* kernel
  - Talos 附帶的 Linux 核心是根據核心自我保護專案（Kernel Self Protection Project）中概述的建議配置的。
* trustd
  - 要運行和操作 Kubernetes 集群，需要一定程度的信任。基於 「信任根 」的概念，trustd 是一個簡單的守護進程，負責在系統內建立信任
* udevd
  - eudev 是 Gentoo 对 udev（systemd 的 Linux 内核设备文件管理器）的分叉。它管理 /dev 中的设备节点，并在添加或删除设备时处理所有用户空间操作。要了解更多信息，请参阅 Gentoo Wiki。

## talosctl 運作流程
Talos 叢集中，Endpoints 負責與客戶端溝通，他可以是 DNS 主機名稱、負載平衡器或是一組 IP 清單等，建議將 Endpoints 直接或是透過負載平衡器指向 Controlplane 節點。
當客戶端對特定的 nodes(Controlplane 或是 worker)發送請求時，其中一台 Endpoint 將會自動將其代理至目標 nodes 上，同時如果有複數台 Endpoints，會由客戶端選擇其中一台，已次來達成高可用性。 
![image](https://github.com/tarokok8s/Tarokok8s/assets/62133915/b05f65d5-4567-4bbe-aee6-12223753b914)

[返回首頁](https://github.com/tarokok8s/Tarokok8s)
