# TODO: Use our own base image, maybe even get rid of conda
FROM rocm/pytorch:rocm6.3.3_ubuntu24.04_py3.12_pytorch_release_2.4.0

RUN pip install -U pip && pip install wyoming==1.6.0 faster-whisper==1.1.1 tokenizers==0.21.*
RUN apt-get update && apt-get -y install nano ffmpeg libomp-dev

RUN mkdir /app && mkdir /app/wyoming_faster_whisper && \
    git clone https://github.com/rhasspy/wyoming-faster-whisper.git wyoming && \
    cp wyoming/wyoming_faster_whisper/* /app/wyoming_faster_whisper && \
    rm -r wyoming

COPY ./run.sh /app/run.sh
COPY ./C2Translate-build/dist /deps
WORKDIR /app

RUN pip install /deps/*.whl && \
    ldconfig /deps

ENTRYPOINT ["/app/run.sh"]