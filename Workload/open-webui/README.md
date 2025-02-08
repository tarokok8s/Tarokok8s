# open-webui
## Environment Preparation
The local-path storageclass needs to be installed first.

## Install open-webui
```
$ curl https://raw.githubusercontent.com/tarokok8s/Tarokok8s/refs/heads/main/Workload/open-webui/open-webui.yaml | kubectl apply -f -
```
```
$ kubectl -n ollama get all
NAME                        READY   STATUS    RESTARTS   AGE
pod/ollama-0                1/1     Running   0          8m9s
pod/webui-cf476874b-d4jkj   2/2     Running   0          8m9s

NAME             TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
service/ollama   ClusterIP   None           <none>        11434/TCP        8m9s
service/webui    NodePort    10.98.16.237   <none>        3000:30404/TCP   8m9s

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/webui   1/1     1            1           8m9s

NAME                              DESIRED   CURRENT   READY   AGE
replicaset.apps/webui-cf476874b   1         1         1       8m9s

NAME                      READY   AGE
statefulset.apps/ollama   1/1     8m9s
```
