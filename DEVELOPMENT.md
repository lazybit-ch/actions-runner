# Development

This repository contains the [GitHub Actions Runner](Dockerfile) image and
[Helm Chart](actions-runner) for deploying to
[Kubernetes](https://kubernetes.io/).

## Setup

We use [`docker`](https://www.docker.com/) for running
[`pre-commit`](https://hub.docker.com/r/lazybit/pre-commit) hooks configured for the repository and
[`kind`](https://kind.sigs.k8s.io/)>=[`v0.9.0`](https://github.com/kubernetes-sigs/kind/releases)
for bootstrapping local Kubernetes clusters.

### pre-commit

Add a [`pre-commit`](https://git-scm.com/docs/githooks#_pre_commit) hook in your local checkout
(`${PWD}/.git/hooks/pre-commit`) to run configured [pre-commit](.pre-commit-config.yaml) hooks
and lint the `Dockerfile` and Helm Chart:
```bash
docker run --rm -i \
    -v ${PWD}:/workspace/source \
    -w /workspace/source \
    lazybit/pre-commit run --all-files

ocker run --rm -i \
    -v ${PWD}:/workspace/source \
    -w /workspace/source \
    hadolint/hadolint < Dockerfile

docker run --rm -i \
    -v ${PWD}:/workspace/source \
    -w /workspace/source/actions-runner \
    lazybit/helm lint .
```

### kind

You can `kind create cluster` to deploy a Kubernetes in Docker cluster.

## Commit style guide

We use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/). The `CHANGELOG`
is created from the commit messages.

## Versioning

We use [Semantic Versioning](https://semver.org/) for releases.
