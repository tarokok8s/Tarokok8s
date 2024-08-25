# README

## Install

```bash
# https://kubevirt.io/user-guide/architecture/
# https://kubevirt.io/quickstart_kind/
# https://kubevirt.io/labs/kubernetes/lab1
$ VERSION=$(curl -s https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt)
$ kubectl apply -f https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt-operator.yaml
$ kubectl apply -f https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt-cr.yaml
$ kubectl get all -n kubevirt
NAME                               READY   STATUS    RESTARTS   AGE
virt-api-78cf8fd8b7-6zr2c          1/1     Running   0          2m30s
virt-api-78cf8fd8b7-gkk4w          1/1     Running   0          2m30s
virt-controller-5954cb4bd4-rhkt9   1/1     Running   0          2m5s
virt-controller-5954cb4bd4-wxbb6   1/1     Running   0          2m5s
virt-handler-46j9p                 1/1     Running   0          2m5s
virt-handler-jhptn                 1/1     Running   0          2m5s
virt-operator-7f65cd9ff9-4822h     1/1     Running   0          3m7s
virt-operator-7f65cd9ff9-fbwvp     1/1     Running   0          3m7s

# virtctl
$ curl -sL https://api.github.com/repos/kubevirt/kubevirt/releases/latest | jq -r .assets[].browser_download_url | grep 'linux-amd64'  -o virtctl

$ VERSION=$(kubectl get kubevirt.kubevirt.io/kubevirt -n kubevirt -o=jsonpath="{.status.observedKubeVirtVersion}")
$ curl -sL https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/virtctl-${VERSION}-linux-amd64 -o virtctl
$ sudo install -o root -g root -m 0755 virtctl /usr/local/bin/virtctl
$ rm -r virtctl*

# cdi
# https://kubevirt.io/labs/kubernetes/lab2
#$ VERSION=$(curl -sL https://api.github.com/repos/kubevirt/containerized-data-importer/releases/latest | jq -r .name)
#$ kubectl apply -f https://github.com/kubevirt/containerized-data-importer/releases/download/${VERSION}/cdi-operator.yaml
#$ kubectl apply -f https://github.com/kubevirt/containerized-data-importer/releases/download/${VERSION}/cdi-cr.yaml
```

## Windows VM

```bash
# https://kubevirt.io/2022/KubeVirt-installing_Microsoft_Windows_11_from_an_iso.html
# upload win10.iso
#$ virtctl image-upload \
#--uploadproxy-url=https://cdi-uploadproxy.cdi.svc.cluster.local:443 \
#--insecure \
#--pvc-name=w10-2021-ltsc-pvc \
#--image-path=./Downloads/W10_2021_LTSC.iso \
#--size=6Gi

# create iso pvc
$ echo 'apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  namespace: default
  name: w10-2021-ltsc-iso
spec:
  storageClassName: standard
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: 5Gi' | kubectl apply -f -

# download iso to pvc
$ echo 'apiVersion: v1
kind: Pod
metadata:
  namespace: default
  name: iso-image
  labels:
    app: iso-image # service selector
spec:
  containers:
    - name: iso-image
      image: quay.io/flysangel/image:alpine.base-v1.0.0
      command:
        - "/bin/bash"
        - "-c"
        - "wget https://web.flymks.com/iso/W10_2021_LTSC.iso -O /iso/disk.img; exit 0"
      volumeMounts:
        - name: iso-image
          mountPath: /iso
  volumes:
    - name: iso-image
      persistentVolumeClaim:
        claimName: w10-2021-ltsc-iso' | kubectl apply -f -

# delete pod
$ kubectl delete pod iso-image

# win10 disk (C:\)
$ echo 'apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  namespace: default
  name: w10-ltsc-test
spec:
  storageClassName: standard
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: 20Gi' | kubectl apply -f -

# win10 vm
$ echo 'apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  name: w10-ltsc-test
spec:
  running: false
  template:
    metadata:
      labels:
        vm: w10-ltsc-test
    spec:
      domain:
        cpu:
          cores: 2
          model: host-passthrough
        resources:
          requests:
            memory: 4Gi
        devices:
          interfaces:
            - name: default
              model: e1000
              bridge: {}
          disks:
            - bootOrder: 1
              name: w10-2021-ltsc-iso
              cdrom:
                bus: sata
            - bootOrder: 2
              name: w10-ltsc-test
              disk:
                bus: sata
      networks:
        - name: default
          pod: {}
      volumes:
        - name: w10-2021-ltsc-iso
          persistentVolumeClaim:
            claimName: w10-2021-ltsc-iso
        - name: w10-ltsc-test
          persistentVolumeClaim:
            claimName: w10-ltsc-test' | kubectl apply -f -

# start vm
$ virtctl start w10-ltsc-test

# check status
$ kubectl get vm
NAME            AGE   STATUS    READY
w10-ltsc-test   15s   Running   True

$ kubectl get pod
NAME                                READY   STATUS    RESTARTS   AGE
virt-launcher-w10-ltsc-test-bmq44   2/2     Running   0          59m

# vnc connect win10
# sudo apt install -y xtightvncviewer
$ virtctl vnc --proxy-only --address=0.0.0.0 --port=5901 w10-ltsc-test

# virtio
# https://pve.proxmox.com/wiki/Windows_VirtIO_Drivers
# https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/?C=M;O=D
```

## mint linux vm

```bash
# create iso pvc
$ echo 'apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  namespace: default
  name: mint-22-xfce-iso
spec:
  storageClassName: standard
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: 5Gi' | kubectl apply -f -

# download iso to pvc
$ echo 'apiVersion: v1
kind: Pod
metadata:
  namespace: default
  name: iso-image
  labels:
    app: iso-image # service selector
spec:
  containers:
    - name: iso-image
      image: quay.io/flysangel/image:alpine.base-v1.0.0
      command:
        - "/bin/bash"
        - "-c"
        - "wget https://web.flymks.com/iso/linuxmint-22-xfce-64bit.iso -O /iso/disk.img; exit 0"
      volumeMounts:
        - name: iso-image
          mountPath: /iso
  volumes:
    - name: iso-image
      persistentVolumeClaim:
        claimName: mint-22-xfce-iso' | kubectl apply -f -

# delete pod
$ kubectl delete pod iso-image

# mint linux disk (/)
$ echo 'apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  namespace: default
  name: mint-22-xfce-test
spec:
  storageClassName: standard
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: 20Gi' | kubectl apply -f -

# mint linux vm
$ echo 'apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  name: mint-22-xfce-test
spec:
  running: false
  template:
    metadata:
      labels:
        vm: mint-22-xfce-test
    spec:
      domain:
        cpu:
          cores: 2
          model: host-passthrough
        resources:
          requests:
            memory: 4Gi
        devices:
          interfaces:
            - name: default
              model: e1000
              bridge: {}
          disks:
            - bootOrder: 1
              name: mint-22-xfce-iso
              cdrom:
                bus: sata
            - bootOrder: 2
              name: mint-22-xfce-test
              disk:
                bus: sata
      networks:
        - name: default
          pod: {}
      volumes:
        - name: mint-22-xfce-iso
          persistentVolumeClaim:
            claimName: mint-22-xfce-iso
        - name: mint-22-xfce-test
          persistentVolumeClaim:
            claimName: mint-22-xfce-test' | kubectl apply -f -

# start vm
$ virtctl start mint-22-xfce-test

# check status
$ kubectl get vm
NAME                AGE   STATUS    READY
mint-22-xfce-test   18s   Running   True

$ kubectl get pod
NAME                                    READY   STATUS    RESTARTS   AGE
virt-launcher-mint-22-xfce-test-xr96c   2/2     Running   0          20s

# vnc connect win10
# sudo apt install -y xtightvncviewer
$ virtctl vnc --proxy-only --address=0.0.0.0 --port=5902 mint-22-xfce-test
```

## import alpine vmdk

```bash
# create vmdk pvc
$ echo 'apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  namespace: default
  name: alp-3202-test
spec:
  storageClassName: standard
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: 20Gi' | kubectl apply -f -

# download vmdk convert to qemu raw
$ echo 'apiVersion: v1
kind: Pod
metadata:
  namespace: default
  name: iso-image
  labels:
    app: iso-image # service selector
spec:
  containers:
    - name: iso-image
      image: quay.io/flysangel/image:alpine.qemu-v1.0.0
      command:
        - "/bin/bash"
        - "-c"
        - "wget https://web.flymks.com/vmdk/f-alp.vmdk; qemu-img convert -f vmdk -O raw f-alp.vmdk /disk/disk.img"
      volumeMounts:
        - name: alp-3202-test
          mountPath: /disk
  volumes:
    - name: alp-3202-test
      persistentVolumeClaim:
        claimName: alp-3202-test' | kubectl apply -f -

# delete pod
$ kubectl delete pod iso-image

# vmware alpine vmdk vm
$ echo 'apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  name: alp-3202-test
spec:
  running: false
  template:
    metadata:
      labels:
        vm: alp-3202-test
    spec:
      domain:
        cpu:
          cores: 2
          model: host-passthrough
        resources:
          requests:
            memory: 4Gi
        devices:
          interfaces:
            - name: default
              model: e1000
              bridge: {}
          disks:
            - bootOrder: 1
              name: alp-3202-test
              disk:
                bus: sata
      networks:
        - name: default
          pod: {}
      volumes:
        - name: alp-3202-test
          persistentVolumeClaim:
            claimName: alp-3202-test' | kubectl apply -f -

# start vm
$ virtctl start alp-3202-test

# check status
$ kubectl get vm
NAME                AGE     STATUS    READY
alp-3202-test       3m26s   Running   True

$ kubectl get pod
NAME                                    READY   STATUS    RESTARTS   AGE
virt-launcher-alp-3202-test-9rdck       2/2     Running   0          3m50s

# vnc proxy
$ virtctl vnc --proxy-only --address=0.0.0.0 --port=5903 alp-3202-test
```
