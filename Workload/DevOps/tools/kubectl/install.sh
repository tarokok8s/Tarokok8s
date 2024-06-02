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

toolName="kubectl"
pre_check "${toolName}"
pushd "${tmpDir}" &>/dev/null
echo "Installing ${toolName}..."

stable=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -sSLO "https://dl.k8s.io/release/${stable}/bin/linux/amd64/kubectl"

sudo install -m 555 "${toolName}" "/usr/local/bin/${toolName}"
echo -e "${toolName} installed to /usr/local/bin/${toolName}\n"

"${toolName}" version &>/dev/null