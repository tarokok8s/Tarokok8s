# README

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

## Deploy minio

```bash
$ kubectl create ns s3-system
$ sed 's|local-path|standard|g' minio-distributed-statefulset.yaml | kubectl apply -f -
$ kubectl apply -f minio-service.yaml
$ kubectl apply -f minio-manage-pod.yaml
```

## Site Replication Overview

```bash
# https://min.io/docs/minio/linux/operations/install-deploy-manage/multi-site-replication.html#minio-site-replication-overview

# install mc
$ curl -sLO https://dl.min.io/client/mc/release/linux-amd64/mc
$ sudo install -o root -g root -m 0755 mc /usr/local/bin/mc && rm -r mc

# create bucket
$ mc config host add sa http://minio-a.default.svc.cluster.local:9000 minio minio123
$ mc admin config set sa storage_class standard=EC:1
$ mc mb sa/rp1

# check sb clean
$ mc config host add sb http://minio-b.default.svc.cluster.local:9000 minio minio123
$ mc admin config set sb storage_class standard=EC:1
$ mc ls sb

# set up replication
$ mc alias set sa http://minio-a.default.svc.cluster.local:9000 minio minio123
$ mc alias set sb http://minio-b.default.svc.cluster.local:9000 minio minio123

$ mc admin replicate add sa sb
$ mc admin replicate info sa
$ mc admin replicate status sa
```

## How to secure access to MinIO on Kubernetes with TLS

```bash
# https://github.com/minio/minio/blob/master/docs/tls/kubernetes/README.md
# https://github.com/minio/minio/blob/master/docs/tls/README.md
```
