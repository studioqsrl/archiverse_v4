#!/bin/bash

# System pool
az aks nodepool add \
  --name systempool \
  --cluster-name archiverse \
  --resource-group archiverse \
  --mode System \
  --node-count 1 \
  --node-vm-size Standard_B2ps_v2 \
  --kubernetes-version 1.30.7 \
  --zones 1 \
  --max-pods 110 \
  --node-osdisk-size 64 \
  --labels nodepool=system-pool

# Frontend pool
az aks nodepool add \
  --name frontendpool \
  --cluster-name archiverse \
  --resource-group archiverse \
  --mode User \
  --node-count 2 \
  --node-vm-size Standard_B2ps_v2 \
  --kubernetes-version 1.30.7 \
  --zones 1 2 \
  --max-pods 110 \
  --node-osdisk-size 64 \
  --labels nodepool=frontend-pool \
  --node-taints "workload=frontend:NoSchedule" \
  --enable-cluster-autoscaler \
  --min-count 2 \
  --max-count 5

# Backend pool
az aks nodepool add \
  --name backendpool \
  --cluster-name archiverse \
  --resource-group archiverse \
  --mode User \
  --node-count 2 \
  --node-vm-size Standard_B2ps_v2 \
  --kubernetes-version 1.30.7 \
  --zones 1 2 \
  --max-pods 110 \
  --node-osdisk-size 64 \
  --labels nodepool=backend-pool \
  --node-taints "workload=appservice:NoSchedule" \
  --enable-cluster-autoscaler \
  --min-count 2 \
  --max-count 5

# DB pool
az aks nodepool add \
  --name dbpool \
  --cluster-name archiverse \
  --resource-group archiverse \
  --mode User \
  --node-count 1 \
  --node-vm-size Standard_B2ps_v2 \
  --kubernetes-version 1.30.7 \
  --zones 1 \
  --max-pods 110 \
  --node-osdisk-size 64 \
  --labels nodepool=db-pool \
  --node-taints "workload=postgres:NoSchedule"
