#!/usr/bin/env bash

conda init bash
source activate py_3.12
# Follow the instructions here: https://llama-cpp-python.readthedocs.io/en/latest/server/#function-calling
# See for ENV variables: https://llama-cpp-python.readthedocs.io/en/latest/server/#llama_cpp.server.settings.ServerSettings
exec python3 -m llama_cpp.server --host 0.0.0.0