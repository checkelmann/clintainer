FROM ubuntu:19.10

LABEL maintainer="Christian Heckelmann <checkelmann@gmail.com>"

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y curl \
        jq \
        zsh \
        git \
        git-lfs \
        fonts-powerline \
        sudo \
        locales \
        apt-transport-https \
        gettext \
        fzf

RUN locale-gen en_US.UTF-8

RUN useradd -rm -d /home/operator -p "$(openssl passwd -1 operator)" -s /bin/bash -g root -G sudo -u 1001 operator
RUN echo "operator     ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER operator
WORKDIR /home/operator
# Install OhMyZsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

COPY .zshrc /home/operator

# Install BIT
RUN sudo curl -sf https://gobinaries.com/chriswalz/bit | sh; sudo curl -sf https://gobinaries.com/chriswalz/bit/bitcomplete | sh && echo y | sudo COMP_INSTALL=1 bitcomplete;

# Install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && sudo mv ./kubectl /usr/local/bin/kubectl

# Install keptn-cli
RUN curl -sL https://get.keptn.sh | sudo -E bash

# Install istioclt
RUN curl -sL https://istio.io/downloadIstioctl | sudo sh -

# Install helm3
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | sudo bash
# Adding zsh completion
RUN helm completion zsh > "${fpath[1]}/_helm"

# Install Openservicemesh cli
RUN OSM_RELEASE=$(curl --silent "https://api.github.com/repos/openservicemesh/osm/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') && \
    curl -L -o osm.tar.gz https://github.com/openservicemesh/osm/releases/download/$OSM_RELEASE/osm-$OSM_RELEASE-linux-amd64.tar.gz && \
    tar -xzvf osm.tar.gz && chmod +x linux-amd64/osm && sudo mv linux-amd64/osm /usr/local/bin/osm && rm -rf linux-amd64 osm.tar.gz

# Install eksctl
RUN curl -s --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp && \
    sudo mv /tmp/eksctl /usr/local/bin

# Install yq
RUN YQ_RELEASE=$(curl --silent "https://api.github.com/repos/mikefarah/yq/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') && \
    sudo curl -sL https://github.com/mikefarah/yq/releases/download/$YQ_RELEASE/yq_linux_amd64 -o /usr/local/bin/yq
RUN sudo chmod +x /usr/local/bin/yq

# k9s
RUN K9S_RELEASE=$(curl --silent "https://api.github.com/repos/derailed/k9s/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') && \
    curl -sL https://github.com/derailed/k9s/releases/download/$K9S_RELEASE/k9s_Linux_x86_64.tar.gz -o k9s.tar.gz && \
    tar -xzvf k9s.tar.gz && chmod +x k9s && sudo mv k9s /usr/local/bin && rm LICENSE README.md k9s.tar.gz

# kubectx & kubens
RUN KUBECTX_RELEASE=$(curl --silent "https://api.github.com/repos/ahmetb/kubectx/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') && \
    curl -sL https://github.com/ahmetb/kubectx/releases/download/$KUBECTX_RELEASE/kubectx_${KUBECTX_RELEASE}_linux_x86_64.tar.gz -o /tmp/kubectx.tar.gz && \
    tar -C /tmp -xzvf /tmp/kubectx.tar.gz && chmod +x /tmp/kubectx && sudo mv /tmp/kubectx /usr/local/bin && \
    curl -sL https://github.com/ahmetb/kubectx/releases/download/$KUBECTX_RELEASE/kubens_${KUBECTX_RELEASE}_linux_x86_64.tar.gz -o /tmp/kubens.tar.gz && \
    tar -C /tmp -xzvf /tmp/kubens.tar.gz && chmod +x /tmp/kubens && sudo mv /tmp/kubens /usr/local/bin && rm /tmp/LICENSE

CMD ["/usr/bin/zsh"]