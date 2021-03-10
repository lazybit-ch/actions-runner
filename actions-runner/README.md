# GitHub Actions Runner

[GitHub Actions Runner](https://github.com/actions/runner) for running self-hosted jobs from a [GitHub Actions](https://github.com/features/actions) workflow.

## TL;DR;

```console
$ helm repo add lazybit https://chartmuseum.lazybit.ch
$ helm repo update
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
| `global.image.pullPolicy` | Global docker image pull policy | `""` |
| `global.image.pullSecrets` | Global docker image pull secrets | `[]` |
| `global.image.tag` | Global docker image tag | `""` |
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Github Actions Runner image registry | `lazybit/actions-runner` |
| `image.pullPolicy` | Docker image pull policy | `IfNotPresent` |
| `image.pullSecrets` | Docker image pull secrets | `[]` |
| `image.tag` | Docker image tag | `""` |
| `nameOverride` | String to partially override actions-runner.fullname template with a string (will prepend the release name) | `""` |
| `fullnameOverride` | String to fully override actions-runner.fullname template with a string | `""` |
| `serviceAccount.create` | Create service account | `true` |
| `serviceAccount.annotations` | Annotations for service account | `{}` |
| `serviceAccount.name` | Name of the service account to use | `""` |
| `podAnnotations` | Map of annotations to add to the pod | `{}` |
| `podSecurityContext.runAsUser` | User ID for the container | `1000` |
| `podSecurityContext.runAsGroup` | Group ID for the container | `1000` |
| `podSecurityContext.fsGroup` | File system group ID for the container | `1000` |
| `securityContext` | Map of privileges and access control settings for a Pod | `{}` |
| `resources` | Map of allocated resources | `{}` |
| `autoscaling.enabled` | Enable horizontal pod autoscaling | `false` |
| `autoscaling.minReplicas` | Minimum autoscaling replicas | `1` |
| `autoscaling.maxReplicas` | Maximum autoscaling replicas | `100` |
| `autoscaling.targetCPUUtilizationPercentage` | Autoscaling CPU utilization threshold | `80` |
| `nodeSelector` | Map of node labels for pod assignment | `{}` |
| `tolerations` | Toleration labels for pod assignment | `[]` |
| `affinity` | Map of affinity labels for pod assignment | `{}` |
| `github.username` | Github username | `""` |
| `github.password` | Github password | `""` |
| `github.organization` | Github organization | `""` |
| `github.repository` | Github repository | `""` |
| `existingSecret` | Existing secret with Github credentials | `false` |
| `existingSecretName` | Existing secret with Github credentials name | `""` |
| `docker` | Mount docker config.json from secret | `false` |
| `dockerSecretName` | Docker secret name to mount (default: `docker` if `docker=true`) | `""` |
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
    --set docker=true \
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
