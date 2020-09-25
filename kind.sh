#!/bin/bash

set -u

: "${GITHUB_USERNAME:=masseybradley}"
: "${GITHUB_TOKEN:?Missing GitHub credentials}}"
: "${GITHUB_OWNER:=lazybit-ch}"
: "${GITHUB_REPOSITORY:=example.com}"
: "${DOCKER_USERNAME:=masseybradley}"
: "${DOCKER_PASSWORD:?Missing Docker Registry credentials}"

# [ -n "$DOCKER_PASSWORD" ] || echo "Missing docker credentials" && exit 1
# [ -n "$GITHUB_TOKEN" ] || echo "Missing github credentials" && exit 1

# Create the Kubernetes in Docker cluster
cat <<EOF | sudo kind create cluster --config=-
apiVersion: kind.x-k8s.io/v1alpha4
kind: Cluster
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
        authorization-mode: "AlwaysAllow"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
- role: worker
- role: worker
EOF

# Install the nfs-server-provisioner
helm repo add stable https://kubernetes-charts.storage.googleapis.com
helm repo update
helm upgrade --install nfs-server \
    --set persistence.enabled=true \
    --set persistence.size=10Gi \
    --set persistence.storageClass=standard \
    --set storageClass.defaultClass=true \
    --set storageClass.name=nfs-client \
    --set storageClass.mountOptions[0]="vers=4" \
    stable/nfs-server-provisioner \
    --wait

# Create a docker-registry secret to pull docker images
# Requires a personal access token with read:packages privileges
kubectl create secret docker-registry docker-0 \
    --docker-username=${DOCKER_USERNAME} \
    --docker-password=${DOCKER_PASSWORD} \
    --docker-server=ghcr.io

# Create an Opaque secret with docker credentials for accessing private docker registries
kubectl create secret generic docker --from-file=${HOME}/.docker/config.json

# github.password requires a personal access token with `repo:read` privileges
helm repo add lazybit https://chartmuseum.lazybit.ch
helm repo update
helm upgrade --install actions-runner \
    --set global.image.pullSecrets[0]=docker-0 \
    --set global.storageClass=nfs-client \
    --set github.username=${GITHUB_USERNAME} \
    --set github.password=${GITHUB_TOKEN} \
    --set github.owner=${GITHUB_OWNER} \
    --set github.repository=${GITHUB_REPOSITORY} \
    --set docker=docker \
    --set rbac.create=true \
    --set persistence.enabled=true \
    --set persistence.certs.existingClaim=certs-actions-runner-dind-0 \
    --set persistence.workspace.existingClaim=workspace-actions-runner-dind-0 \
    --set dind.experimental=true \
    --set dind.kaniko=true \
    --set dind.debug=true \
    --set dind.metrics.enabled=true \
    --set dind.metrics.address="0.0.0.0" \
    --set dind.metrics.port="9323" \
    --set dind.persistence.enabled=true \
    --set dind.persistence.certs.accessModes[0]=ReadWriteMany \
    --set dind.persistence.certs.size=1Gi \
    --set dind.persistence.workspace.accessModes[0]=ReadWriteMany \
    --set dind.persistence.workspace.size=8Gi \
    --set dind.resources.requests.memory="1Gi" \
    --set dind.resources.requests.cpu="1" \
    --set dind.resources.limits.memory="2Gi" \
    --set dind.resources.limits.cpu="2" \
    --set dind.livenessProbe.enabled=false \
    --set dind.readinessProbe.enabled=false \
    lazybit/actions-runner \
    --wait
