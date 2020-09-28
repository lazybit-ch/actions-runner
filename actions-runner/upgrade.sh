#!/bin/bash

# helm repo add lazybit https://chartmuseum.lazybit.ch \
#     --username=${CHARTMUSEUM_USERNAME} \
#     --password=${CHARTMUSEUM_PASSWORD}
# helm repo update
# helm dependency update
helm upgrade --install actions-runner \
    --set global.storageClass=nfs-client \
    --set github.username=${GITHUB_USERNAME} \
    --set github.password=${GITHUB_TOKEN} \
    --set github.owner=${GITHUB_OWNER} \
    --set github.repository=${GITHUB_REPOSITORY} \
    --set docker=true \
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
    --dry-run \
    . \
    --wait
