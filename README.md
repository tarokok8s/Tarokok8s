# Taroko(太魯閣) Kubernetes

## 簡介

### 1. 目的

Taroko Kubernetes 是一個專為全端開發工程師和全端資料工程師設計的最佳實作練功坊。它的設計旨在簡化基礎設施的部署和管理，讓使用者可以更專注於前後端開發和資料分析的工作，而不必花費過多時間在環境設定和維護上。

在 Taroko Kubernetes 中可以一鍵啟動 2 種不同架構的工作平台，主要分別會給全端開發工程師和全端資料分析工程師使用，讓不同需求的使用者能夠快速在對應的工作平台上部署和維運貨櫃化應用程式 (Containerized Applications)，並能夠有更多時間可以專注於創造價值和解決問題。

### 2. 組成

預設情況下，系統將擁有四台虛擬機（VM），會在 Windows 環境下使用 VMware Workstation 來建立這些虛擬機。其中一台將充當 Taroko K8s 管理主機，其餘三台將組成 Taroko K8s 叢集，這三台主機將執行 Talos Linux 作業系統。

[閱讀更多詳細資訊](https://github.com/tarokok8s/Tarokok8s/blob/main/%E6%8A%80%E8%A1%93%E6%96%87%E4%BB%B6/Taroko/Taroko%20K8S%20%E5%9F%BA%E7%A4%8E%E6%9E%B6%E6%A7%8B%E5%9C%96.md)

### 3. Quick Start
 - 3.1. Prerequisites
   - OS: Windows 10,11
   - 硬體資源
     - CPU: 8+ Core
     - RAM: 32 GB
     - Disk: 1T
   - 需先安裝好 VMware Workstation 17 Player，詳細資訊[請點此]()

- 3.2. 下載連結壓縮檔[請點此](https://drive.google.com/file/d/1axT84N_10R-Ftw5QL9kaB9dXqOhCvM1z/view?usp=drive_link)

- 3.3. 將壓縮檔解壓縮，詳細資訊[請點此](https://github.com/tarokok8s/Tarokok8s/blob/main/%E6%8A%80%E8%A1%93%E6%96%87%E4%BB%B6/Taroko/Taroko%20K8S%20%E5%B9%B3%E5%8F%B0%E5%BB%BA%E7%BD%AE.md)

- 3.4. 開啟 cmd，進入 VMTK2024v1.6.7 目錄
```
cd VMTK2024v1.6.7
```

- 3.5. 啟動 Taroko K8s VM
```
k start
```
- 3.6. 確認 TKAdm 管理主機 IP 資訊

![image](https://github.com/tarokok8s/Tarokok8s/assets/62133915/45d4f666-d645-4aea-9bc8-d631c65d6af2)

- 3.7. 使用 ssh 登入 TKAdm 管理主機
  - 帳號/密碼: bigred/bigred
```
ssh bigred@192.168.23.133
```

- 3.8. 啟動 Taroko K8s
```
1m2w.sh default
```

### 4. 平台運作架構介紹

#### Full Stack DevOps 類型

- 目標使用者 : 專門為全端開發工程師設計。
- 平台元件 : 
    - 管理 Console(Kube-kadm) : 內建 K8s 管理 Console，讓 K8s 入口憑證檔 (KubeConfig) 不流出 K8s 叢集之外。
    - Metrics Server : 維運方面可以監控貨櫃化應用程式的 CPU、記憶體資源使用量。
    - MetalLB : 網路流量方面提供負載平衡 (Load Balancer) 的功能。
    - Gateway API : 是一種用於管理和保護 API 流量。它充當單一入口點，可以讓客戶端存取後端服務。
    - Cert-manager : 用於集群中自動化管理 SSL/TLS 憑證的工具。
    - MySQL NDB : 是一個流行的開源關聯式資料庫管理系統，做為後端資料庫使用。
    - Argo workflows : 是一個開源的貨櫃原生工作流程引擎，它用於協調複雜的多步驟任務和流程，主要用途為 Machine Learning、Data and batch processing、Infrastructure automation、CI/CD 等。
    - MinIO SNSD + JuiceFS : 資料儲存上能夠隨需擴增的同時還提供容錯。
- 核心技術 : kube-Kadm + Metrics Server + MetalLB + Gateway API + Cert-manager + DirectPV + MySQL NDB + Argo workflows + MinIO SNSD + JuiceFS

![image](https://github.com/tarokok8s/Tarokok8s/assets/90317293/a12e9eb3-29f9-4fbb-a66a-2941f5ba1e0a)

[閱讀更多詳細資訊]()

#### Full Stack Data Engineer 類型

- 目標使用者 : 專門為全端資料工程師設計。
- 平台元件 :
    - 管理 Console(Kube-kadm) : 內建 K8s 管理 Console，讓 K8s 入口憑證檔 (KubeConfig) 不流出 K8s 叢集之外。
    - Metrics Server : 維運方面可以監控貨櫃化應用程式的 CPU、記憶體資源使用量。
    - MetalLB : 網路流量方面提供負載平衡 (Load Balancer) 的功能。
    - Hadoop : 是一個開源的分散式數據處理框架，它提供了一個分散式檔案系統(HDFS)和一個分散式計算框架(MapReduce)，用於存儲和處理大數據。
    - 在資料的儲存與分析方面，我們提供多種技術來做資料的處理，譬如 : 
        - 將 Minio MNMD 與 Spark 整合，可以在資料儲存上具有高度可擴展性、實現高可用和容錯，並快速、高效的透過 Spark 對大規模的資料進行分析運算。
    - Argo workflows : 是一個開源的貨櫃原生工作流程引擎，它用於協調複雜的多步驟任務和流程，主要用途為 Machine Learning、Data and batch processing、Infrastructure automation、CI/CD 等。
    - MinIO MNMD + JuiceFS : 資料儲存上能夠隨需擴增的同時還提供容錯。
- 核心技術 : kube-Kadm + Metrics Server + MetalLB + MySQL NDB + Hadoop + Spark-py + Hive + JupyterLab + Argo workflows + MinIO MNMD + JuiceFS 

[閱讀更多詳細資訊]()

# 文件目錄

- 安裝 Taroko K8s 基礎設施
  - [VMware Workstation Player 安裝]()
  - [VMware Workstation Player 網路架構圖]()
  - [VMware Workstation Player IaC 程式設計]()
- Taroko K8s 基礎介紹與安裝
  - [Taroko K8s 基礎作業系統介紹](https://github.com/tarokok8s/Tarokok8s/tree/main/%E6%8A%80%E8%A1%93%E6%96%87%E4%BB%B6/Taroko)
  - [Taroko K8s 基礎架構圖](https://github.com/tarokok8s/Tarokok8s/blob/main/%E6%8A%80%E8%A1%93%E6%96%87%E4%BB%B6/Taroko/Taroko%20K8S%20%E5%9F%BA%E7%A4%8E%E6%9E%B6%E6%A7%8B%E5%9C%96.md)
  - [Taroko K8s 平台建置](https://github.com/tarokok8s/Tarokok8s/blob/main/%E6%8A%80%E8%A1%93%E6%96%87%E4%BB%B6/Taroko/Taroko%20K8S%20%E5%B9%B3%E5%8F%B0%E5%BB%BA%E7%BD%AE.md)
  - [Taroko K8s 平台操作手冊](https://github.com/tarokok8s/Tarokok8s/blob/main/%E6%8A%80%E8%A1%93%E6%96%87%E4%BB%B6/Taroko/Taroko%20K8s%20%E5%B9%B3%E5%8F%B0%E6%93%8D%E4%BD%9C%E6%89%8B%E5%86%8A.md)
  - [Taroko K8s 平台類型選擇](https://github.com/tarokok8s/Tarokok8s/blob/main/%E6%8A%80%E8%A1%93%E6%96%87%E4%BB%B6/Taroko/Taroko%20K8s%20%E5%B9%B3%E5%8F%B0%E9%A1%9E%E5%9E%8B%E9%81%B8%E6%93%87.md)
- Full Stack DevOps 架構
  - [Taroko K8s 核心服務 - Kube-kadm]()
  - [Taroko K8s 核心服務 - Metrics Server]()
  - [Taroko K8s 核心服務 - MetalLB]()
  - [Taroko K8s 核心服務 - Gateway API](https://github.com/tarokok8s/Tarokok8s/blob/main/%E6%8A%80%E8%A1%93%E6%96%87%E4%BB%B6/Kubernetes%20Workload/Gateway%20API.md)
  - [Taroko K8s 核心服務 - Cert-manager](https://github.com/tarokok8s/Tarokok8s/blob/main/%E6%8A%80%E8%A1%93%E6%96%87%E4%BB%B6/Kubernetes%20Workload/Cert-manager.md)
  - [Taroko K8s 核心服務 - DirectPV]()
  - [Taroko K8s 核心服務 - MySQL NDB]()
  - [Taroko K8s 核心服務 - Argo workflows]()
  - [Taroko K8s 核心服務 - MinIO SNSD + JuiceFS]()
- Full Stack Data Engineer 架構
  - [Taroko K8s 核心服務 - Kube-kadm]()
  - [Taroko K8s 核心服務 - Metrics Server]()
  - [Taroko K8s 核心服務 - MetalLB]()
  - [Taroko K8s 核心服務 - DirectPV]()
  - [Taroko K8s 核心服務 - MySQL NDB]()
  - [Taroko K8s 核心服務 - Hadoop]()
  - [Taroko K8s 核心服務 - Spark-py]()
  - [Taroko K8s 核心服務 - Hive]()
  - [Taroko K8s 核心服務 - JupyterLab]()
  - [Taroko K8s 核心服務 - Argo workflows]()
  - [Taroko K8s 核心服務 - MinIO SNSD + JuiceFS]()
