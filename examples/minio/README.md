# README

## Deploy minio

```bash
$ kubectl create ns s3-system

# kind local-path name standard
$ wget -qO - https://raw.githubusercontent.com/tarokok8s/Tarokok8s/main/examples/minio/minio.yaml | sed 's|local-path|standard|g' | kubectl apply -f -

$ kubectl wait -n s3-system pod -l app=minio --for=condition=Ready --timeout=360s
pod/minio-0 condition met
pod/minio-1 condition met
```

## Site Replication Overview

```bash
# https://min.io/docs/minio/linux/operations/install-deploy-manage/multi-site-replication.html#minio-site-replication-overview
```

## Erasure Coding

```bash
# Doc
# https://min.io/docs/minio/linux/operations/concepts/erasure-coding.html
# https://min.io/product/erasure-code-calculator
# https://blog.min.io/guided-tour-of-minio-erasure-code-calculator/
# https://blog.min.io/selecting-hardware-for-minio-deployment/

# Github
# https://github.com/minio/minio/blob/master/docs/erasure/README.md
# https://github.com/minio/minio/blob/master/docs/erasure/storage-class/README.md

# CSDN and other blog
# https://cloud.tencent.com/developer/article/2353439
# https://juejin.cn/post/7159024565581479943#heading-24
# https://blog.csdn.net/jacky128256/article/details/109900239
# https://www.jianshu.com/p/acf0f392bac9

# Reed-Solomon
# https://blog.csdn.net/oqqYuan1234567890/article/details/107702117
# https://github.com/klauspost/reedsolomon

$ ../simple-encoder -data 3 -par 1 -out . ../alpine.iso
$ ../simple-decoder -data 3 -par 1 -out alpine.bk.iso alpine.iso

$ ../simple-encoder -data 2 -par 2 -out . ../alpine.iso
$ ../simple-decoder -data 2 -par 2 -out alpine.bk.iso alpine.iso
```

## How to secure access to MinIO on Kubernetes with TLS

```bash
# https://github.com/minio/minio/blob/master/docs/tls/kubernetes/README.md
# https://github.com/minio/minio/blob/master/docs/tls/README.md
```
