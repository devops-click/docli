#!/usr/bin/env bash
[[ "${DOCLI_DEBUG:-off}" == "on" ]]       && set -exo pipefail || set -eo pipefail
[[ "${DOCLI_UNSET_VARS:-off}" == "on" ]]  && set -u
############################################################################### #dltbr
#              https://DevOps.click - DevOps taken seriously                  # #dltbr
###############################################################################
#                       docli Installation Script
###############################################################################

## DOCLI MODULE INFORMATION
DOCLI_MODULE_VERSION="0.0.01"
[[ "${BASH_SOURCE[0]}" != "" ]] && DOCLI_MODULE="$(basename "${BASH_SOURCE[0]}")"                                             || DOCLI_MODULE="$(basename "$0")"
DOCLI_MODULE_TYPE="install"
[[ "${BASH_SOURCE[0]}" != "" ]] && DOCLI_MODULE_UPPER=$(echo "$(basename "${BASH_SOURCE[0]}")"  | tr '[:lower:]' '[:upper:]') || DOCLI_MODULE_UPPER=$(echo "$(basename "$0")" | tr '[:lower:]' '[:upper:]')
##[[ "${DOCLI_MODULE_ARRAY_SOURCE:-on}" == "on" ]] && source ${DOCLI_DIR:-$DOCLI}/functions/docli_module_array

# TODO: REMOVE, kept for small period to keep compatibility
install_version="$DOCLI_MODULE_VERSION"

os_var=$(uname)
: "${DOCLI_DEPLOY:=false}"
: "${DOCLI_DEVELOPER_MODE:=false}"
: "${DOCLI_REPOSITORY:=}"
DOCLI_REMOTE_REPOSITORY=https://raw.githubusercontent.com/devops-click/docli/main

if [[ $DOCLI_DEPLOY == true ]]; then
  echo "* INFO: docli deploy *"
fi

# Detect if the script is being sourced from the internet
if [[ "$0" = "bash" ]] || [[ "$0" = "/bin/bash" ]] || [[ "$0" = "/bin/sh" ]] || [[ "$0" = "sh" ]] || [[ "$0" = "/bin/zsh" ]] || [[ "$0" = "zsh" ]]; then
  echo -e "\n************************************************************"
  echo -e "* INFO: docli installation sourced from GitHub *"
  echo -e "************************************************************\n"
  install_file_name="install.sh" # hardcode or otherwise determine
  install_file_name_upper="INSTALL.SH" # hardcode or otherwise determine
  install_current_dir="$PWD"
  install_local="false" # used when running from a forked repository
elif [[ $DOCLI_DEVELOPER_MODE == true ]]; then
  echo -e "\n************************************************************"
  echo "* INFO: docli installation sourced LOCALLY (DEVELOPER MODE) *"
  echo -e "************************************************************\n"
  echo -e "\n** DETECTEC LOCAL RUN: If DOCLI_REPOSITORY variable is set, we will get files locally from there! (Developers only)"
  [[ "${BASH_SOURCE[0]}" != "" ]] && install_file_name="$(basename "${BASH_SOURCE[0]}")"                                    || install_file_name="$(basename "$0")"
  [[ "${BASH_SOURCE[0]}" != "" ]] && install_file_name_upper="$(basename "${BASH_SOURCE[0]}" | tr '[:lower:]' '[:upper:]')" || install_file_name_upper="$(basename "$0" | tr '[:lower:]' '[:upper:]')"
  install_current_dir="$(pwd)"
  install_local="true" # used when running from a forked repository
else
  echo -e "\n************************************************************"
  echo "* INFO: docli installation sourced LOCALLY (DEVELOPER MODE) *"
  echo -e "************************************************************\n"
  echo -e "\n** DETECTEC LOCAL RUN: If DOCLI_REPOSITORY variable is set, we will get files locally from there! (Developers only)"
  [[ "${BASH_SOURCE[0]}" != "" ]] && install_file_name="$(basename "${BASH_SOURCE[0]}")"                                    || install_file_name="$(basename "$0")"
  [[ "${BASH_SOURCE[0]}" != "" ]] && install_file_name_upper="$(basename "${BASH_SOURCE[0]}" | tr '[:lower:]' '[:upper:]')" || install_file_name_upper="$(basename "$0" | tr '[:lower:]' '[:upper:]')"
  install_current_dir="$(pwd)"
  install_local="true" # used when running from a forked repository
fi

# source...bash_basic_functions # loaded to be executed independently
#:: # Check if the script is running on macOS or Linux
#:: ## Usage example:
#:: `check_os_mac_linux_only`
check_os_mac_linux_only() {
  if [[ "$os_var" == "Darwin" ]]; then
    os="macos"
    # Check if Homebrew is installed
    echo "** MacOS Detected. Installing minimal requirements to proceed with docli setup **"
    if ! command -v brew &>/dev/null; then
      echo "** Homebrew not found. Installing... **"
      # Install Homebrew
      export HOMEBREW_INSTALL_FROM_API=1
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
      brew update
      brew install bash awscli md5sha1sum curl jq
    else
      echo "** Homebrew is already installed. **"
    fi
    # eval "$(/opt/homebrew/bin/brew shellenv)" # Do not use it, or a new shell will be instanced
    export PATH="${DOCLI_DIR:-/opt/devops}/bin:/opt/homebrew/bin:/usr/sbin:/sbin:/usr/bin:/bin:/usr/local/bin:/usr/local/sbin:$HOME/devops/bin:$PATH"
  elif [ "$os_var" == "Linux" ]; then
    os="linux"
  else
    echo "** ERROR: Supported only by MacOS and Linux. **"
    exit 1
  fi
}

# Load environment Vars
[[ -f "$HOME/.docli_envs" ]] && source $HOME/.docli_envs
[[ -f "$install_current_dir/.docli_envs" ]] && source $install_current_dir/.docli_envs
if [ -n "${DOCLI+x}" ] && [ -n "$DOCLI" ]; then
  echo "** DOCLI variable found with value $DOCLI! Using it's values when applicable **"
  check_os_mac_linux_only
else
  echo "** DOCLI variable not found! Using defaults **"
  check_os_mac_linux_only
  [[ $os == "macos" ]] && export DOCLI="$HOME/devops"
  [[ $os == "linux" ]] && export DOCLI="/opt/devops"
fi

## docli Markdown Generation:
#:: ## docli install
#::
#:: Run this script using:
#:: ```bash
#:: curl:
#::   sh -c "$(curl -fsSL $DOCLI_REMOTE_REPOSITORY/install.sh)"
#:: wget:
#::   sh -c "$(wget -qO- $DOCLI_REMOTE_REPOSITORY/install.sh)"
#:: fetch:
#::   sh -c "$(fetch -o - $DOCLI_REMOTE_REPOSITORY/install.sh)"
#:: ```
#::
#:: To pass arguments to the installation, do the following:
#:: ```bash
#:: arguments: module_argument
#:: sh -c "$(curl -fsSL $DOCLI_REMOTE_REPOSITORY/install.sh)" -- --only-modules=macos_devops
#:: to run only MacOS Setup for DevOps Engineers
#:: ```
#::
#:: As an alternative, you may first download it to then run it afterwards:
#::   wget $DOCLI_REMOTE_REPOSITORY/install.sh
#::   sh install.sh
#::
#:: You can set variables to interact with the script. Ex: to change the path to the docli repository:
#::   DOCLI=~/.devops sh install.sh

[[ -z "$DOCLI" ]] && DOCLI=${1:-} || echo "DOCLI=$DOCLI"

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
    export DOCLI="$HOME/devops"
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

########################################
# DIRECTORY CHECK AND CREATION
########################################
check_and_create_dirs() {
  echo -e "** docli-install: Creating base structure **"
  # List of directories to check and create if not present
  declare -a dirs=(
    "$DOCLI/apps/aws"
    "$DOCLI/bin"
    "$DOCLI/exports"
    "$DOCLI/functions"
    "$DOCLI/install"
    "$DOCLI/logs"
    "$DOCLI/main"
    "$DOCLI/s3"
    "$DOCLI/scripts"
    "$DOCLI/tools"
    "$DOCLI/tmp"
    "$DOCLI/.private"
  )
  # Loop through each directory and check if it exists
  for dir in "${dirs[@]}"; do
    eval dir_expanded=$dir  # Expand the tilde to the user's home directory

    if [[ -d "$dir_expanded" ]]; then
      echo "$dir_expanded already exists"
    else
      echo "$dir_expanded does not exist. Creating..."
      mkdir -p "$dir_expanded"
    fi
  done
}

check_and_create_dirs

# Define file paths
declare -a file_paths=(
  ".version"
  ".docli"
  "bin/docheck"
  "bin/docli"
  "bin/runbuild"
  "bin/runpacker"
  "bin/runtf"
  "bin/setenv"
  "functions/bash_aws_copy_credentials"
  "functions/bash_aws_local_sso_temp_creds"
  "functions/bash_azure"
  # "functions/bash_base_get_arguments"
  # "functions/bash_base_get_arguments_local"
  "functions/bash_basic_aws_profiles"
  "functions/bash_basic_cloud_providers"
  "functions/bash_basic_environments"
  "functions/bash_basic_functions"
  "functions/bash_basic_source_files_or_dir_check"
  "functions/bash_colors_tput"
  "functions/bash_git_private_dir"
  "functions/bash_gpg_key"
  "functions/bash_hashicorp_vault"
  "functions/bash_k8s"
  "functions/bash_k8s_secrets"
  "functions/bash_multios"
  "functions/bash_op"
  "functions/bash_os_check"
  "functions/bash_set"
  "functions/bash_terraform"
  "functions/bash_terraform_get_base_files"
  "functions/x_docli_pre_envs"
  "functions/x_docli_module_array"
  "functions/docli_pre_envs"
  "functions/docli_module_array"
  "functions/output_source_files"
  "functions/runbuild_call"
  "functions/runtf_call"
  "functions/runpacker_call"
  "main/packer"
  "main/setup"
  "main/sso"
  "main/sys"
  "main/x_docheck"
  "main/x_docli"
  "main/x_runbuild"
  "main/x_runpacker"
  "main/x_runtf"
  "main/x_setenv"
  "scripts/docli_aws_copy_token_credentials"
  "scripts/docli_generate_markdown_doc"
  "scripts/docli_colors_tput"
  "tools/ca-generator/client-certificates/run"
  "tools/ca-generator/client-certificates/validate_remote_cert"
)

# Define special directories for tools
declare -a tool_dirs=(
  # "tools/ai"
  "tools/ca-generator"
  "tools/aws-account-cleaner"
  "tools/aws-instance-backup-to-ami"
  "tools/aws-rds-connectivity-tests"
  "tools/aws-vpc-connectivity-tests"
  "tools/aws-instance-backup-to-ami"
  "tools/gcp-storage-bucket-cleanup"
  # "tools/gpg-import-keys"
  # "tools/gpg-key-service-accounts"
  # "tools/gcp-storage-bucket-copy"
  # "tools/macos-troubleshoot"
  # "tools/mfa-expect"
)

# Copy or download function
copy_or_download() {
  local install_local=$1
  local repo_path=$2
  local target_path=$3

  for file_path in "${file_paths[@]}"; do
    if [[ $install_local == true ]]; then
      echo "Copying $file_path"
      cp "$repo_path/.devops/$file_path" "$target_path/$file_path"
      # if [[ $file_path == ".docli" ]]; then
      #   cp "$repo_path/$file_path" "$target_path/$file_path"
      # else
      #   cp "$repo_path/.devops/$file_path" "$target_path/$file_path"
      # fi
    else
      echo "Downloading $file_path"
      curl -sL "$DOCLI_REMOTE_REPOSITORY/.devops/$file_path" -H "Cache-Control: no-cache, no-store" -o "$target_path/$file_path" || echo "* Error downloading $file_path *"
    fi
  done

  for dir in "${tool_dirs[@]}"; do
    [[ ! -d "$target_path/$dir" ]] && mkdir -p "$target_path/$dir"
    if [[ $install_local == true ]]; then
      echo "Copying directory $dir"
      cp -R "$repo_path/.devops/$dir/"* "$target_path/$dir"
      # if [[ $file_path == ".docli" ]]; then
      #   cp -R "$repo_path/$dir/"* "$target_path/$dir"
      # else
      #   cp -R "$repo_path/.devops/$dir/"* "$target_path/$dir"
      # fi
    else
      # echo "Downloading $dir"
      # curl -sL "$DOCLI_REMOTE_REPOSITORY/.devops/$file_path" -H "Cache-Control: no-cache, no-store" -o "$target_path/$file_path" || echo "* Error downloading $file_path *"
      # TODO: Download tools logic here...
      echo "Download logic for tools not implemented"
    fi
  done

  if [[ $install_local == true ]]; then
    cp "$repo_path/resources/omz-zsh/themes/devops.click.zsh-theme" "$HOME/.oh-my-zsh/themes/devops.click.zsh-theme"
  else
    curl -sL "$DOCLI_REMOTE_REPOSITORY/resources/omz-zsh/themes/devops.click.zsh-theme" -H "Cache-Control: no-cache, no-store" -o "$HOME/.oh-my-zsh/themes/devops.click.zsh-theme" || echo "* Error downloading devops.click.zsh-theme *"
  fi
}

# Main logic - deploy - put in here to keep logic in one place only
if [[ $DOCLI_DEPLOY == true ]]; then
  echo -e "** docli-deploy: Deploying to config dir **"
  copy_or_download true "$DOCLI_REPOSITORY" "$HOME/Documents/GitHub/ops-config/terraform/aws/deploy/ec2-flask-tools/apps/config.devops.click/files"
fi

# Main logic - install
if [[ ${install_local:-false} == true ]]; then
  echo -e "** docli-install: Download/Updating docli files (LOCAL) **"
  copy_or_download true "$DOCLI_REPOSITORY" "$DOCLI"
else
  echo -e "** docli-install: Download/Updating docli files **"
  copy_or_download false "$DOCLI_REPOSITORY" "$DOCLI"
fi

# File Permissioning
echo -e "** docli-install: Setting file permissions **"
chmod +x $DOCLI/bin/* || echo "* Could not chmod $DOCLI/bin/ *"
chmod +x $DOCLI/main/* || echo "* Could not chmod $DOCLI/main/ *"
chmod +x $DOCLI/scripts/* || echo "* Could not chmod $DOCLI/scripts/ *"
chmod +x $DOCLI/tools/*/run || echo ""

SHOW_VERSION=(cat $DOCLI/.version)

echo -e "\n**** docli $SHOW_VERSION installed sucessfully! ****\n"
