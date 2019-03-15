#!/bin/bash

# Usage example:  PLATFORM=$(uname -m) TRAVIS_COMMIT=latest ./build.sh

PLATFORM=${PLATFORM:-`uname -m`}
TRAVIS_COMMIT=${TRAVIS_COMMIT:-latest}

# Stop at any error, show all commands
set -ex

docker/build_scripts/prefetch.sh openssl curl
#docker build --rm -t quay.io/pypa/manylinux1_$PLATFORM:$TRAVIS_COMMIT -f docker/Dockerfile-$PLATFORM docker/
docker build --rm -t pvapy_manylinux1_$PLATFORM:$TRAVIS_COMMIT -f docker/Dockerfile-$PLATFORM docker/
