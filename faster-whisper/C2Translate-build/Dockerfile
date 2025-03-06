FROM rocm/pytorch:rocm6.3.3_ubuntu24.04_py3.12_pytorch_release_2.4.0

RUN mkdir /src
WORKDIR /src

RUN git clone https://github.com/arlo-phoenix/CTranslate2-rocm.git --recurse-submodules
COPY build.sh /src/build.sh
RUN chmod +x /src/build.sh

# For debugging purposes
ENTRYPOINT ["conda", "run", "-n", "py_3.12", "/src/build.sh"]