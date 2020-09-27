ARG UBUNTU_VERSION
FROM ubuntu:${UBUNTU_VERSION}

ARG GITHUB_ACTIONS_RUNNER_VERSION
ENV GITHUB_ACTIONS_RUNNER_VERSION=${GITHUB_ACTIONS_RUNNER_VERSION:-"2.273.2"}

ARG DOCKER_COMPOSE_VERSION
ENV DOCKER_COMPOSE_VERSION=${DOCKER_COMPOSE_VERSION:-"1.27.3"}

ARG KUBECTL_VERSION
ENV KUBECTL_VERSION=${KUBECTL_VERSION:-"1.19.0"}

ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        apt-transport-https=2.0.2ubuntu0.1 \
        ca-certificates=20190110ubuntu1.1 \
        curl=7.68.0-1ubuntu2.2 \
        gnupg-agent=2.2.19-3ubuntu2 \
        iputils-ping=3:20190709-3 \
        jq=1.6-1 \
        software-properties-common=0.98.9.2 && \
    apt-get clean && \
    rm -rf /var/cache/apt/lists/*

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        docker-ce=5:19.03.13~3-0~ubuntu-focal \
        docker-ce-cli=5:19.03.13~3-0~ubuntu-focal \
        containerd.io=1.3.7-1 && \
    apt-get clean && \
    rm -rf /var/cache/apt/lists/*

RUN curl -Lo /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod 755 /usr/local/bin/kubectl

RUN curl -Lo /usr/local/bin/docker-compose "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" && \
    chmod 755 /usr/local/bin/docker-compose

WORKDIR /opt/actions-runner
RUN curl -L "https://github.com/actions/runner/releases/download/v${GITHUB_ACTIONS_RUNNER_VERSION}/actions-runner-linux-x64-${GITHUB_ACTIONS_RUNNER_VERSION}.tar.gz" | tar xvz && \
    bash -x /opt/actions-runner/bin/installdependencies.sh

RUN groupadd -g 1000 actions-runner && \
    useradd -d /home/actions-runner -m -s /usr/bin/bash -k /etc/skel -u 1000 -g 1000 -G docker actions-runner && \
    chown -R 1000:1000 /opt/actions-runner

USER actions-runner
ENTRYPOINT ["/opt/actions-runner/run.sh"]
