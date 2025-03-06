#!/usr/bin/env bash

conda init bash
source activate py_3.12
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CONDA_PREFIX/lib/
exec python3 -m wyoming_faster_whisper --device cuda --model ${WHISPER_MODEL:-distil-small.en} --language ${WHISPER_LANGUAGE:en} --uri 'tcp://0.0.0.0:10300' --data-dir /data --download-dir /data "$@"