# TODO: Use our own base image, maybe even get rid of conda
FROM rocm/pytorch:rocm6.3.3_ubuntu24.04_py3.12_pytorch_release_2.4.0

# set your GPU here, gfx906 is Instinct Mi50 only
ENV FORCE_CMAKE=1
ENV CMAKE_ARGS="CMAKE_C_COMPILER=/opt/rocm/bin/amdclang -D CMAKE_CXX_COMPILER=/opt/rocm/bin/amdclang++ -D CMAKE_PREFIX_PATH=/opt/rocm -DCMAKE_BUILD_TYPE=Release -DGGML_HIPBLAS=ON -DLLAMA_HIPBLAS=ON -DGGML_HIP=ON -DAMDGPU_TARGETS=gfx906"

RUN apt update && apt install libstdc++-12-dev libstdc++-12-doc

# This will install the python wrapper but also download and compile llama.cpp
RUN pip install -U pip && pip install llama-cpp-python 'llama-cpp-python[server]' huggingface-hub

COPY ./run.sh /app/run.sh
WORKDIR /app

RUN chmod +x /app/run.sh

ENTRYPOINT ["/app/run.sh"]