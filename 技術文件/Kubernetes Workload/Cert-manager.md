# Cert-manager

## Cert-manager 資源定義
* 安裝好 cert-manager 之後，我們要來設定簽發 TLS 憑證的組態，而這邊有兩種類別，我們這個範例使用 Issuer
  - Issuer(頒發者)：作用範圍只在某個 K8S Namespace 內
  - ClusterIssuer(頒發者)：作用範圍為整個 K8S Cluster
  - Certificate(憑證) : 物件表示 TLS/SSL 證書。描述了憑證的期望屬性，它包含證書的 PEM 編碼格式、私鑰、以及其他 metadata。這個設定主要是要讓 cert-manager 知道所要使用的 CA 是什麼 (像這邊就是使用 selfsigned)，還有要管理的域名以及驗證的方法，設定好這些之後，下一個步驟要申請 Certificate 的時候就可以直接引用它
  - certificaterequest (憑證要求)：這是一個 namespace 資源，用於向 issuer 請求 X.509 憑證。它包含一個經過 base64 編碼的 PEM 格式憑證簽章請求(CSR)。

## 安裝 cert-manager
* 安裝 cert-manager crd
```
$ kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.crds.yaml
```
* 透過 helm 安裝 cert-manager v1.11.0
```
$ helm repo add jetstack https://charts.jetstack.io

$ helm repo update

$ helm install cert-manager jetstack/cert-manager \
--namespace cert-manager \
--create-namespace \
--version v1.11.0
```
```
$ kubectl get pods --namespace cert-manager
NAME                                     READY   STATUS    RESTARTS   AGE
cert-manager-76d44b459c-zhpp2            1/1     Running   0          32s
cert-manager-cainjector-9b679cc6-6tzd8   1/1     Running   0          32s
cert-manager-webhook-57c994b6b9-4dfvs    1/1     Running   0          32s
```
## 使用 cert-manager SelfSigned 部屬 Issuer
* 使用 issuer 建立 RootCA
```
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: selfsigned-issuer
  namespace: default
spec:
  selfSigned: {}
```
```
$ kubectl get issuer
NAME                READY   AGE
selfsigned-issuer           25s
```
* 透過 RootCA issuer 建立憑證
* 憑證有效期限 90 天，會在倒數第 30 天自動更換憑證
```
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: test-ca
  namespace: default
spec:
  isCA: true
  duration: 2160h             # 90d
  renewBefore: 720h           # 30d
  commonName: test-ca
  subject:
    organizations:
      - ACME Inc.
    organizationalUnits:
      - Widgets
  secretName: test-ca-secret
  privateKey:
    algorithm: ECDSA
    size: 256
  issuerRef:
    name: selfsigned-issuer
    kind: Issuer
    group: cert-manager.io
```
* 檢查創建的憑證與 secret
* 如果檢查發現建好 certificate 但並沒有產生 secret，可以把 cert-manager redeploy
```
$ kubectl get certificate -o wide
NAME      READY   SECRET           ISSUER              STATUS                                          AGE
test-ca   True    test-ca-secret   selfsigned-issuer   Certificate is up to date and has not expired   28s

$ kubectl get secret
NAME             TYPE                DATA   AGE
test-ca-secret   kubernetes.io/tls   3      12m
```
* 透過剛剛建立好的 RootCA secret 再次建立 Issuer
* 這個 test-ca-issuer 是要用來簽屬我們自己 ingress 的憑證
```
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: test-ca-issuer
  namespace: default
spec:
  ca:
    secretName: test-ca-secret
```
```
$ kubectl get issuer
NAME                READY   AGE
selfsigned-issuer   True    4m39s
test-ca-issuer      True    18s
```

## 使用 cert-manager Issuer 建立的憑證建立 ingress
* 需先設立好 domain 並要解析到 k8s 的 node
```
$ host test.example.com
test.example.com has address 192.168.11.130
```
* 建立測試用 nginx web
```
$ kubectl create deploy web --image=nginx --port=80
```
```
$ kubectl expose deploy web --name=svc-web --target-port=80 --port=80
```
* 檢查 ingressclass 名稱
* 需要 dns 解析 `test.example.com` 這個位置
```
$ kubectl get ingressClass
NAME    CONTROLLER             PARAMETERS   AGE
nginx   k8s.io/ingress-nginx   <none>       4d23h
```
* annotations 需要宣告使用哪個 issuer
* echo-cert 這個 secret 會再做出 ingress 後產生
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tls-nginx-ingress
  namespace: default
  annotations:
    # add an annotation indicating the issuer to use.
    cert-manager.io/issuer: test-ca-issuer
spec:
  ingressClassName: nginx
  tls:
  - hosts:
      - test.example.com
    secretName: echo-cert
  rules:
  - host: test.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: svc-web  
            port:
              number: 80
```
* 檢查 echo-cert secret 是否有產生
```
$ kubectl get secret
NAME             TYPE                DATA   AGE
echo-cert        kubernetes.io/tls   3      101s
test-ca-secret   kubernetes.io/tls   3      5m31s

$ kubectl get certificate -o wide
NAME        READY   SECRET           ISSUER              STATUS                                          AGE
echo-cert   True    echo-cert        test-ca-issuer      Certificate is up to date and has not expired   56s
test-ca     True    test-ca-secret   selfsigned-issuer   Certificate is up to date and has not expired   5m25s
```
## 將 cert-manager 簽的憑證匯入到 client 瀏覽器
* 將 ca.pem 匯入 Client 瀏覽器
```
$ kubectl get secret test-ca-secret -o jsonpath='{.data.ca\.crt}' | base64 -d > ca.pem
```

![image](https://hackmd.io/_uploads/ryVvjDpTp.png)

## 確認憑證是否自動更新
* 預設憑證有效期限 90 天，會在倒數第 30 天自動更換憑證
```
$ kubectl describe certificate echo-cert
Name:         echo-cert
Namespace:    default
Labels:       objectset.rio.cattle.io/hash=c35d8a4e136ecaab66ba320fcc233a0659968a07
Annotations:  <none>
API Version:  cert-manager.io/v1
Kind:         Certificate
Metadata:
  Creation Timestamp:  2024-03-27T05:05:01Z
  Generation:          1
  Owner References:
    API Version:           networking.k8s.io/v1
    Block Owner Deletion:  true
    Controller:            true
    Kind:                  Ingress
    Name:                  tls-nginx-ingress
    UID:                   86e5c293-ec2d-41dc-b113-dfb6f9c623ae
  Resource Version:        24484779
  UID:                     cbafc364-0ea3-4f26-b108-19851579b417
Spec:
  Dns Names:
    test.example.com
  Issuer Ref:
    Group:      cert-manager.io
    Kind:       Issuer
    Name:       test-ca-issuer
  Secret Name:  echo-cert
  Usages:
    digital signature
    key encipherment
Status:
  Conditions:
    Last Transition Time:  2024-03-27T05:05:01Z
    Message:               Certificate is up to date and has not expired
    Observed Generation:   1
    Reason:                Ready
    Status:                True
    Type:                  Ready
  Not After:               2024-06-25T05:05:00Z
  Not Before:              2024-03-27T05:05:00Z
  Renewal Time:            2024-05-26T05:05:00Z
  Revision:                1
Events:
  Type    Reason     Age   From                                       Message
  ----    ------     ----  ----                                       -------
  Normal  Issuing    7m3s  cert-manager-certificates-trigger          Issuing certificate as Secret does not exist
  Normal  Generated  7m3s  cert-manager-certificates-key-manager      Stored new private key in temporary Secret resource "echo-cert-glsbl"
  Normal  Requested  7m3s  cert-manager-certificates-request-manager  Created new CertificateRequest resource "echo-cert-s5rjz"
  Normal  Issuing    7m3s  cert-manager-certificates-issuing          The certificate has been successfully issued
```
## 手動更新憑證
### 安裝 cmctl
```
$ curl -fsSL -o cmctl.tar.gz https://github.com/cert-manager/cert-manager/releases/latest/download/cmctl-linux-amd64.tar.gz && tar xzf cmctl.tar.gz && sudo mv cmctl /usr/local/bin
```
* 檢查 ingress 當前憑證有效日期
```
$ echo | openssl s_client -connect `kubectl get ing tls-nginx-ingress --no-headers -o custom-columns=HOSTS:.spec.rules[*].host`:443 2>/dev/null | openssl x509 -noout -dates
notBefore=Mar 27 05:05:00 2024 GMT
notAfter=Jun 25 05:05:00 2024 GMT
```

* 手動更新 ingress `echo-cert` 憑證
```
$ cmctl renew echo-cert
Manually triggered issuance of Certificate default/echo-cert

# 確認 ingress 憑證已更新
$ echo | openssl s_client -connect `kubectl get ing tls-nginx-ingress --no-headers -o custom-columns=HOSTS:.spec.rules[*].host`:443 2>/dev/null | openssl x509 -noout -dates
notBefore=Mar 27 05:17:08 2024 GMT
notAfter=Jun 25 05:17:08 2024 GMT

$ kubectl get certificaterequest
NAME              APPROVED   DENIED   READY   ISSUER              REQUESTOR                                         AGE
echo-cert-5smc6   True                True    test-ca-issuer      system:serviceaccount:cert-manager:cert-manager   103s
echo-cert-s5rjz   True                True    test-ca-issuer      system:serviceaccount:cert-manager:cert-manager   13m
test-ca-nfndn     True                True    selfsigned-issuer   system:serviceaccount:cert-manager:cert-manager   14m
```
* 檢查 ingress `echo-cert` 憑證狀態
```
$ cmctl status certificate echo-cert
Name: echo-cert
Namespace: default
Created at: 2024-03-27T13:05:01+08:00
Conditions:
  Ready: True, Reason: Ready, Message: Certificate is up to date and has not expired
DNS Names:
- test.example.com
Events:
  Type    Reason     Age               From                                       Message
  ----    ------     ----              ----                                       -------
  Normal  Issuing    16m               cert-manager-certificates-trigger          Issuing certificate as Secret does not exist
  Normal  Generated  16m               cert-manager-certificates-key-manager      Stored new private key in temporary Secret resource "echo-cert-glsbl"
  Normal  Requested  16m               cert-manager-certificates-request-manager  Created new CertificateRequest resource "echo-cert-s5rjz"
  Normal  Reused     4m1s              cert-manager-certificates-key-manager      Reusing private key stored in existing Secret resource "echo-cert"
  Normal  Issuing    4m (x2 over 16m)  cert-manager-certificates-issuing          The certificate has been successfully issued
  Normal  Requested  4m                cert-manager-certificates-request-manager  Created new CertificateRequest resource "echo-cert-5smc6"
Issuer:
  Name: test-ca-issuer
  Kind: Issuer
  Conditions:
    Ready: True, Reason: KeyPairVerified, Message: Signing CA verified
  Events:
    Type    Reason           Age                From                  Message
    ----    ------           ----               ----                  -------
    Normal  KeyPairVerified  16m (x2 over 16m)  cert-manager-issuers  Signing CA verified
Secret:
  Name: echo-cert
  Issuer Country:
  Issuer Organisation: ACME Inc.
  Issuer Common Name: test-ca
  Key Usage: Digital Signature, Key Encipherment
  Extended Key Usages:
  Public Key Algorithm: RSA
  Signature Algorithm: ECDSA-SHA256
  Subject Key ID:
  Authority Key ID: b2691202864a62e5393a7a17b46883c72cb3c7d8
  Serial Number: c6d2596773d531bf39e8b258fb776002
  Events:  <none>
Not Before: 2024-03-27T13:17:08+08:00
Not After: 2024-06-25T13:17:08+08:00
Renewal Time: 2024-05-26T13:17:08+08:00       # 下次自動更新憑證日期
No CertificateRequest found for this Certificate
```
* 檢查 ingress `echo-cert` 憑證唯一識別代號(身分證)
```
$ cmctl inspect -v secret echo-cert
Valid for:
        DNS Names:
                - test.example.com
        URIs: <none>
        IP Addresses: <none>
        Email Addresses: <none>
        Usages:
                - digital signature
                - key encipherment

Validity period:
        Not Before: Wed, 27 Mar 2024 05:17:08 UTC
        Not After: Tue, 25 Jun 2024 05:17:08 UTC

Issued By:
        Common Name:    test-ca
        Organization:   test-ca
        OrganizationalUnit:     ACME Inc.
        Country:        <none>

Issued For:
        Common Name:    <none>
        Organization:   <none>
        OrganizationalUnit:     <none>
        Country:        <none>

Certificate:
        Signing Algorithm:      ECDSA-SHA256
        Public Key Algorithm:   RSA
        Serial Number:  264279338836509632857330864363742388226          
        Fingerprints:   73:81:6C:FE:4F:70:2F:02:47:D0:F3:70:0A:DC:97:C7:35:77:25:92:53:30:FF:D7:4C:91:20:BD:7B:DD:6C:59        # 這是憑證唯一識別代號(身分證)，這個識別碼不可能重複
        Is a CA certificate: false
        CRL:    <none>
        OCSP:   <none>

Debugging:
        Trusted by this computer:       no: x509: certificate signed by unknown authority
        CRL Status:     No CRL endpoints set
        OCSP Status:    Cannot check OCSP: No OCSP Server set
```
