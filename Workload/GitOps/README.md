# GitOps

```bash
git clone https://github.com/tarokok8s/Tarokok8s.git && sudo rm -rf .git && mv Tarokok8s/Workload/GitOps/ ~/gitops
cd ~/gitops && git init && git add -A && git commit -m "init repo"

./bootstrap.sh
```