# Use the official Ubuntu 22.04 LTS base image
FROM ubuntu:22.04 AS workflow

# Update the system and install necessary tools
RUN apt-get update && apt-get install -y \
    wget \
    default-jdk \
    unzip \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker’s official GPG key and repository
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
RUN apt-get update && apt-get install -y \
    docker-ce docker-ce-cli containerd.io

# Download and install Nextflow 24.04.0-edge
RUN wget -qO- https://get.nextflow.io | bash && \
    chmod +x nextflow && \
    mv nextflow /usr/local/bin
ENV NXF_VER=24.04.0-edge
RUN nextflow info

# Set the working directory
WORKDIR /data

COPY main.nf .
COPY nextflow.config .