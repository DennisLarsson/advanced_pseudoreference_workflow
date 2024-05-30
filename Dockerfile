# Use the official Ubuntu 22.04 LTS base image
FROM ubuntu:22.04

# Update the system and install necessary tools
RUN apt-get update && apt-get install -y \
    wget \
    default-jdk \
    unzip

# Download and install Nextflow 24.04.0-edge
RUN wget -qO- https://get.nextflow.io | bash && \
    chmod +x nextflow && \
    mv nextflow /usr/local/bin
ENV NXF_VER=24.04.0-edge
RUN nextflow info

# Set the working directory
WORKDIR /data

COPY main.nf /data/main.nf
