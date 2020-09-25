# GitHub Actions Runner

[GitHub Actions Runner](https://github.com/actions/runner) for running self-hosted jobs from a [GitHub Actions](https://github.com/features/actions) workflow.

## TL;DR;

```console
$ helm repo add lazybit https://chartmuseum.lazybit.ch
$ helm install my-release lazybit/actions-runner --set global.image.pullSecrets[0]=docker-0
```

> **Tip**: Create a docker registry Secret with your Github Container Registry credentials i.e. `kubectl create secret docker-registry docker-0 --docker-username=${GITHUB_USERNAME} --docker-password=${GITHUB_TOKEN} --docker-server=ghcr.io`

## Introduction

This chart bootstraps a GitHub Actions Runner deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.14+
- Helm 3.0.3+

## Installing the Chart

To install the chart from the `lazybit` [ChartMuseum](https://chartmuseum.com/) repository with the release name `my-release`:

```console
$ helm install my-release lazybit/actions-runner
```

The command deploys the GitHub Actions Runner on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

The following tables lists the configurable parameters of the GitHub Actions Runner chart and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.image.pullPolicy` | | `""` |
| `global.image.pullSecrets` | | `[]` |
| `global.image.tag` | | `""` |
| `replicaCount` | | `1` |
| `image.repository` | | `ghcr.io/lazybit-ch/actions-runner` |
| `image.pullPolicy` | | `IfNotPresent` |
| `image.pullSecrets` | | `[]` |
| `image.tag` | | `""` |
| `nameOverride` | | `""` |
| `fullnameOverride` | | `""` |
| `serviceAccount.create` | | `true` |
| `serviceAccount.annotations` | | `{}` |
| `serviceAccount.name` | | |
| `podAnnotations` | | `{}` |
| `podSecurityContext` | | `{}` |
| `securityContext` | | `{}` |
| `service.type` | | `ClusterIP` |
| `service.port` | | `8080` |
| `ingress.enabled` | | `false` |
| `ingress.annotations` | | `{}` |
| `ingress.hosts[0].host` | | `chart-example.local` |
| `ingress.hosts[0].paths` | | `[]` |
| `ingress.tls` | | `[]` |
| `resources` | | `{}` |
| `autoscaling.enabled` | | `false` |
| `autoscaling.minReplicas` | | `1` |
| `autoscaling.maxReplicas` | | `100` |
| `autoscaling.targetCPUUtilizationPercentage` | | `80` |
| `nodeSelector` | | `{}` |
| `tolerations` | | `[]` |
| `affinity` | | `{}` |
| `github` | | `{}` |
| `existingSecret` | | `false` |
| `existingSecretName` | | `""` |
| `livenessProbe.enabled` | | `false` |
| `readinessProbe.enabled` | | `false` |
| `docker` | Docker secret name for pushing images | `""` |
| `dind.enabled` | Enable dependent Docker in Docker installation | `true` |

### Create secrets during the installation

```console
helm install my-release --set github.username=username --set github.password=token
```

> **Tip**: The Personal access token requires the `admin:org` and `repo` scopes.

### Example Installation

Create an Opaque Secret with credentials for interacting with your Docker Registry: `kubectl create secret generic docker --from-file=${HOME}/.docker/config.json`

```console
helm repo update
helm install actions-runner \
    --set global.image.pullSecrets[0]=docker-0 \
    --set global.storageClass=nfs-client \
    --set github.username=masseybradley \
    --set github.password=${GITHUB_TOKEN} \
    --set github.owner=lazybit-ch \
    --set github.repository=example.com \
    --set docker=docker \
    --set rbac.create=false \
    --set persistence.enabled=true \
    --set persistence.certs.existingClaim=certs-actions-runner-dind-0 \
    --set persistence.workspace.existingClaim=workspace-actions-runner-dind-0 \
    --set dind.experimental=true \
    --set dind.kaniko=false \
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
    lazybit/actions-runner
```

> **Tip**: Enable mounting the Opaque secret in the `dind` container for bind-mounting the `/kaniko/.docker/config.json` during a step by setting `dind.kaniko=true`..

> **Tip**: Enable rbac to grant permissions for creating pods during a steps execution.
