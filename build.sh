#!/bin/bash

set -eu

readonly ROOT_PATH=$(cd $(dirname $0) && pwd)

## Get OS environment parameters.
if [ "$(uname -s)" = 'Darwin' ]; then
    # Mac OSX
    readonly ID='macos'
    readonly ARCH='x86_64'
    readonly IS_LINUX='false'

elif [ -e /etc/os-release ]; then
    . /etc/os-release
    readonly ARCH=`uname -p`
    readonly IS_LINUX='true'

else
    echo "Thank you for useing. But sorry, this platform is not supported yet."
    exit 1
fi

## Download libwebrtc (Compiled chromium WebRTC native APIs.)
readonly LOCAL_ENV_PATH=${ROOT_PATH}/local
readonly WEBRTC_VER=75

mkdir -p ${LOCAL_ENV_PATH}/include
mkdir -p ${LOCAL_ENV_PATH}/src
cd ${LOCAL_ENV_PATH}/src

# Filename
#if [ "${ID}" = 'macos' ]; then
readonly WEBRTC_FILE="libwebrtc-75.0.3770.142-macosx-10.14.5.zip"
#else
#    readonly WEBRTC_FILE="libwebrtc-ubuntu-x64-${WEBRTC_VER}.tar.gz"
#fi

# Download and unarchive
if ! [ -e "${WEBRTC_FILE}" ]; then
    if [ "${ID}" = 'macos' ]; then
	curl -OL https://github.com/llamerada-jp/libwebrtc/releases/download/m${WEBRTC_VER}/${WEBRTC_FILE}
	cd ${LOCAL_ENV_PATH}
	unzip -o src/${WEBRTC_FILE}
    else
	wget https://github.com/llamerada-jp/libwebrtc/releases/download/v${WEBRTC_VER}/${WEBRTC_FILE}
	cd ${LOCAL_ENV_PATH}
	tar zxf src/${WEBRTC_FILE}
    fi
fi

## Build
# Change compiler to clang on linux
if [ "${IS_LINUX}" = 'true' ]; then
    export CC=/usr/bin/clang
    export CXX=/usr/bin/clang++
fi

readonly BUILD_PATH=${ROOT_PATH}/build
mkdir -p ${BUILD_PATH}

cd ${ROOT_PATH}
git submodule init
git submodule update

cd ${BUILD_PATH}
cmake -DLIBWEBRTC_PATH=${LOCAL_ENV_PATH} ..
make
cp sample ${ROOT_PATH}
