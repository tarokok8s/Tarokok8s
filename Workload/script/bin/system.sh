export POD_NAMESPACE=default
export KUBERNETES_SERVICE_PORT=443
export KUBERNETES_SERVICE_HOST=kubernetes.default
export KUBERNETES_SERVICE_PORT_HTTPS=443
export TALOSCONFIG=/home/bigred/wulin/talosconfig
export NOW="--force --grace-period 0"

alias kg='kubectl get'
alias ka='kubectl apply'
alias kd='kubectl delete'
alias kt='kubectl top'
alias ks='kubectl get all -n kube-system'
alias kt='kubectl top'
alias kk='kubectl krew'
alias kp="kubectl get pods -o wide -A | sed 's/(.*)//' | tr -s ' ' | cut -d ' ' -f 1-4,7,8 | column -t"
alias dkimg='curl -X GET -s -u bigred:bigred http://172.22.1.11:5000/v2/_catalog | jq ".repositories[]"'
alias kgip="kubectl get pod --template '{{.status.podIP}}'"

export PS1='\u@\h:\w$ '
alias pingdup='sudo arping -D -I eth0 -c 2 '
alias ping='ping -c 4'
alias dir='ls -alh'
alias docker='sudo /usr/bin/podman'

if [ "$USER" == "bigred" ]; then
   mkdir -p ~/wulin/yaml
   sudo chown -R bigred:wheel /home/bigred/

   if [ ! -d /home/bigred/.krew ]; then
      kubectl krew install directpv &>/dev/null
      [ "$?" == "0" ] && echo "kubectl directpv ok"
   fi
   
   mc config host ls | grep tk8s &>/dev/null
   if [ "$?" != "0" ]; then
      mc config host add tk8s http://minio.kube-system:9000 minio minio123 &>/dev/null
      mc admin config set tk8s storage_class standard=EC:1 &>/dev/null
      [ "$?" == "0" ] && echo "tk8s ok"
   fi

   mc config host ls | grep mios &>/dev/null
   if [ "$?" != "0" ]; then
      mc config host add mios http://miniosnsd.kube-system:9000 minio minio123 &>/dev/null
      mc admin config set mios storage_class standard=EC:1 &>/dev/null
      [ "$?" == "0" ] && echo "mios ok"
   fi

   kubectl get pod -A --field-selector=status.phase==Succeeded 2>/dev/null | grep Completed &>/dev/null
   if [ "$?" == "0" ]; then
      kubectl delete pod -A --field-selector=status.phase==Succeeded &>/dev/null
      [ "$?" == "0" ] && echo "delete all completed pods"

      kubectl delete pod -A --field-selector=status.phase==Failed &>/dev/null
      [ "$?" == "0" ] && echo "delete all errored pods"
      echo ""
   fi
fi
