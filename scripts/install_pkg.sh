#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o noclobber
set -o errexit
set -o errtrace

LLVM_VER="17"

function install_packages() {
  sudo apt install -y \
    build-essential \
    git \
	  gcc \
	  make \
	  perl \
	  pkg-config \
	  flex \
	  bison \
	  libssl-dev \
	  libelf-dev \
	  libncurses-dev \
	  curl \
	  bat

	install_llvm
}

function install_llvm() {
  sudo apt install -y \
    clang-${LLVM_VER} \
    lld-${LLVM_VER} \
    llvm-${LLVM_VER} \
    llvm-${LLVM_VER}-dev \
    llvm-${LLVM_VER}-runtime \
    libclang-${LLVM_VER}-dev
}

function setup_alternatives() {
  sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-${LLVM_VER} 100
  sudo update-alternatives --install /usr/bin/ld.lld ld.lld /usr/bin/ld.lld-${LLVM_VER} 100

  for tool in llvm-ar llvm-nm llvm-objcopy llvm-strip; do
    if [ -x /usr/bin/${tool}-${LLVM_VER} ]; then
        sudo update-alternatives --install /usr/bin/$tool $tool /usr/bin/$tool-${LLVM_VER} 100
      fi
    done
}

function main() {
  sudo apt update
  install_packages
  setup_alternatives
}

main ${@+"$@"}
