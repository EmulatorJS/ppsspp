#!/bin/bash
set -e

cd "$(dirname "$0")"
cd ../../

git submodule update --init --recursive

cd ffmpeg
cp ../libretro/emscripten/linux_wasm32.sh ./
bash linux_wasm32.sh
cd ../

sed -i 's|return getauxval(hwcap_type);|return 1;|g' ext/cpu_features/src/hwcaps.c
sed -i 's|#include <sys/auxv.h>||g' ext/cpu_features/src/hwcaps.c

cd ext/armips/ext/
rm -rf filesystem
git clone https://github.com/gulrak/filesystem.git filesystem

cd ../../../libretro/
emmake make platform=emscripten -j$(nproc)

mkdir -p emscripten/build/
cp *.bc emscripten/build/
cp ../ffmpeg/linux/wasm32/lib/*.a emscripten/build/
