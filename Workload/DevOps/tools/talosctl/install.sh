#!/bin/bash

set -euo pipefail
trap cleanup EXIT ERR

tmpDir=$(mktemp -d)

cleanup() {
  rm -rf "${tmpDir}"
  popd &>/dev/null || true
}

pre_check() {
  local location
  location=$(command -v "${1}" || true)

  if [ -n "${location}" ]; then
    echo "${1} is already installed at: ${location}"
    exit 0
  fi
}

toolName="talosctl"
pre_check "${toolName}"
pushd "${tmpDir}" &>/dev/null

curl -sL https://talos.dev/install | sh