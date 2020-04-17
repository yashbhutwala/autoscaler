#!/bin/bash

# https://news.ycombinator.com/item?id=10736584
set -o errexit -o nounset -o pipefail
# this line enables debugging
#set -xv

# parameters
# only if namespace is provided will namespace be used
NAMESPACE="${1:-"no"}"

# deploy crd regardless of cluster scoped/any namespaces
kubectl apply -f "./vpa-v1-crd.yaml"

if [ $NAMESPACE = "no" ]; then
  # deploy cluster scoped
  kubectl apply -f "./cluster-scoped/"
else
  deployment="./namespace-scoped/recommender-deployment.yaml"
  rbac="./namespace-scoped/recommender-ns-rbac.yaml"

  # 1. service account and deployment
  sed "s/\$NAMESPACE/$NAMESPACE/g" ${deployment} | kubectl apply -n $NAMESPACE -f -
  # 2. rbac
  sed "s/\$NAMESPACE/$NAMESPACE/g" ${rbac} | kubectl apply -n $NAMESPACE -f -
fi
