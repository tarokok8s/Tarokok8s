#!/bin/bash

echo "Install Argo CD..."

kubectl apply -k argocd &>/dev/null
kubectl wait -n argocd --for=condition=Ready pod --timeout=360s -l app.kubernetes.io/name=argocd-application-controller
kubectl wait -n argocd --for=condition=Ready pod --timeout=360s -l app.kubernetes.io/name=argocd-applicationset-controller
kubectl wait -n argocd --for=condition=Ready pod --timeout=360s -l app.kubernetes.io/name=argocd-dex-server
kubectl wait -n argocd --for=condition=Ready pod --timeout=360s -l app.kubernetes.io/name=argocd-notifications-controller
kubectl wait -n argocd --for=condition=Ready pod --timeout=360s -l app.kubernetes.io/name=argocd-redis
kubectl wait -n argocd --for=condition=Ready pod --timeout=360s -l app.kubernetes.io/name=argocd-repo-server
kubectl wait -n argocd --for=condition=Ready pod --timeout=360s -l app.kubernetes.io/name=argocd-server

# Install Argo CD CLI
VERSION=$(curl -L -s https://raw.githubusercontent.com/argoproj/argo-cd/stable/VERSION)
curl -sSL -o argocd-linux-amd64 "https://github.com/argoproj/argo-cd/releases/download/v$VERSION/argocd-linux-amd64"
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

argocd login argocd-server.argocd --insecure --username admin --password Argo12345
# ssh-keyscan -p 22100 kadm.kube-system | argocd cert add-ssh --batch 
argocd repocreds add ssh://bigred@kadm.kube-system:22100/home/bigred --ssh-private-key-path ~/.ssh/id_rsa
argocd repo add ssh://bigred@kadm.kube-system:22100/home/bigred/gitops --insecure-skip-server-verification

kubectl apply -f apps/argocd.yaml &>/dev/null

mc mb -p mios/workflows

# Install Argo Workflows CLI
VERSION=$(curl -s https://api.github.com/repos/argoproj/argo-workflows/releases/latest | jq -r .tag_name)
url="https://github.com/argoproj/argo-workflows/releases/download/${VERSION}/argo-linux-amd64.gz"
curl -sSLO "${url}"
gunzip argo-linux-amd64.gz &>/dev/null
sudo install -m 555 argo-linux-amd64 /usr/local/bin/argo
rm argo-linux-amd64

kubectl create secret generic git-cred \
    --from-file=privateKey=/home/bigred/.ssh/id_rsa \
    -n argo





kubectl label "$(kubectl get node -o name | grep control)" "node=jenkins"