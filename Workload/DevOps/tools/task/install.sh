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

pushd "${tmpDir}" &>/dev/null

curl -s -o "task.bash" "https://raw.githubusercontent.com/go-task/task/main/completion/bash/task.bash"
sudo install -m 555 "task.bash" "/usr/local/bin/task.bash"

toolName="task"
pre_check "${toolName}"
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b "${tmpDir}"
sudo install -m 555 "${toolName}" "/usr/local/bin/${toolName}"
echo -e "${toolName} installed to /usr/local/bin/${toolName}\n"

"${toolName}" --version &>/dev/null
