#!/bin/bash

set -e

# see: https://github.com/kubernetes/helm/issues/2223#issuecomment-304866056
# make sure this container has privileged=true on the gitlab runner config
sysctl net.ipv6.conf.all.disable_ipv6=0

helm init

helm version

# helm repo add stable https://kubernetes-charts.storage.googleapis.com

helm dependency update $HELM_CHART

HELM_RELEASE_NAME=${IMG_TAG:0:5}-${PROJECT_NAMESPACE:0:5}-${PROJECT_NAME:0:5}
echo "helm upgrade $HELM_RELEASE_NAME --install $HELM_CHART"

helm upgrade $HELM_RELEASE_NAME --install $HELM_CHART \
  --set image.repository=$HELM_IMAGE_REPOSITORY,image.tag=$HELM_IMAGE_TAG,image.pullPolicy=$HELM_IMAGE_PULL_POLICY,image.lastDeployed=$HELM_IMAGE_LAST_DEPLOYED \
  --set app.secretKeyBase=$SECRET_KEY_BASE
