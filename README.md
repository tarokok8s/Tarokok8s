# Taroko K8S

## Taroko(太魯閣) K8S 簡介

### 1. 目的

Taroko Kubernetes 是一個專為全端開發工程師和全端資料工程師設計的最佳實作練功坊。它的設計旨在簡化基礎設施的部署和管理，讓使用者可以更專注於前後端開發和資料分析的工作，而不必花費過多時間在環境設定和維護上。

在 Taroko Kubernetes 中可以一鍵啟動 2 種不同類型的基礎設施，主要分為 全端開發工程師和全端資料分析工程師，這 2 種類型，讓不同需求的使用者能夠快速在對應的基礎設施上部署和維運貨櫃化應用程式 (Containerized Applications)，並能夠有更多時間可以專注於創造價值和解決問題。

### 2. 組成

- 預設總共會有 4 台 VM，一台扮演 Talos 外部管理主機，另外 3 台 VM 會組成 Talos Kubernetes Cluster。

[閱讀更多詳細資訊](https://github.com/tarokok8s/Tarokok8s/blob/5090dea47b5d76cc2bff134915ce52507fe86fd8/%E6%8A%80%E8%A1%93%E6%96%87%E4%BB%B6/Taroko/Taroko%20K8S%20%E5%9F%BA%E7%A4%8E%E6%9E%B6%E6%A7%8B%E5%9C%96.md)

### 3. 各類型詳細介紹

#### Full Stack DevOps 基礎類型

- 目標使用者 : 專門為全端開發工程師設計。
- 特點 : 
    - 管理 Console(Kube-kadm) : 內建 K8s 管理 Console，讓 K8s 入口憑證檔 (KubeConfig) 不流出 K8s 叢集之外。
    - MetalLB : 網路流量方面提供負載平衡 (Load Balancer) 的功能。
    - Gateway API : 是一種用於管理和保護 API 流量。它充當單一入口點，可以讓客戶端存取後端服務。
    - Cert-manager : 用於集群中自動化管理 SSL/TLS 憑證的工具。
    - 資料儲存上能夠隨需擴增的同時還提供容錯。
    - Metric Server : 維運方面可以監控貨櫃化應用程式的 CPU、記憶體資源使用量
- 核心技術 : kube-Kadm + Metric Server + MetalLB + Gateway API + Cert-manager + DirectPV + MySQL + Jenkins + MinIO SNSD、seaweedfs、JuiceFS(擇一)

![image](https://github.com/tarokok8s/Tarokok8s/assets/90317293/a12e9eb3-29f9-4fbb-a66a-2941f5ba1e0a)

[閱讀更多詳細資訊]()

#### Full Stack Data Engineer 基礎類型

- 目標使用者 : 專門為全端資料工程師設計。
- 特點 :
    - 管理 Console(Kube-kadm) : 內建 K8s 管理 Console，讓 K8s 入口憑證檔 (KubeConfig) 不流出 K8s 叢集之外。
    - MetalLB : 網路流量方面提供負載平衡 (Load Balancer) 的功能。
    - Hadoop : 是一個開源的分散式數據處理框架，它提供了一個分散式檔案系統(HDFS)和一個分散式計算框架(MapReduce)，用於存儲和處理大數據。
    - 在資料的儲存與分析方面，我們提供多種技術來做資料的處理，譬如 : 
        - 將 Minio MNMD 與 Spark 整合，可以在資料儲存上具有高度可擴展性、實現高可用和容錯，並快速、高效的透過 Spark 對大規模的資料進行分析運算。
- 核心技術 : kube-Kadm + Metric Server + MetalLB + MinIO MNMD + MySQL NDB + Hadoop + Spark-py + Argo

[閱讀更多詳細資訊]()

# 文件目錄

- 安裝 Taroko K8S 基礎設施
  - [VMware Workstation Player 安裝]()
  - [VMware Workstation Player 網路架構圖]()
  - [VMware Workstation Player IaC 程式設計]()
- Taroko K8S 基礎介紹與安裝
  - [Taroko K8S 基礎作業系統介紹](https://github.com/tarokok8s/Tarokok8s/tree/8288b280d2ea3965ba7954267187c92c6f70b7b3/%E6%8A%80%E8%A1%93%E6%96%87%E4%BB%B6/Taroko)
  - [Taroko K8S 基礎架構圖](https://github.com/tarokok8s/Tarokok8s/blob/c76dfcd6d206f9604a01b9c5238ea31fd0524ee7/%E6%8A%80%E8%A1%93%E6%96%87%E4%BB%B6/Taroko/Taroko%20K8S%20%E5%9F%BA%E7%A4%8E%E6%9E%B6%E6%A7%8B%E5%9C%96.md)
  - [Tariko K8S 平台建置](https://github.com/tarokok8s/Tarokok8s/blob/main/%E6%8A%80%E8%A1%93%E6%96%87%E4%BB%B6/Taroko/Taroko%20K8S%20%E5%B9%B3%E5%8F%B0%E5%BB%BA%E7%BD%AE.md)
- Taroko K8S 核心服務
  - [Taroko K8S 核心服務 - Metric Server]()
  - [Taroko K8S 核心服務 - MetalLB]()
  - [Taroko K8S 核心服務 - MinIO SNSD]()
