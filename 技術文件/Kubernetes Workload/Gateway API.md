# Gateway API

* Gateway API 就是用來取代 Ingress 的。
* 在 Kubernetes 中，Gateway API 是一種用於管理和保護 API 流量的軟體。它充當單一入口點，可讓客戶端訪問後端服務。
* Kubernetes Gateway API 是 Kubernetes 1.18 版本引進的一種新的 API 規範，是 Kubernetes 官方正在開發的新的 API，Ingress 是 Kubernetes 已有的 API。Gateway API 會成為 Ingress 的下一代替代方案。Gateway API 提供更豐富的功能，支援 TCP、UDP、TLS 等，不只是 HTTP。Ingress 主要面向 HTTP 流量。Gateway API 具有更強的擴充性，透過 CRD 可以輕易新增特定的 Gateway 類型。 


## 架構圖
![image](https://hackmd.io/_uploads/ByMs9xzM0.png)
## 運作原理
![image](https://hackmd.io/_uploads/rJYs5efMR.png)
* GatewayClass： 一組共用通用設定和行為的 Gateway 集合，就像 IngressClass、StorageClass 一樣。
* Gateway：就是 GatewayClass 的具體實現，聲明後由 GatewayClass 的基礎設備提供者提供一個具體存在的 Pod，充當了進入 Kubernetes 集群的流量的入口，負責流量接入以及往後轉發，同時還可以起到一個初步過濾的效果。
* HTTPRoute： 定義特定於 HTTP 的規則，用於將流量從 Gateway 導入到應到後端的服務。這些端點通常表示為 Service。

## 安装 Gateway API CRD 和 Envoy Controller
* 需先安裝好 metallb
* 安裝標準版 Gateway API CRD，包括功能有 GatewayClass、Gateway、HTTPRoute 和 ReferenceGrant
```
$ kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml
```
* 測試版 Gateway API CRD，包括功能有 TCPRoute、TLSRoute、UDPRoute 和 GRPCRoute(未來可能會刪除)
```
$ kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/experimental-install.yaml
```

* 安裝 Envoy Controller
```
$ kubectl apply -f https://github.com/envoyproxy/gateway/releases/download/v1.0.1/install.yaml
```
* 查看已安裝的 CRD 資源
```
$ kubectl get crd |grep networking.k8s.io
gatewayclasses.gateway.networking.k8s.io                          2024-05-03T05:57:30Z
gateways.gateway.networking.k8s.io                                2024-05-03T05:57:30Z
grpcroutes.gateway.networking.k8s.io                              2024-05-03T05:57:30Z
httproutes.gateway.networking.k8s.io                              2024-05-03T05:57:30Z
referencegrants.gateway.networking.k8s.io                         2024-05-03T05:57:30Z
tcproutes.gateway.networking.k8s.io                               2024-05-03T05:57:30Z
tlsroutes.gateway.networking.k8s.io                               2024-05-03T05:57:31Z
udproutes.gateway.networking.k8s.io                               2024-05-03T05:57:31Z
```
* 查看安裝的 envoy controller
```
$ kubectl get pod -n envoy-gateway-system
NAME                             READY   STATUS    RESTARTS   AGE
envoy-gateway-6dcd84c6c9-gl8kb   2/2     Running   0          108s
```
## 部屬 gatewayclass

* 部屬 gatewayclass
```
$ echo 'apiVersion: gateway.networking.k8s.io/v1beta1
kind: GatewayClass
metadata:
  name: eg
spec:
  controllerName: gateway.envoyproxy.io/gatewayclass-controller' | kubectl apply -f -
```
```
$ kubectl get gatewayclass
NAME           CONTROLLER                                      ACCEPTED   AGE
eg             gateway.envoyproxy.io/gatewayclass-controller   True       7s
```
## gateway api 測試
* 部屬測試用 backend deployment
```
$ echo $'apiVersion: v1
kind: Service
metadata:
  name: svc-backend
  labels:
    app: backend
    service: backend
spec:
  ports:
    - name: http
      port: 3000
      targetPort: 3000
  selector:
    app: backend
---
apiVersion: v1
kind: Service
metadata:
  name: svc-backend2
  labels:
    app: backend2
    service: backend2
spec:
  ports:
    - name: http
      port: 3000
      targetPort: 3000
  selector:
    app: backend2
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
      version: v1
  template:
    metadata:
      labels:
        app: backend
        version: v1
    spec:
      containers:
        - image: docker.io/taiwanese/echoserver
          imagePullPolicy: IfNotPresent
          name: backend
          ports:
            - containerPort: 3000
          env:
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend2
      version: v1
  template:
    metadata:
      labels:
        app: backend2
        version: v1
    spec:
      containers:
        - image: docker.io/taiwanese/echoserver
          imagePullPolicy: IfNotPresent
          name: backend2
          ports:
            - containerPort: 3000
          env:
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace' | kubectl apply -f -
```
```
$ kubectl get svc,pod
NAME                   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
service/kubernetes     ClusterIP   10.43.0.1      <none>        443/TCP    76d
service/svc-backend    ClusterIP   10.43.144.57   <none>        3000/TCP   4m10s
service/svc-backend2   ClusterIP   10.43.198.74   <none>        3000/TCP   4m10s

NAME                            READY   STATUS    RESTARTS   AGE
pod/backend-6c74b76b4-r6npw     1/1     Running   0          7h52m
pod/backend2-67c74bfb48-6q78n   1/1     Running   0          5h54m
```

* 部屬 gateway resource
* 設定 gateway 對外開的 port 是 80
```
$ echo 'apiVersion: gateway.networking.k8s.io/v1beta1
kind: Gateway
metadata:
  name: eg
spec:
  gatewayClassName: eg
  listeners:
    - name: http
      protocol: HTTP
      port: 80' | kubectl apply -f -
```
```
$ kubectl get gateway
NAME   CLASS   ADDRESS          PROGRAMMED   AGE
eg     eg      192.168.11.160   True         28m
```
* 會在 `envoy-gateway-system` namespace 下建立一個對外的 service，並且導入到 `envoy-default-my-tcp-gateway-28bd5041` 這個 pod。
```
$ kubectl -n envoy-gateway-system get po,svc
NAME                                                         READY   STATUS    RESTARTS   AGE
pod/envoy-default-my-tcp-gateway-28bd5041-848dd48d74-wcjff   2/2     Running   0          2m20s
pod/envoy-gateway-6bccd54479-lqmm5                           1/1     Running   0          3m37s

NAME                                            TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)                         AGE
service/envoy-default-my-tcp-gateway-28bd5041   LoadBalancer   10.43.20.124    192.168.11.146   8080:32387/TCP,8090:31917/TCP   2m20s
service/envoy-gateway                           ClusterIP      10.43.199.147   <none>           18000/TCP,18001/TCP             3m37s
service/envoy-gateway-metrics-service           ClusterIP      10.43.9.247     <none>           19001/TCP                       3m37s
```



* 部屬 httproute resource
* 來自 Gateway 的 HTTP 流量， 如果 Host 的 header 設定為 `www.example.com` 且請求路徑指定為 `/backend`， 將被路由至 svc-backend ，如果請求路徑指定為 `/backend2` 將被路由至 svc-backend2。

```
$ echo 'apiVersion: gateway.networking.k8s.io/v1beta1
kind: HTTPRoute
metadata:
  name: backend
spec:
  parentRefs:
    - name: eg
  hostnames:
    - "www.example.com"
  rules:
    - backendRefs:
        - group: ""
          kind: Service
          name: svc-backend
          port: 3000
          weight: 1
      matches:
        - path:
            type: PathPrefix
            value: /backend
    - backendRefs:
        - group: ""
          kind: Service
          name: svc-backend2
          port: 3000
          weight: 1
      matches:
        - path:
            type: PathPrefix
            value: /backend2' | kubectl apply -f -
```
```
$ kubectl get httproute
NAME      HOSTNAMES             AGE
backend   ["www.example.com"]   4m18s
```
* Controller 提供的流量入口 Pod。
```
$ kubectl get pod -n envoy-gateway-system
NAME                                         READY   STATUS    RESTARTS   AGE
envoy-default-eg-64656661-8677c5c79c-c7zg4   1/1     Running   0          4m45s
envoy-gateway-6dcd84c6c9-gl8kb               2/2     Running   0          10m
```
* 檢查 envoy 對外的 service，開了 80 port
```
$ kubectl get svc -n envoy-gateway-system|grep LoadBalancer
envoy-default-my-tcp-gateway-28bd5041   LoadBalancer   10.43.20.124    192.168.11.146   80:30796/TCP   2m49s
```

## request 流程圖
![image](https://hackmd.io/_uploads/rJ9TffffC.png)

1. Client 開始準備 URL 為 `http://www.example.com` 的 HTTP 請求 
2. Client 的 DNS 會先做名稱解析到對應的 IP。 
3. Client 向 Gateway IP 位址發送 request；反向代理接收 HTTP request 並使用 header 匹配 Gateway 和 HTTPRoute 的設定。 
4. 反向代理可以根據 HTTPRoute 的匹配規則針對 request 所帶的 path 需要符合規則。 
5. 反向代理可以修改 request；例如，根據 HTTPRoute 的過濾規則新增或刪除 header。 
6. 最後，反向代理將請求轉送到一個或多個後端。

* 再叢集外測試打一個 request，可以透過不同的 path 將流量導入到不同的服務。
```
$ curl -H "host: www.example.com" http://192.168.11.160/backend
{
 "path": "/backend",
 "host": "www.example.com",
 "method": "GET",
 "proto": "HTTP/1.1",
 "headers": {
  "Accept": [
   "*/*"
  ],
  "User-Agent": [
   "curl/8.0.1"
  ],
  "X-Envoy-Internal": [
   "true"
  ],
  "X-Forwarded-For": [
   "192.168.11.65"
  ],
  "X-Forwarded-Proto": [
   "http"
  ],
  "X-Request-Id": [
   "c218884d-3a8d-4ca1-b280-4f027c7acc3d"
  ]
 },
 "namespace": "default",
 "ingress": "",
 "service": "",
 "pod": "backend-6c74b76b4-r6npw"
}

$ curl -H "host: www.example.com" http://192.168.11.160/backend2
{
 "path": "/backend2",
 "host": "www.example.com",
 "method": "GET",
 "proto": "HTTP/1.1",
 "headers": {
  "Accept": [
   "*/*"
  ],
  "User-Agent": [
   "curl/8.0.1"
  ],
  "X-Envoy-Internal": [
   "true"
  ],
  "X-Forwarded-For": [
   "192.168.11.65"
  ],
  "X-Forwarded-Proto": [
   "http"
  ],
  "X-Request-Id": [
   "f7ff826f-2c47-47a0-9940-abe4898b6517"
  ]
 },
 "namespace": "default",
 "ingress": "",
 "service": "",
 "pod": "backend2-67c74bfb48-6q78n"
}
```

* 環境清除
```
$ kubectl delete httproute backend

$ kubectl delete gateway eg
```
