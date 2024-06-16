# README

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
$ sed 's|local-path|standard|g' redis-pvc.yaml | kubectl apply -f -
$ kubectl apply -f redis-standalone-deployment.yaml
$ kubectl apply -f redis-service.yaml
```

## Install CSI Driver

```bash
# https://juicefs.com/docs/community/juicefs_on_k3s/#install-csi-driver
$ wget -qO - https://raw.githubusercontent.com/juicedata/juicefs-csi-driver/master/deploy/k8s.yaml | sed 's|namespace: kube-system|namespace: s3-system|g' | kubectl apply -f
```

## Deploy juicefs storageclass

```bash
$ cat juicefs-storageclass.yaml
::
apiVersion: v1
kind: Secret
metadata:
  namespace: s3-system # Notice
  name: juicefs-minio-secret
type: Opaque
stringData:
  name: "data"
  metaurl: "redis://redis.s3-system.svc.cluster.local/1" # Notice
  storage: "minio"
  bucket: "http://minio.s3-system.svc.cluster.local:9000/juicefs" # Notice
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
  csi.storage.k8s.io/node-publish-secret-namespace: s3-system # CSI Driver deploy on which namespace
  csi.storage.k8s.io/provisioner-secret-name: juicefs-minio-secret
  csi.storage.k8s.io/provisioner-secret-namespace: s3-system # CSI Driver deploy on which namespace

$ kubectl apply -f juicefs-storageclass.yaml
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
