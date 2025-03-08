FROM ubuntu:24.04

# If you're forced to stay on 5.15, use the Ubuntu 22.04 base image
# AMD recommends this for a specific kernel
# Kernels supported on Ubuntu 24.0.4 are 6.8 (LTS) and 6.11 (WHE)
# See also: https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/prerequisites.html
# Download and install GPU drivers and ROCm
RUN apt update && apt install -y wget && wget https://repo.radeon.com/amdgpu-install/6.3.3/ubuntu/noble/amdgpu-install_6.3.60303-1_all.deb && \
    apt install -y ./amdgpu-install_6.3.60303-1_all.deb && \
    rm ./amdgpu-install_6.3.60303-1_all.deb && \
    apt update && apt install -y amdgpu-dkms rocm

# Install dependencies for llama.cpp
RUN apt update && \
    apt install -y git cmake make curl libcurl4t64 libcurl4-openssl-dev

# Build llama.cpp
RUN git clone -b b4855 https://github.com/ggml-org/llama.cpp.git && cd llama.cpp && \
    HIPCXX="$(hipconfig -l)/clang" HIP_PATH="$(hipconfig -R)" \
    cmake -S . -B build -DGGML_HIPBLAS=ON -DGGML_HIP=ON -DLLAMA_CURL=ON -DAMDGPU_TARGETS=gfx906 -DCMAKE_C_COMPILER=/opt/rocm/bin/amdclang -DCMAKE_CXX_COMPILER=/opt/rocm/bin/amdclang++ -DCMAKE_PREFIX_PATH=/opt/rocm -DCMAKE_BUILD_TYPE=Release && \
    cmake --build build --config Release -- -j 16

# Make llmama binaries available in to all users
RUN chmod +x /llama.cpp/build/bin/*
ENV PATH="$PATH:/llama.cpp/build/bin"
ENV LLAMA_CACHE=/models

# Now that those groups exist, add them to the existing user
RUN groupadd -g 1001 homeassistant && \
    useradd homeassistant -u 1001 -g 1001 && \
    usermod -a -G render,video homeassistant && \
    mkdir /models && \
    chown -R homeassistant /models


#USER 1001:1001

# https://github.com/ggml-org/llama.cpp/blob/master/examples/server/README.md
ENTRYPOINT [ "llama-server", "--jinja", "--host", "0.0.0.0", "--port", "8000"]