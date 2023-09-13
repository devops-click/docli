#!/usr/bin/env bash
set -euo pipefail
############################################################################### #dltbr
#              https://DevOps.click - DevOps taken seriously                  # #dltbr
###############################################################################
#                       docli Installation Script
###############################################################################

install_version="0.0.02"
install_file_name="$(basename "$0")"
install_file_name_upper="$(basename "$0" | tr '[:lower:]' '[:upper:]')"
install_script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
install_current_dir="$(pwd)"

## docli Markdown Generation:
#:: ## docli install
#::
#:: Run this script using:
#:: ```bash
#:: curl:
#::   sh -c "$(curl -fsSL https://raw.githubusercontent.com/devops-click/docli/main/tools/install.sh)"
#:: wget:
#::   sh -c "$(wget -qO- https://raw.githubusercontent.com/devops-click/docli/main/tools/install.sh)"
#:: fetch:
#::   sh -c "$(fetch -o - https://raw.githubusercontent.com/devops-click/docli/main/tools/install.sh)"
#:: ```
#::
#:: To pass arguments to the installation, do the following:
#:: ```bash
#:: arguments: module_argument
#:: sh -c "$(curl -fsSL https://raw.githubusercontent.com/devops-click/docli/main/tools/install.sh)" -- --only-modules=macos_devops
#:: to run only MacOS Setup for DevOps Engineers
#:: ```
#::
#:: As an alternative, you may first download it to then run it afterwards:
#::   wget https://raw.githubusercontent.com/devops-click/docli/main/tools/install.sh
#::   sh install.sh
#::
#:: You can set variables to interact with the script. Ex: to change the path to the docli repository:
#::   DOCLI=~/.devops sh install.sh

# source $install_script_dir/.docli $install_current_dir

DOCLI=${1:-}

echo -e "\n**** docli installation ****\n"

# Detect the architecture
arch=$(uname -m)

# Detect the OS
#### MacOS ####
if [[ "$OSTYPE" == "darwin"* ]]; then
  os="macos"
  os_name="MacOS"
  echo "** OS: ${os_name} ${arch} Detected **"
  if [ "$DOCLI" == "" ]; then
    export DOCLI="$HOME/.devops"
    echo "** Using default docli location $DOCLI"
  fi

#### Linux ####
elif [[ -f "/etc/os-release" ]]; then
  . /etc/os-release
  if [[ "$ID" == "amzn" ]]; then
    if [[ "$VERSION_ID" == "2" ]]; then
      os="amzn2"
      os_name="Amazon Linux 2"
      echo "** OS: ${os_name} ${arch} Detected **"
      if [ $DOCLI == "" ]; then
        export DOCLI="/opt/devops"
        echo "** Using default docli location $DOCLI"
      fi
    elif [[ "$VERSION_ID" == "2022" ]]; then
      os="al2022"
      os_name="Amazon Linux 2022"
      echo "** OS: ${os_name} ${arch} Detected **"
      if [ $DOCLI == "" ]; then
        export DOCLI="/opt/devops"
        echo "** Using default docli location $DOCLI"
      fi
    fi
  elif [[ "$ID" == "ubuntu" ]]; then
    os="ubuntu"
    os_name="Ubuntu"
    echo "** OS: ${os_name} ${arch} Detected **"
    if [ $DOCLI == "" ]; then
      export DOCLI="/opt/devops"
      echo "** Using default docli location $DOCLI"
    fi
  elif [[ "$ID" == "debian" ]]; then
    os="debian"
    os_name="Debian"
    echo "** OS: ${os_name} ${arch} Detected **"
    if [ $DOCLI == "" ]; then
      export DOCLI="/opt/devops"
      echo "** Using default docli location $DOCLI"
    fi
  else
    echo "** ERROR: OS not supported **"
    exit 1
  fi
else
  echo "** ERROR: OS not supported **"
  exit 1
fi

echo -e "** docli-install: Creating base structure **"
[[ ! -d "${DOCLI}/bin" ]] && mkdir -p $DOCLI/bin || echo "$DOCLI/bin exists"
[[ ! -d "${DOCLI}/main" ]] && mkdir -p $DOCLI/main || echo "$DOCLI/main exists"
[[ ! -d "${DOCLI}/scripts" ]] && mkdir -p $DOCLI/scripts || echo "$DOCLI/scripts exists"
exit 0
echo -e "** docli-install: Download/Updating docli files **"
curl -sL https://raw.githubusercontent.com/devops-click/docli/main/.devops/bin/docli -H "Cache-Control: no-cache, no-store" -o $DOCLI/bin/docli
curl -sL https://raw.githubusercontent.com/devops-click/docli/main/.devops/functions/bash_basic_functions -H "Cache-Control: no-cache, no-store" -o $DOCLI/functions/bash_basic_functions
curl -sL https://raw.githubusercontent.com/devops-click/docli/main/.devops/main/macos -H "Cache-Control: no-cache, no-store" -o $DOCLI/main/macos
curl -sL https://raw.githubusercontent.com/devops-click/docli/main/.devops/scripts/docli_aws_copy_token_credentials -H "Cache-Control: no-cache, no-store" -o $DOCLI/scripts/docli_aws_copy_token_credentials

echo -e "** docli-install: Setting file permissions **"
chmod +x -R $DOCLI/bin/*
chmod +x -R $DOCLI/main/*
chmod +x -R $DOCLI/scripts/*

echo -e "\n**** docli installed sucessfully! ****\n"