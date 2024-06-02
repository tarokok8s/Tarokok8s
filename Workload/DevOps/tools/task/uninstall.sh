#!/bin/bash

set -euo pipefail

uninstall() {
  local toolName="${1}"
  if command -v "${toolName}" &>/dev/null; then
    toolPath=$(command -v "${toolName}")
    sudo rm -rf "${toolPath}"
    echo "${toolPath} remove ok!"
  fi
}

uninstall task
uninstall task.bash
