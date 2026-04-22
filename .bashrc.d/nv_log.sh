alias kgd="kubectl get DaemonSet neuvector-enforcer-pod -n neuvector -o yaml > dp.yaml && vim dp.yaml && kubectl apply -f dp.yaml -n neuvector "
alias kgc="kubectl get deployment neuvector-controller-pod -n neuvector  -o yaml > dpC.yaml && vim dpC.yaml && kubectl apply -f dpC.yaml -n neuvector "
alias kgs="kubectl get deployment neuvector-scanner-pod -n neuvector  -o yaml > dpS.yaml && vim dpS.yaml && kubectl apply -f dpS.yaml -n neuvector "
alias kge="kubectl get DaemonSet neuvector-enforcer-pod -n neuvector  -o yaml > dpE.yaml && vim dpE.yaml && kubectl apply -f dpE.yaml -n neuvector "

alias kde="kubectl delete pod -n neuvector -l app=neuvector-enforcer-pod"
alias kdc="kubectl delete pod -n neuvector -l app=neuvector-controller-pod"
alias kds="kubectl delete pod -n neuvector -l app=neuvector-scanner-pod"

alias kle="kubectl logs -f -n neuvector -l app=neuvector-enforcer-pod"
alias klc="kubectl logs -f -n neuvector -l app=neuvector-controller-pod"
alias kls="kubectl logs -f -n neuvector -l app=neuvector-scanner-pod"

alias ld="kubectl get pod -n neuvector -l app=neuvector-enforcer-pod"
alias ldo="kubectl get pod -n neuvector -l app=neuvector-enforcer-pod -o wide"
alias lc="kubectl get pod -n neuvector -l app=neuvector-controller-pod"

klogs() {
  if [ -z "$1" ]; then
    echo "Usage: klogs <pod-name>"
    return 1
  fi
  kubectl logs -n neuvector "$1" | grep 'XXX'
}
alias l=klogs

kexec() {
  if [ -z "$1" ]; then
    echo "Usage: klogs <pod-name>"
    return 1
  fi
  kubectl exec -it -n neuvector "$1" sh
}
alias ke=kexec

klog() {
  if [ -z "$1" ]; then
    echo "Usage: klogs <pod-name>"
    return 1
  fi
  kubectl logs -n neuvector "$1"
}
alias kl=klog
