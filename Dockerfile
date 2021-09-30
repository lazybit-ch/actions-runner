ARG UBUNTU_VERSION
FROM ubuntu:${UBUNTU_VERSION}

ARG GITHUB_ACTIONS_RUNNER_VERSION
ENV GITHUB_ACTIONS_RUNNER_VERSION=${GITHUB_ACTIONS_RUNNER_VERSION:-"2.283.2"}

ARG DOCKER_COMPOSE_VERSION
ENV DOCKER_COMPOSE_VERSION=${DOCKER_COMPOSE_VERSION:-"1.29.2"}

ARG KUBECTL_VERSION
ENV KUBECTL_VERSION=${KUBECTL_VERSION:-"1.22.2"}

ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        apt-transport-https=2.0.2ubuntu0.2 \
        ca-certificates=20210119~20.04.2 \
        curl=7.68.0-1ubuntu2.7 \
        git=1:2.25.1-1ubuntu3.2 \
        gnupg-agent=2.2.19-3ubuntu2 \
        iputils-ping=3:20190709-3 \
        jq=1.6-1ubuntu0.20.04.1 \
        software-properties-common=0.98.9.5 && \
    apt-get clean && \
    rm -rf /var/cache/apt/lists/*

# hadolint ignore=DL3059
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        docker-ce=5:20.10.8~3-0~ubuntu-focal \
        docker-ce-cli=5:20.10.8~3-0~ubuntu-focal \
        containerd.io=1.4.9-1 && \
    apt-get clean && \
    rm -rf /var/cache/apt/lists/*

# hadolint ignore=DL3059
RUN curl -Lo /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod 755 /usr/local/bin/kubectl

# hadolint ignore=DL3059
RUN curl -Lo /usr/local/bin/docker-compose "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" && \
    chmod 755 /usr/local/bin/docker-compose

WORKDIR /opt/actions-runner
RUN curl -L "https://github.com/actions/runner/releases/download/v${GITHUB_ACTIONS_RUNNER_VERSION}/actions-runner-linux-x64-${GITHUB_ACTIONS_RUNNER_VERSION}.tar.gz" | tar xvz && \
    bash -x /opt/actions-runner/bin/installdependencies.sh

# hadolint ignore=DL3059
RUN groupadd -g 1000 actions-runner && \
    useradd -d /home/actions-runner -m -s /usr/bin/bash -k /etc/skel -u 1000 -g 1000 -G docker actions-runner && \
    chown -R 1000:1000 /opt/actions-runner

USER actions-runner
ENTRYPOINT ["/opt/actions-runner/run.sh"]
