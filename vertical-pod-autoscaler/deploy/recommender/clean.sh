#!/bin/bash

# https://news.ycombinator.com/item?id=10736584
# set -o errexit -o nounset -o pipefail
# this line enables debugging
#set -xv

# parameters
# only if namespace is provided will namespace be used
NAMESPACE="${1:-"no"}"
DELETE_CRD="${2:-"no"}"

if [ $NAMESPACE = "no" ]; then
  # deploy cluster scoped
  kubectl delete -f "./cluster-scoped/"
  # only delete crd if it is cluster scoped
  kubectl delete -f "./vpa-v1-crd.yaml"
else
  deployment="./namespace-scoped/recommender-deployment.yaml"
  rbac="./namespace-scoped/recommender-ns-rbac.yaml"

  # 1. service account and deployment
  sed "s/\$NAMESPACE/$NAMESPACE/g" ${deployment} | kubectl delete -n $NAMESPACE -f -
  # 2. rbac
  sed "s/\$NAMESPACE/$NAMESPACE/g" ${rbac} | kubectl delete -n $NAMESPACE -f -

  if [ $DELETE_CRD != "no" ]; then
    # in namespace scoped, delete crd if desired
    kubectl delete -f "./vpa-v1-crd.yaml"
  fi
fi
