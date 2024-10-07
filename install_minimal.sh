#!/usr/bin/env bash
[[ "${DOCLI_DEBUG:-off}" == "on" ]]       && set -exo pipefail || set -eo pipefail
[[ "${DOCLI_UNSET_VARS:-off}" == "on" ]]  && set -u
############################################################################### #dltbr
#              https://DevOps.click - DevOps taken seriously                  # #dltbr
###############################################################################
#                                   docli
###############################################################################
# Designed to be used for very fast installations
# Usage:
# curl -fsSL https://raw.githubusercontent.com/devops-click/docli/main/install_minimal.sh | bash
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/devops-click/docli/main/install_minimal.sh)"

PATH="${DOCLI_DIR:-/opt/devops}/bin:/opt/homebrew/bin:/usr/sbin:/sbin:/usr/bin:/bin:/usr/local/bin:/usr/local/sbin:$HOME/devops/bin:$PATH"

## DOCLI MODULE INFORMATION
DOCLI_MODULE_VERSION=0.0.01
DOCLI_MODULE="$(basename "${BASH_SOURCE[0]}")"
DOCLI_MODULE_TYPE="root"
DOCLI_MODULE_UPPER=$(echo "$DOCLI_MODULE" | tr '[:lower:]' '[:upper:]')

## VERBOSE INFORMATION
[[ "${DOCLI_VERBOSE:-off}" == "on" ]] && echo -e "\n***** $DOCLI_MODULE version $DOCLI_MODULE_VERSION ($DOCLI_MODULE_TYPE) *****\n" || true

## USE OR NOT SUDO
if command -v sudo > /dev/null 2>&1; then
  export use_sudo="sudo"
else
  export use_sudo=""
fi

## CREATE DIRECTORIES
[[ ! -d /opt/devops/bin ]]      && mkdir -p /opt/devops/bin
[[ ! -d /opt/devops/scripts ]]  && mkdir -p /opt/devops/scripts

## DOWNLOAD BINARIES
curl -fsSL https://raw.githubusercontent.com/devops-click/docli/main/.devops/docheck -o /opt/devops/bin/docheck || wget https://raw.githubusercontent.com/devops-click/docli/main/.devops/docheck -O /opt/devops/bin/docheck

## SETUP PERMISSIONS
$use_sudo chmod +x /opt/devops/bin/*
$use_sudo chmod +x /opt/devops/scripts/*

echo "* DOCLI: Minimal installation completed successfully *"
