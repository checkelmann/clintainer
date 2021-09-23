FROM ubuntu:20.04

LABEL maintainer="Christian Heckelmann <checkelmann@gmail.com>"

RUN apt-get update && apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y curl \
        jq \
        zsh \
        git \
        git-lfs \
        fonts-powerline \
        sudo \
        locales \
        apt-transport-https \
        gettext \
        fzf \
        python3-pip

RUN locale-gen en_US.UTF-8

RUN useradd -rm -d /home/operator -p "$(openssl passwd -1 operator)" -s /bin/bash -g root -G sudo -u 1001 operator
RUN echo "operator     ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER operator
WORKDIR /home/operator
# Install OhMyZsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

COPY .zshrc /home/operator

# Install BIT
RUN sudo curl -sf https://gobinaries.com/chriswalz/bit | sh; echo y | sudo COMP_INSTALL=1 bit complete;

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
RUN /usr/local/bin/helm completion zsh > "/home/operator/.oh-my-zsh/plugins/git/_helm"

# Install Openservicemesh cli
RUN OSM_RELEASE=$(curl --silent "https://api.github.com/repos/openservicemesh/osm/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') && \
    curl -L -o osm.tar.gz https://github.com/openservicemesh/osm/releases/download/$OSM_RELEASE/osm-$OSM_RELEASE-linux-amd64.tar.gz && \
    tar -xzvf osm.tar.gz && chmod +x linux-amd64/osm && sudo mv linux-amd64/osm /usr/local/bin/osm && rm -rf linux-amd64 osm.tar.gz

# Install eksctl
RUN EKSCTL_RELEASE=$(curl --silent "https://api.github.com/repos/weaveworks/eksctl/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') && \
    curl -L -o eksctl.tar.gz https://github.com/weaveworks/eksctl/releases/download/$EKSCTL_RELEASE/eksctl_$(uname -s)_amd64.tar.gz && \
    tar -xzvf eksctl.tar.gz && chmod +x eksctl && sudo mv eksctl /usr/local/bin

# Install yq
RUN YQ_RELEASE=$(curl --silent "https://api.github.com/repos/mikefarah/yq/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') && \
    sudo curl -sL https://github.com/mikefarah/yq/releases/download/$YQ_RELEASE/yq_linux_amd64 -o /usr/local/bin/yq
RUN sudo chmod +x /usr/local/bin/yq

# k9s
RUN K9S_RELEASE=$(curl --silent "https://api.github.com/repos/derailed/k9s/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') && \
    curl -sL https://github.com/derailed/k9s/releases/download/$K9S_RELEASE/k9s_${K9S_RELEASE}_Linux_x86_64.tar.gz -o k9s.tar.gz && \
    tar -xzvf k9s.tar.gz && chmod +x k9s && sudo mv k9s /usr/local/bin && rm LICENSE README.md k9s.tar.gz    

# kubectx & kubens
RUN KUBECTX_RELEASE=$(curl --silent "https://api.github.com/repos/ahmetb/kubectx/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') && \
    curl -sL https://github.com/ahmetb/kubectx/releases/download/$KUBECTX_RELEASE/kubectx_${KUBECTX_RELEASE}_linux_x86_64.tar.gz -o /tmp/kubectx.tar.gz && \
    tar -C /tmp -xzvf /tmp/kubectx.tar.gz && chmod +x /tmp/kubectx && sudo mv /tmp/kubectx /usr/local/bin && \
    curl -sL https://github.com/ahmetb/kubectx/releases/download/$KUBECTX_RELEASE/kubens_${KUBECTX_RELEASE}_linux_x86_64.tar.gz -o /tmp/kubens.tar.gz && \
    tar -C /tmp -xzvf /tmp/kubens.tar.gz && chmod +x /tmp/kubens && sudo mv /tmp/kubens /usr/local/bin && rm /tmp/LICENSE

# kubespy
RUN SPY_RELEASE=$(curl --silent "https://api.github.com/repos/pulumi/kubespy/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') && \
    sudo curl -sL https://github.com/pulumi/kubespy/releases/download/$SPY_RELEASE/kubespy-$SPY_RELEASE-linux-amd64.tar.gz -o /tmp/kubespy.tar.gz && \
    tar -C /tmp -xzvf /tmp/kubespy.tar.gz && chmod +x /tmp/kubespy && sudo mv /tmp/kubespy /usr/local/bin

# stern
RUN STERN_RELEASE=$(curl --silent "https://api.github.com/repos/wercker/stern/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') && \
    sudo curl -sL https://github.com/wercker/stern/releases/download/$STERN_RELEASE/stern_linux_amd64 -o /usr/local/bin/stern && \
    sudo chmod +x /usr/local/bin/stern

# kube-shell
RUN sudo pip3 install kube-shell

# monaco
RUN MONACO_RELEASE=$(curl --silent "https://api.github.com/repos/dynatrace-oss/dynatrace-monitoring-as-code/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') && \
    sudo curl -sL https://github.com/dynatrace-oss/dynatrace-monitoring-as-code/releases/download/$MONACO_RELEASE/monaco-linux-amd64 -o /usr/local/bin/monaco && \
    sudo chmod +x /usr/local/bin/monaco


# aws cli
RUN sudo pip3 install awscli

# cleanup
RUN sudo rm -rf /tmp/* && sudo apt-get clean 

CMD ["/usr/bin/zsh"]