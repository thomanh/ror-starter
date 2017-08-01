#!/bin/bash

set -e

# see: https://github.com/kubernetes/helm/issues/2223#issuecomment-304866056
# make sure this container has privileged=true on the gitlab runner config
sysctl net.ipv6.conf.all.disable_ipv6=0

helm init

helm version

# helm repo add stable https://kubernetes-charts.storage.googleapis.com

helm dependency update $HELM_CHART

# should normalize the helm release name
IMG_TAG=`echo $IMG_TAG | sed 's/features\/#//g'`
count=0
IMG_TAG=`for ((i=0;i<${#IMG_TAG};i++)); do [[ "${IMG_TAG:$i:1}" =~ [0-9]|[a-Z] ]] && [[ $((++count)) -eq 5 ]] && echo "${IMG_TAG:0:$((i+1))}"; done`
HELM_RELEASE_NAME=$IMG_TAG-${PROJECT_NAMESPACE:0:5}-${PROJECT_NAME:0:5}

#
echo "helm upgrade $HELM_RELEASE_NAME --install $HELM_CHART"

helm upgrade $HELM_RELEASE_NAME --install $HELM_CHART \
  --set image.repository=$HELM_IMAGE_REPOSITORY,image.tag=$HELM_IMAGE_TAG,image.pullPolicy=$HELM_IMAGE_PULL_POLICY,image.lastDeployed=$HELM_IMAGE_LAST_DEPLOYED \
  --set app.secretKeyBase=$SECRET_KEY_BASE
