FROM ubuntu:24.04

RUN groupadd -g 1001 homeassistant && \
    useradd homeassistant -u 1001 -g 1001

# Install dependencies
# AMD recommends this for a specific kernel
# Kernels supported on Ubuntu are 5.15 (22.04) and 6.8 (24.04)
# See also: https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/prerequisites.html
RUN apt update && \
    apt install -y wget linux-headers-6.8.0-52-generic linux-modules-extra-6.8.0-52-generic python3-setuptools python3-wheel

# If you're forced to stay on 5.15, use the Ubuntu 22.04 base image
# install linux-headers-linux-modules-extra-5.15.0-97-generic and linux-modules-extra-linux-modules-extra-5.15.0-97-generic

# Download and install GPU drivers and ROCm
RUN wget https://repo.radeon.com/amdgpu-install/6.3.3/ubuntu/noble/amdgpu-install_6.3.60303-1_all.deb && \
    apt install -y ./amdgpu-install_6.3.60303-1_all.deb && \
    rm ./amdgpu-install_6.3.60303-1_all.deb && \
    apt update && apt install -y amdgpu-dkms rocm

# Now that those groups exist, add them to the existing user
RUN usermod -a -G render,video homeassistant    

USER 1001:1001 