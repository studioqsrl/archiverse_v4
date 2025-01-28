#!/bin/bash

# Monitor Flux resources
echo "Monitoring Flux GitOps resources..."
kubectl get gitrepositories.source.toolkit.fluxcd.io -n flux-system -w &
kubectl get kustomizations.kustomize.toolkit.fluxcd.io -n flux-system -w &
kubectl get imagerepositories.image.toolkit.fluxcd.io -n flux-system -w &
kubectl get imageupdateautomations.image.toolkit.fluxcd.io -n flux-system -w &

echo "Monitoring Flux reconciliation..."
kubectl get helmreleases -n flux-system -w &
flux get all -A &

echo "Monitoring deployment status..."
kubectl get deployments -n archiverse -w &
kubectl get pods -n archiverse -w &

echo "Monitoring cluster health..."
while true; do
  clear
  echo "=== Node Status ==="
  kubectl get nodes
  echo
  echo "=== Flux System Pods ==="
  kubectl get pods -n flux-system
  echo
  echo "=== Application Pods ==="
  kubectl get pods -n archiverse
  echo
  echo "=== Non-Running Pods (All Namespaces) ==="
  kubectl get pods -A | grep -v Running
  sleep 5
done &

# Cleanup background processes on script exit
trap "kill 0" EXIT
