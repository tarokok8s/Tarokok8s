# README

## Architecture

![Juicefs Architecture](https://juicefs.com/docs/assets/images/juicefs-arch-52477e7677b23c870b72f08bb28c7ceb.svg)

## K8s install

```bash
# Doc
# https://juicefs.com/docs/zh/csi/guide/pv
# https://juicefs.com/docs/zh/community/reference/how_to_set_up_object_storage/#minio
# https://juicefs.com/docs/community/juicefs_on_k3s/#install-csi-driver

# https://juicefs.com/docs/zh/community/architecture/
# https://juicefs.com/docs/zh/community/internals/io_processing
# https://juicefs.com/docs/zh/community/guide/cache/#metadata-cache
# https://juicefs.com/docs/zh/community/security/trash/
```

## Deploy Redis

```bash
$ kubectl create ns s3-system

# kind local-path name standard
$ wget -qO - https://raw.githubusercontent.com/tarokok8s/Tarokok8s/main/examples/juicefs/redis.yaml | sed 's|local-path|standard|g' | kubectl apply -f -

# not kind local-path
$ wget -qO - https://raw.githubusercontent.com/tarokok8s/Tarokok8s/main/examples/juicefs/redis.yaml | kubectl apply -f -

# wait
$ kubectl wait -n s3-system pod -l app=redis --for=condition=Ready --timeout=360s

# test redis
$ redis=$(kubectl get pod -n s3-system -l app=redis -o name)
$ kubectl exec -it -n s3-system $redis -- redis-benchmark -q -n 1000
PING_INLINE: 200000.00 requests per second, p50=0.159 msec
PING_MBULK: 249999.98 requests per second, p50=0.095 msec
SET: 249999.98 requests per second, p50=0.095 msec
GET: 249999.98 requests per second, p50=0.095 msec
INCR: 249999.98 requests per second, p50=0.087 msec
LPUSH: 249999.98 requests per second, p50=0.087 msec
RPUSH: 249999.98 requests per second, p50=0.087 msec
LPOP: 249999.98 requests per second, p50=0.087 msec
RPOP: 249999.98 requests per second, p50=0.095 msec
SADD: 249999.98 requests per second, p50=0.095 msec
HSET: 333333.34 requests per second, p50=0.095 msec
SPOP: 333333.34 requests per second, p50=0.095 msec
ZADD: 333333.34 requests per second, p50=0.087 msec
ZPOPMIN: 333333.34 requests per second, p50=0.087 msec
LPUSH (needed to benchmark LRANGE): 333333.34 requests per second, p50=0.087 msec
LRANGE_100 (first 100 elements): 142857.14 requests per second, p50=0.175 msec
LRANGE_300 (first 300 elements): 55555.56 requests per second, p50=0.463 msec
LRANGE_500 (first 500 elements): 37037.04 requests per second, p50=0.703 msec
LRANGE_600 (first 600 elements): 28571.43 requests per second, p50=0.887 msec
MSET (10 keys): 166666.67 requests per second, p50=0.159 msec
XADD: 166666.67 requests per second, p50=0.159 msec
```

## Install CSI Driver

```bash
# https://juicefs.com/docs/community/juicefs_on_k3s/#install-csi-driver
$ kubectl apply -f https://raw.githubusercontent.com/tarokok8s/Tarokok8s/main/examples/juicefs/juicefs.yaml
$ kubectl wait -n s3-system pod -l app=juicefs-csi-controller --for=condition=Ready --timeout=360s &&
    kubectl wait -n s3-system pod -l app=juicefs-csi-node --for=condition=Ready --timeout=360s &&
    kubectl wait -n s3-system pod -l app=juicefs-csi-dashboard --for=condition=Ready --timeout=360s
```

## Deploy juicefs storageclass

```bash
$ wget -qO - https://raw.githubusercontent.com/tarokok8s/Tarokok8s/main/examples/juicefs/storageclass.yaml
::
apiVersion: v1
kind: Secret
metadata:
  namespace: s3-system
  name: juicefs-minio-secret
type: Opaque
stringData:
  name: "data"
  metaurl: "redis://redis.s3-system.svc.cluster.local/1"
  storage: "minio"
  bucket: "http://minio.s3-system.svc.cluster.local:9000/juicefs"
  access-key: "minio"
  secret-key: "minio123"
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: juicefs-minio
provisioner: csi.juicefs.com
reclaimPolicy: Retain
volumeBindingMode: Immediate
parameters:
  csi.storage.k8s.io/node-publish-secret-name: juicefs-minio-secret
  csi.storage.k8s.io/node-publish-secret-namespace: s3-system
  csi.storage.k8s.io/provisioner-secret-name: juicefs-minio-secret
  csi.storage.k8s.io/provisioner-secret-namespace: s3-system

$ kubectl apply -f https://raw.githubusercontent.com/tarokok8s/Tarokok8s/main/examples/juicefs/storageclass.yaml
$ kubectl get pod -n s3-system
NAME                                        READY   STATUS    RESTARTS       AGE
pod/juicefs-csi-controller-0                4/4     Running   4 (5d5h ago)   9d
pod/juicefs-csi-controller-1                4/4     Running   0              9d
pod/juicefs-csi-dashboard-887bd6474-x6sh7   1/1     Running   0              9d
pod/juicefs-csi-node-5lfvr                  3/3     Running   0              9d
pod/juicefs-csi-node-lvx95                  3/3     Running   0              9d
pod/minio-0                                 1/1     Running   0              9d
pod/minio-1                                 1/1     Running   0              9d
pod/minio-mg                                1/1     Running   0              9d
pod/redis-79785c6794-h26g2                  1/1     Running   0              9d

```

## Test juicefs

```bash
$ kubectl apply -f test-mariadb.yaml
```
