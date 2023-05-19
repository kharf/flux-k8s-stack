#!/bin/sh
# Prerequisites
# - Container Engine (podman/docker)
# - github token to connect flux ssh key to (GITHUB_TOKEN)
# - github user to be used (GITHUB_USER)
# - url to the git repository (REPOSITORY_URL)
# - git branch (BRANCH)
# - name of the kind k8s cluster (CLUSTER_NAME)
# - Path to the Test Kustomization (KS_PATH)

# install flux
if [ ! -f /usr/local/bin/flux ]; then
  echo "Flux not installed, installing ..."
  curl -s https://fluxcd.io/install.sh | bash
fi

# install kind
if [ ! -f /usr/local/bin/kind ]; then
  echo "Kind not installed, installing ..."
  curl -Lo ./kind https://github.com/kubernetes-sigs/kind/releases/latest/download/kind-linux-amd64
  chmod +x ./kind
  sudo mv ./kind /usr/local/bin/kind
fi

# install kubectl
which kubectl
if [ $? -eq 1 ]; then
  echo "Kubectl not installed, installing ..."
  curl -Lo ./kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x ./kubectl
  sudo mv ./kubectl /usr/local/bin/kubectl
fi

# create k8s cluster
kind delete cluster --name $CLUSTER_NAME
kind create cluster --name $CLUSTER_NAME
CONTEXT=kind-$CLUSTER_NAME
kubectl cluster-info --context $CONTEXT

# install flux on k8s cluster
flux install \
--context=$CONTEXT

# create flux reconciliations
flux create source git flux-system \
--context=$CONTEXT \
--url=$REPOSITORY_URL \
--branch=$BRANCH \
--password=$GITHUB_TOKEN \
--username=$GITHUB_USER
flux create kustomization infrastructure \
--context=$CONTEXT \
--source=flux-system \
--path=$KS_PATH \
--prune=true \
--wait=true \
--health-check-timeout=4m

if [ $? -eq 0 ]
then
  exit 0
else
  kubectl get ks -A
  kubectl get hr -A
  kubectl get all -A
  kubectl get ingress -A
  exit 1
fi
