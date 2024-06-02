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

toolName="argo"
pre_check "${toolName}"
pushd "${tmpDir}" &>/dev/null
echo "Installing ${toolName}..."

version=$(curl -s https://api.github.com/repos/argoproj/argo-workflows/releases/latest | jq -r .tag_name)
url="https://github.com/argoproj/argo-workflows/releases/download/${version}/argo-linux-amd64.gz"
curl -sSLO "${url}"
gunzip argo-linux-amd64.gz && mv argo-linux-amd64 "${toolName}"

sudo install -m 555 "${toolName}" "/usr/local/bin/${toolName}"
echo -e "${toolName} installed to /usr/local/bin/${toolName}\n"

"${toolName}" version &>/dev/null
