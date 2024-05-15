# Taroko K8s 平台類型選擇

## SSH 登入 TKAdm 管理主機
### 目前有三種類型可選擇
```
$ 1m2w.sh
1m2w.sh <type>

type:
  default -> kube-Kadm + Metric Server + MetalLB + MinIO SNSD + DirestPV
  dt -> kube-Kadm + Metric Server + MetalLB + MinIO MNMD + MySQL NDB + Hadoop + Spark-py
  cicd -> kube-Kadm + Metric Server + MetalLB + Jenkins + Argo
```
