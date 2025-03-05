# Use Ubuntu 20.04 as the base image
FROM ubuntu:20.04

# Set non-interactive mode to prevent prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    unzip \
    jq \
    git \
    apt-transport-https \
    software-properties-common \
    sudo \
    docker.io \
    build-essential \
    nodejs \
    iputils-ping \
    libcurl4 \
    libunwind8 \
    netcat \
    libssl1.1 \
    vim \
    wget \
    npm \
    libc6 \
    libgcc-s1 \
    libgssapi-krb5-2 \
    libicu66 \
    liblttng-ust0 \
    libstdc++6 \
    libunwind8 \
    zlib1g && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs

# Install .NET Core SDK and Runtime
RUN curl -fsSL https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -o packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y dotnet-sdk-6.0 aspnetcore-runtime-6.0 dotnet-runtime-6.0

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install GoLang
RUN apt-get update && apt-get upgrade -y && apt-get install -y golang

# Install Helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install PowerShell
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-focal-prod focal main" > /etc/apt/sources.list.d/microsoft.list' && \
    apt-get update && apt-get install -y powershell

# Create a non-root user and necessary directories
RUN useradd -m azureuser && \
    usermod -aG sudo azureuser && \
    echo "azureuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /azp/agent && \
    chown -R azureuser:azureuser /azp && \
    chmod -R 777 /azp/agent

# Switch to work directory
WORKDIR /azp/agent

# Install Azure DevOps agent
RUN curl -L https://vstsagentpackage.azureedge.net/agent/3.220.2/vsts-agent-linux-x64-3.220.2.tar.gz -o vsts-agent.tar.gz && \
    mkdir -p /azp/agent && \
    tar -zxvf vsts-agent.tar.gz -C /azp/agent && \
    rm vsts-agent.tar.gz && \
    chown -R azureuser:azureuser /azp/agent && \
    chmod -R 777 /azp/agent

# Copy start.sh script
COPY start.sh /azp/agent/start.sh

# Grant execution permission
RUN chmod +x /azp/agent/start.sh && \
    chown -R azureuser:azureuser /azp/agent/start.sh

# Switch to non-root user
USER azureuser

# Set the entrypoint
ENTRYPOINT ["/bin/bash", "-c", "exec /azp/agent/start.sh"]
