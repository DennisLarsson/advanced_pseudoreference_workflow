# Use the official Ubuntu 22.04 LTS base image
FROM ubuntu:22.04

# Update the system and install necessary tools
RUN apt-get update && apt-get install -y \
    wget \
    default-jdk \
    unzip

# Download and install Nextflow
RUN wget -qO- https://get.nextflow.io | bash
RUN mv nextflow /usr/local/bin

# Set the working directory
WORKDIR /data