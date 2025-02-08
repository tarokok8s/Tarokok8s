# open-webui
## Environment Preparation
The local-path storageclass needs to be installed first.

## Install open-webui
```
$ kubectl apply -f https://raw.githubusercontent.com/tarokok8s/Tarokok8s/refs/heads/main/Workload/open-webui/open-webui.yaml
```
```
$ kubectl -n llm-system get all
NAME                         READY   STATUS    RESTARTS   AGE
pod/ollama-0                 1/1     Running   0          8m16s
pod/webui-5c7c5cb896-vtrg9   2/2     Running   0          8m16s

NAME             TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)          AGE
service/ollama   ClusterIP   None          <none>        11434/TCP        8m17s
service/webui    NodePort    10.98.16.23   <none>        3000:32408/TCP   8m17s

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/webui   1/1     1            1           8m16s

NAME                               DESIRED   CURRENT   READY   AGE
replicaset.apps/webui-5c7c5cb896   1         1         1       8m16s

NAME                      READY   AGE
statefulset.apps/ollama   1/1     8m16s
```
## 登入 Open WebUI
* 預設帳密 : admin@tks.com/admin

![image](https://github.com/user-attachments/assets/6d6f47f2-764d-4610-9ac7-2e3267a10b3c)

![image](https://github.com/user-attachments/assets/06417e30-1822-4ed8-a1f7-155711a099b7)
