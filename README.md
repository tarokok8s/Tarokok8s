# Taroko K8S

## 1. Taroko(太魯閣) K8S 簡介

Taroko Kubernetes 使用 Kubernetes 專用的作業系統 Talos Linux 來建立 Kubernetes。

我們客製化了 Kubernetes 中的基礎設施，主要分為 default、dt 和 cicd 3 種類型，讓不同需求的使用者能夠快速擁有對應的基礎設施。

### 1.1. 目地

Taroko Kubernetes 是一個完全開源的系統用來管理跨多個主機的貨櫃化應用程式 (Containerized Applications)。

它專注於把貨櫃化應用程式運作的長長久久、穩穩當當。

與雲端商提供的 K8S 相比，可以完全掌控 Kubernetes 中的基礎設施，舉例 : Controlplane Node、ETCD 和 Worker Node，且不用擔心某個服務不小心大量使用，而遇到費用暴增的挑戰。

### 1.2. 組成

#### Default

- kube-Kadm + Metric Server + MetalLB + MinIO SNSD + DirestPV

Default 這個類型適合在 Kubernetes 中建立網站或資料庫，能夠透過 MetalLB 將網站服務對外，並結合 MinIO SNSD + DirestPV 讓資料能夠永存的同時還能隨需擴增。

[閱讀更多詳細資訊]()

#### dt

- kube-Kadm + Metric Server + MetalLB + MinIO MNMD + MySQL NDB + Hadoop + Spark-py

dt 這個類型會在 Kubernetes 中啟動 資料科技平台，能讓你把資料透過 Hadoop + Spark 做深度分析。

[閱讀更多詳細資訊]()

#### cicd

- kube-Kadm + Metric Server + MetalLB + Jenkins + Argo

cicd 這個類型會在 Kubernetes 中啟動 cicd 的完整功能，適合 DevOPS 工程師使用，能讓程式設計師快速開發與部屬。

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
