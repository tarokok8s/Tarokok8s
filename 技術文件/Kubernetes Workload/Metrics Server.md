# Metrics Server

![image](https://hackmd.io/_uploads/rJFz3lG7A.png)

* Metrics Server 是叢集級別的數據聚和器(aggregator)，作為一個  Deployment 部署在 K8s 叢集中，透過將 kube-aggregator 部屬到 API Server 上，基於 kubelet 收集各個節點的指標數據再將數據儲存在 Metrics Server 的 Memory 中(代表不會保存歷史數據，重啟資料就會消失)，再以 API 的形式提供出來。
* Metrics Server 主要用來透過 aggregate api 向其它元件（kube-scheduler、Horizontal Pod Autoscaler、Kubernetes 叢集等）提供叢集中的 pod 和 node 的 cpu 和 memory 監控指標，水平擴展的 podautoscaler 就是透過呼叫這個介面來查看 pod 的目前資源使用量來進行 pod 的擴縮容的。

## 操作方式
* 檢視 Node 資源
```
$ kubectl top no
NAME   CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
k1m1   135m         3%     1743Mi          31%
k1w1   52m          1%     860Mi           15%
k1w2   45m          1%     896Mi           16%
```
* 檢視 Workload 資源
```
$ kubectl top po -A
NAMESPACE                       NAME                                             CPU(cores)   MEMORY(bytes)
kube-system                     calico-kube-controllers-5fc7d6cf67-lwb4k         4m           51Mi
kube-system                     canal-dmkmp                                      22m          141Mi
kube-system                     canal-v79mq                                      22m          141Mi
kube-system                     canal-xpbt8                                      24m          142Mi
kube-system                     coredns-85b955d87b-jpmgc                         2m           28Mi
kube-system                     coredns-85b955d87b-jpp76                         1m           44Mi
kube-system                     kube-apiserver-k1m1                              34m          329Mi
kube-system                     kube-controller-manager-k1m1                     11m          49Mi
kube-system                     kube-kadm                                        1m           163Mi
kube-system                     kube-proxy-rzndn                                 1m           67Mi
kube-system                     kube-proxy-x625p                                 3m           68Mi
kube-system                     kube-proxy-zctj4                                 7m           67Mi
kube-system                     kube-scheduler-k1m1                              3m           21Mi
kube-system                     metrics-server-6d94bc8694-kh5sl                  2m           64Mi
kube-system                     miniosnsd                                        4m           159Mi
kubelet-serving-cert-approver   kubelet-serving-cert-approver-58b48cf746-4b8bm   1m           30Mi
metallb-system                  controller-5f56cd6f78-5shb7                      1m           49Mi
metallb-system                  speaker-47xnp                                    3m           53Mi
metallb-system                  speaker-f6c25                                    3m           53Mi
metallb-system                  speaker-n587d                                    3m           51Mi
```
## 檢視 Metrics Server yaml

```
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    k8s-app: metrics-server
    rbac.authorization.k8s.io/aggregate-to-admin: "true"
    rbac.authorization.k8s.io/aggregate-to-edit: "true"
    rbac.authorization.k8s.io/aggregate-to-view: "true"
  name: system:aggregated-metrics-reader
rules:
- apiGroups:
  - metrics.k8s.io
  resources:
  - pods
  - nodes
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    k8s-app: metrics-server
  name: system:metrics-server
rules:
- apiGroups:
  - ""
  resources:
  - nodes/metrics
  verbs:
  - get
- apiGroups:
  - ""
  resources:
  - pods
  - nodes
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server-auth-reader
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: extension-apiserver-authentication-reader
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server:system:auth-delegator
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    k8s-app: metrics-server
  name: system:metrics-server
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:metrics-server
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: v1
kind: Service
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
spec:
  ports:
  - name: https
    port: 443
    protocol: TCP
    targetPort: https
  selector:
    k8s-app: metrics-server
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
spec:
  selector:
    matchLabels:
      k8s-app: metrics-server
  strategy:
    rollingUpdate:
      maxUnavailable: 0
  template:
    metadata:
      labels:
        k8s-app: metrics-server
    spec:
      containers:
      - args:
        - --cert-dir=/tmp
        - --secure-port=10250
        - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
        - --kubelet-use-node-status-port
        - --metric-resolution=15s
        image: registry.k8s.io/metrics-server/metrics-server:v0.7.1
        imagePullPolicy: IfNotPresent
        livenessProbe:
          failureThreshold: 3
          httpGet:
            path: /livez
            port: https
            scheme: HTTPS
          periodSeconds: 10
        name: metrics-server
        ports:
        - containerPort: 10250
          name: https
          protocol: TCP
        readinessProbe:
          failureThreshold: 3
          httpGet:
            path: /readyz
            port: https
            scheme: HTTPS
          initialDelaySeconds: 20
          periodSeconds: 10
        resources:
          requests:
            cpu: 100m
            memory: 200Mi
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 1000
          seccompProfile:
            type: RuntimeDefault
        volumeMounts:
        - mountPath: /tmp
          name: tmp-dir
      nodeSelector:
        kubernetes.io/os: linux
      priorityClassName: system-cluster-critical
      serviceAccountName: metrics-server
      volumes:
      - emptyDir: {}
        name: tmp-dir
---
apiVersion: apiregistration.k8s.io/v1
kind: APIService
metadata:
  labels:
    k8s-app: metrics-server
  name: v1beta1.metrics.k8s.io
spec:
  group: metrics.k8s.io
  groupPriorityMinimum: 100
  insecureSkipTLSVerify: true
  service:
    name: metrics-server
    namespace: kube-system
  version: v1beta1
  versionPriority: 100

```
