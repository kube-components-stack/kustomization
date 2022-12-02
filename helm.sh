#!/bin/bash

kubens kube-system

# helm ls --all

helm template \
  --debug \
  --name-template=kustomization \
  --namespace kube-system \
  --set env.fromValues.CLUSTER=plato \
  --set env.fromValues.ENV=devncoargo \
  deploy/charts/kustomization |yq e -P

# helm uninstall kustomization \
#   --namespace kube-system

helm upgrade \
  --install kustomization deploy/charts/kustomization \
  --namespace kube-system \
  --set env.fromValues.CLUSTER=plato \
  --set env.fromValues.ENV=devncoargo \
  -i