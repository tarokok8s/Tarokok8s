# README

## Apply xkadm

```bash
$ kubectl apply -f https://raw.githubusercontent.com/tarokok8s/Tarokok8s/main/examples/xkadm/xkadm.yaml

# wait
$ kubectl wait -n kube-system pod -l app=kube-xkadm --for=condition=Ready --timeout=360s
```

## Create VcXsrv

```bash
# on kind
$ sudo podman rmi quay.io/flysangel/image:x.vcxsrv-v1.0.0 &>/dev/null; sudo podman run -it --rm --net=host quay.io/flysangel/image:x.vcxsrv-v1.0.0
Trying to pull quay.io/flysangel/image:x.vcxsrv-v1.0.0...
Getting image source signatures
Copying blob 8134e0a75af3 done   |
Copying blob 27c049f4d39b done   |
Copying blob 4abcf2066143 done   |
Copying config 29a1db0bec done   |
Writing manifest to image destination

Pluse use windows cmd run
powershell -command "irm http://172.20.0.154:5566/zip | iex"
```

## Windows connect

```bash
# cmd
> powershell -command "irm http://172.20.0.154:5566/zip | iex"

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d-----       2024/9/19  下午 11:39                bin
d-----       2024/9/19  下午 11:39                hack
d-----       2024/9/19  下午 11:39                terminal
d-----       2024/9/19  下午 11:39                vcxsrv
-a----       2024/9/19  下午 11:38            120 env.bat
-a----       2024/8/25  上午 11:57            628 runTerminal.bat
-a----       2024/9/19  下午 09:39            451 startLxqt.bat
-a----       2024/9/19  下午 11:17            611 stopLxqt.bat
-a----       2024/9/19  下午 09:39            269 testEnv.bat

> cd %userprofile%\VcXsrv

# start
> startLxqt.bat

# stop
> stopLxqt.bat
```
