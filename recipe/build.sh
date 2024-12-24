#!/bin/bash

set -xeuo pipefail

mkdir build_release
pushd build_release

cmake ${CMAKE_ARGS} \
    -GNinja \
    -DCMAKE_BUILD_TYPE:STRING="Release" \
    -DCMAKE_PREFIX_PATH:PATH="${PREFIX}" \
    -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DBUILD_STATIC_LIBS:BOOL=OFF \
    -DREQUIRE_CRYPTO_OPENSSL:BOOL=ON \
    "${SRC_DIR}"

cmake --build . --target install --config Release

# running tests only on linux because run-all has hardcoded mktemp --suffix=... in it which is
# not working on MacOS mktemp
if [[ "$(uname)" == "Linux" ]]; then
    export PATH=${PREFIX}/bin:$PATH
    export LD_LIBRARY_PATH=${PREFIX}/lib:$PATH
    export PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig:$PKG_CONFIG_PATH
    export CMAKE_PREFIX_PATH=${PREFIX}
    ./pkg-test/run-all
fi

popd  # Leave `build_release`
