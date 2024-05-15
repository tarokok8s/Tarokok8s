# Kube-kadm 

## 功能介紹
1. kube-kadm 這個 Pod 為 Taroko K8s 管理 Console，可以透過 ssh 連進 kube-kadm 管理叢集與 Build Image，目的是為了不讓 K8s 入口憑證檔 (KubeConfig) 流出 K8s 叢集之外，以達到資安上的風險。
2. kube-kadm 內建 Docker Registry，充當為整個叢集的 Image Registry。

## 操作 kube-kadm
* ssh 登入 kube-kadm
```
$ ssh bigred@172.22.1.11 -p 22100
```
* 檢視叢集結點狀態
```
$ kubectl get no -owide
NAME   STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE         KERNEL-VERSION   CONTAINER-RUNTIME
k1m1   Ready    control-plane   18h   v1.29.3   172.22.1.11   <none>        Talos (v1.6.7)   6.1.82-talos     containerd://1.7.13
k1w1   Ready    <none>          17h   v1.29.3   172.22.1.15   <none>        Talos (v1.6.7)   6.1.82-talos     containerd://1.7.13
k1w2   Ready    <none>          17h   v1.29.3   172.22.1.16   <none>        Talos (v1.6.7)   6.1.82-talos     containerd://1.7.13
```
* 使用 podman 命令
```
$ sudo podman version
Client:       Podman Engine
Version:      4.8.3
API Version:  4.8.3
Go Version:   go1.21.9
Built:        Sun Apr  7 03:34:14 2024
OS/Arch:      linux/amd64
```
## 檢視 kube-kadm-dkreg.yaml
```
$ cat ~/wulin/wkload/kadm/kube-kadm-dkreg.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kadm
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kadm
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: kadm
  namespace: kube-system
---
apiVersion: v1
kind: Service
metadata:
  name: kube-kadm
  namespace: kube-system
spec:
  selector:
    app: kadm
  ports:
    - protocol: TCP
      port: 22100
      targetPort: 22100
---
apiVersion: v1
kind: Pod
metadata:
  name: kube-kadm
  namespace: kube-system
  labels:
    app: kadm
spec:
  volumes:
  - name: dkreg-storage
    hostPath:
      path: /opt/dkreg
  - name: podman-storage
    hostPath:
      path: /opt/podman
  - name: kadm-storage
    emptyDir: {}
  serviceAccountName: kadm
  containers:
  - name: kadm
    image: quay.io/cloudwalker/alp.kadm
    imagePullPolicy: Always
    tty: true
    ports:
    - containerPort: 22100
      hostPort: 22100
    lifecycle:
      postStart:
        exec:
          command:
            - /bin/bash
            - -c
            - |
              cp -p /var/tmp/htpasswd /opt/dkreg
    securityContext:
      privileged: true
    volumeMounts:
    - name: dkreg-storage
      mountPath: /opt/dkreg
    - name: podman-storage
      mountPath: /var/lib/containers/storage
    - name: kadm-storage
      mountPath: /home/bigred/wulin
      mountPropagation: Bidirectional
    env:
    - name: KUBERNETES_SERVICE_HOST
      value: "kubernetes.default"
    - name: KUBERNETES_SERVICE_PORT_HTTPS
      value: "443"
    - name: KUBERNETES_SERVICE_PORT
      value: "443"
    securityContext:
      privileged: true
  - image: quay.io/cloudwalker/registry:2
    name: dkreg
    ports:
    - containerPort: 5000
      hostPort: 5000
    volumeMounts:
    - mountPath: "/var/lib/registry"
      name: dkreg-storage
    env:
    - name: REGISTRY_AUTH
      value: "htpasswd"
    - name: REGISTRY_AUTH_HTPASSWD_PATH
      value: "/var/lib/registry/htpasswd"
    - name: REGISTRY_AUTH_HTPASSWD_REALM
      value: "Registry Realm"
  - name: s3fs
    image: quay.io/cloudwalker/alp.s3fs
    imagePullPolicy: Always
    securityContext:
      privileged: true
    volumeMounts:
    - name: kadm-storage
      mountPath: /s3
      mountPropagation: Bidirectional
    env:
    - name: USER
      value: minio
    - name: PASSWORD
      value: minio123
    - name: URL
      value: http://miniosnsd.kube-system:9000
    - name: BUCKET
      value: kadm
    - name: EXTARG
      value: "-o uid=1000 -o gid=10 -o umask=000 -o nonempty"
    - name: DEBUG
      value: "-o dbglevel=info -o curldbg -f"
  nodeSelector:
    kadm: node
  tolerations:
  - effect: NoSchedule
    operator: Exists
```
