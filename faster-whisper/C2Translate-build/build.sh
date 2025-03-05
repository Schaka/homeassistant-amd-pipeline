#!/bin/bash

# Following instructions here: https://github.com/arlo-phoenix/CTranslate2-rocm/blob/rocm/README_ROCM.md
# Run cmake with specified options
# Minus the part about using conda, because our Docker environment sets up "everything"

# enter checked out repository
cd CTranslate2-rocm

CLANG_CMAKE_CXX_COMPILER=clang++ CXX=clang++ HIPCXX="$(hipconfig -l)/clang" HIP_PATH="$(hipconfig -R)" \
   cmake -S . -B build -DWITH_MKL=OFF -DWITH_HIP=ON -DCMAKE_HIP_ARCHITECTURES=$PYTORCH_ROCM_ARCH -DBUILD_TESTS=ON -DWITH_CUDNN=ON

# Build the project with 16 parallel jobs
cmake --build build -- -j16

# Change to the build directory
cd build

echo -e "\n-----------------------------------------------------------------"
echo -e "1.  Installing the CMake Build"
echo -e "-----------------------------------------------------------------\n"

# Install the build with conda or system-wide
cmake --install . --prefix $CONDA_PREFIX
sudo make install

echo -e "-----------------------------------------------------------------"
echo -e "2.  Linking with ldconfig"
echo -e "-----------------------------------------------------------------\n"

# Update shared library cache
sudo ldconfig
ld -lctranslate2 --verbose

cd ../python
pip install -r install_requirements.txt
python setup.py bdist_wheel


echo -e "\n -----------------------------------------------------------------"
echo -e "3. Exporting Wheel File for usage in Faster-Whisper"
echo -e "-----------------------------------------------------------------\n"

cp dist/*.whl /dist
cp ../build/libctranslate2* /dist/