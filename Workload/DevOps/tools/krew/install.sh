#!/bin/bash

set -euo pipefail
trap cleanup EXIT ERR

tmpDir=$(mktemp -d)

cleanup() {
  rm -rf "${tmpDir}"
  popd &>/dev/null || true
}

need() {
  command -v "$1" &>/dev/null || die "Binary '$1' is missing but required"
}

need "git"
pushd "${tmpDir}" &>/dev/null

curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-linux_amd64.tar.gz"
tar zxvf "krew-linux_amd64.tar.gz"
./"krew-linux_amd64" install krew