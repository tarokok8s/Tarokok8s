# MetalLB

![image](https://hackmd.io/_uploads/rJ6YC6bmR.png)

## MetalLB 是什麼？

MetalLB 就是用來提供在地端實現網路 LoadBalancer 的方式。
簡而言之，它允許你在非運行雲端提供商上的叢集中創建類型為 LoadBalancer 的 Kubernetes 服務。

因為地端的 K8s 原生並沒有 LoadBalancer 的功能，所以只能在公有雲 IaaS 平台才能直接使用 LoadBalancer 類型的 service。除此之外就只能用 NodePort or externalIP 來將服務對外。但一般來說建議還是使用 LoadBalancer 類型較好。

## MetalLB 的優點：

1. 簡單設定：簡化了負載均衡器的配置過程，使其易於設置和管理。它不需要太多的複雜配置，並提供了一個簡單的方式來將外部 IP 地址分配給 Kubernetes 服務。
2. 無雲端依賴：對於那些不使用雲端提供的負載均衡服務的用戶來說，MetalLB 是一個理想的解決方案。它可以在本地資料中心或私有雲中運作，無需依賴雲端供應商的特定產品或服務。
3. 節省成本：使用 MetalLB 可以節省成本，因為它不需要訂閱付費的雲端負載均衡器服務。這對於預算有限的組織或個人來說尤其有吸引力。
4. 可擴展性：MetalLB 可以根據需求擴展，並處理不同類型的負載均衡需求。它能夠動態地調整 IP 地址的分配，以應對流量增長，因此非常適用於具有變化需求的環境。
5. 與 Kubernetes 整合：MetalLB 與 Kubernetes 緊密整合，允許您使用 Kubernetes 服務類型 LoadBalancer，使其與其他 Kubernetes 元件無縫協作。這樣可以實現更高的自動化和自我修復性。

## L2 模式的運作流程
![image](https://hackmd.io/_uploads/rJVoP6bXC.png)

* 當外部想要找 K8s 內的某個服務，透過發送 ARP，由 Leader 節點用 MAC address 回應。外部主機就會將回應存在本地的 ARP table，下次就可以直接從本地取得。當請求已到達節點之後，節點就會再透過 kube-proxy 將請求轉到負載平衡的目標 Pod。
> 所以其實還是透過 kube-proxy 來提供服務的負載平衡的功能，不是 MetalLB 本身

## 組成元件：
1. Controller : 以 deployment 的方式實現，用來監聽 Service 的變動、分配/回收 IP。
2. Speaker : 用來實現對外廣播，以 daemonset 方式實現，對外廣播Service IP。

## 運作流程

1. Controller 監聽 Service 的變動、分配/回收 IP，監聽到 Service 設定為 Loadbalancer 模式時，就從 IP Pool 分配一個對應的 IP，並且在刪除 Service 時(或改成其他模式)回收 IP。
2. Speaker 根據選擇的 Protocol 進行對應的廣播與回應，當流量透過 TCP/UDP 到達指定的 Node 時，由 Node 上的 Kube-Proxy 元件處理流量，分發到對應的 Pod。

## MetalLB 安裝

```!
$ wget -qO - https://raw.githubusercontent.com/metallb/metallb/v0.14.0/config/manifests/metallb-native.yaml | kubectl apply -f -
```

```
## 注意 addresses 要換自己環境的 ip
$ echo '
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: mlb1
  namespace: metallb-system
spec:
  addresses:
    - 192.168.61.220-192.168.61.230
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: mlb1
  namespace: metallb-system' | kubectl apply -f -
```
## MetalLB 檢查
```
$ kubectl get pod -n metallb-system -o wide
NAME                          READY   STATUS    RESTARTS   AGE   IP             NODE   NOMINATED NODE   READINESS GATES
controller-7476b58756-rhchw   1/1     Running   0          11m   10.244.1.54    w1     <none>           <none>
speaker-779hp                 1/1     Running   0          11m   192.168.61.7   w2     <none>           <none>
speaker-hx8tp                 1/1     Running   0          11m   192.168.61.6   w1     <none>           <none>
speaker-vxdnp                 1/1     Running   0          11m   192.168.61.4   m1     <none>           <none>
```

### MetalLB 測試
* 建立deployment
```
$ echo '
apiVersion: apps/v1
kind: Deployment
metadata:
  name: s1.dep
spec:
  replicas: 2
  selector:
    matchLabels:
      app: s1.dep
  template:
    metadata:
      labels:
        app: s1.dep
    spec:
      containers:
      - name: app
        image: quay.io/flysangel/image:app.golang' | kubectl apply -f -
deployment.apps/s1.dep created
```

* 建立 LoadBalancer service
```
$ echo '
apiVersion: v1
kind: Service
metadata:
  name: s1
  annotations:
    metallb.universe.tf/address-pool: mlb1
spec:
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: s1.dep
  type: LoadBalancer' | kubectl apply -f -
service/s1 created
```
* 檢查 service
* 這邊的`192.168.61.220`就會是從 ip pool 提供的 ip，讓服務對外給別人連線
```
$ kubectl get pod
NAME                      READY   STATUS    RESTARTS   AGE
s1.dep-5949f6d856-khqp8   1/1     Running   0          3s
s1.dep-5949f6d856-59w6k   1/1     Running   0          3s

$ kubectl get service
NAME                 TYPE           CLUSTER-IP    EXTERNAL-IP      PORT(S)        AGE
service/kubernetes   ClusterIP      10.98.0.1     <none>           443/TCP        9d
service/s1           LoadBalancer   10.98.0.137   192.168.61.220   80:32323/TCP   30s
```
## 驗證
* 確認流量可以打到不同的 pod
```
$ curl -w "\n" http://192.168.61.220
{"message":"Hello Golang"}

$ curl -w "\n" http://192.168.61.220/hostname
{"message":"s1.dep-55f7bf48df-zcbcp"}

$ curl -w "\n" http://192.168.61.220/hostname
{"message":"s1.dep-55f7bf48df-b588s"}
```

* 使用 arping 確認 macaddress 位置
```
$ sudo arping -c 4 192.168.61.220
ARPING 192.168.61.220 from 192.168.61.4 eth0
Unicast reply from 192.168.61.220 [00:50:56:AB:00:07]  0.873ms
Unicast reply from 192.168.61.220 [00:50:56:AB:00:07]  1.253ms
Unicast reply from 192.168.61.220 [00:50:56:AB:00:07]  0.813ms
Unicast reply from 192.168.61.220 [00:50:56:AB:00:07]  0.871ms
Sent 4 probes (1 broadcast(s))
Received 4 response(s) 
```
> `00:50:56:AB:00:07`這個`macaddress`是 w2
## 總結
把 w2 關機之後再去 arping，會發現`macaddress`會變成 w1，並且服務還是會通，雖然 metallb 不會幫我們做附載平衡，但她會幫我們做到單點主機損毀，並且幫我們換到別台主機上。



