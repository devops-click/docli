#!/usr/bin/env bash
# [[ "${DOCLI_DEBUG:-off}" == "on" ]]       && set -exo pipefail || set -eo pipefail
# [[ "${DOCLI_UNSET_VARS:-off}" == "on" ]]  && set -u
############################################################################### #dltbr
#              https://DevOps.click - DevOps taken seriously                  # #dltbr
###############################################################################
#                               docli_base_setup
###############################################################################

## DOCLI MODULE INFORMATION
DOCLI_MODULE_VERSION="0.0.01"
[[ "${BASH_SOURCE[0]}" != "" ]] && DOCLI_MODULE="$(basename "${BASH_SOURCE[0]}")"                                             || DOCLI_MODULE="$(basename "$0")"
[[ "${BASH_SOURCE[0]}" != "" ]] && DOCLI_MODULE_TYPE="$(basename "$(dirname "$(realpath "${BASH_SOURCE[0]}")")")"             || DOCLI_MODULE_TYPE="$(basename "$(dirname "$(realpath "$0")")")"
[[ "${BASH_SOURCE[0]}" != "" ]] && DOCLI_MODULE_UPPER=$(echo "$(basename "${BASH_SOURCE[0]}")"  | tr '[:lower:]' '[:upper:]') || DOCLI_MODULE_UPPER=$(echo "$(basename "$0")" | tr '[:lower:]' '[:upper:]')
##[[ "${DOCLI_MODULE_ARRAY_SOURCE:-on}" == "on" ]] && source ${DOCLI_DIR:-$DOCLI}/functions/docli_module_array

## VERBOSE INFORMATION
[[ "${DOCLI_VERBOSE:-off}" == "on" ]] && echo -e "\n***** $DOCLI_MODULE version $DOCLI_MODULE_VERSION ($DOCLI_MODULE_TYPE) *****\n"

# Function to check and add line to a file
check_and_add_line() {
  LINE=$1
  FILE=$2
  grep -qF -- "$LINE" "$FILE" || echo "$LINE" >> "$FILE"
}

# Check for root/sudo permissions
if [ "$(id -u)" != "0" ]; then
  echo "This script requires root privileges. Please run as root or use sudo."
  exit 1
fi

# Default values (will be adjusted based on OS detection)
install_dir="/opt/docli"
api_url="https://api.devops.click/v1/setup"
mail_default="yourmail@yourdomain.com"

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --install-dir) install_dir="$2"; shift ;;
    --api-url) api_url="$2"; shift ;;
    --mail-default) mail_default="$2"; shift ;;
    --mail-admin) mail_admin="$2"; shift ;;
    --mail-ops) mail_ops="$2"; shift ;;
    --mail-sec) mail_sec="$2"; shift ;;
    --mail-data) mail_data="$2"; shift ;;
    --mail-dev) mail_dev="$2"; shift ;;
    --mail-gdpr) mail_gdpr="$2"; shift ;;
    *) echo "Unknown parameter passed: $1"; exit 1 ;;
  esac
  shift
done

# Set individual mail variables if not set
mail_admin=${mail_admin:-$mail_default}
mail_ops=${mail_ops:-$mail_default}
mail_sec=${mail_sec:-$mail_default}
mail_data=${mail_data:-$mail_default}
mail_dev=${mail_dev:-$mail_default}
mail_gdpr=${mail_gdpr:-$mail_default}

# Detect OS, Version, and Architecture
OS=""
VERSION=""
ARCH=$(uname -m)

case "$(uname -s)" in
  Linux*|MINGW*|MSYS*|CYGWIN*)
    if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null ; then
      export OS="wsl"
      export install_dir="$HOME/docli"
    elif [ -f /etc/os-release ]; then
      . /etc/os-release
      export OS=$ID
      export VERSION=$VERSION_ID
    else
      echo "Unable to determine Linux distribution."
      exit 1
    fi
    ;;
  Darwin*)
    export OS="macos"
    export VERSION=$(sw_vers -productVersion)
    export install_dir="$HOME/docli"
    ;;
  *)
    echo "Unsupported operating system."
    exit 1
    ;;
esac

echo "OS detected: $OS $VERSION"
echo "Architecture: $ARCH"

# OS-specific package installation and updates
case $OS in
  ubuntu|debian|linuxmint)
    # apt-get update && apt-get upgrade -y
    apt-get install -y nano jq
    ;;
  centos|rhel|fedora|amzn)
    # yum update -y
    yum install -y nano jq
    ;;
  macos)
    # softwareupdate --install --all
    brew install nano jq
    ;;
  wsl)
    # apt-get update && apt-get upgrade -y || yum update -y || echo "* Could not install packages inside your WSL environment *"
    apt-get install -y nano jq || yum install -y nano jq || echo "* Could not install packages inside your WSL environment *"
    ;;
  *)
    echo "Installation for $OS not supported."
    exit 1
    ;;
esac

# Create directories if they don't exist
for dir in "$install_dir/tmp" "$install_dir/bin" "$install_dir/certs" "$install_dir/.cache" "$install_dir/.private" "$install_dir/scripts" "$install_dir/functions"; do
  [ ! -d "$dir" ] && mkdir -p "$dir"
done

# Create or update .docli_envs file
env_file="$install_dir/.docli_envs"
touch "$env_file"
check_and_add_line "DOCLI=\"${DOCLI:-$install_dir}\"" "/etc/environment"
check_and_add_line "DOCLI=\"${DOCLI:-$install_dir}\"" "$env_file"
check_and_add_line "DOCLI_PROJECT_ROOT=\"/opt/docli\"" "/etc/environment"
check_and_add_line "DOCLI_PROJECT_ROOT=\"/opt/docli\"" "$env_file"
check_and_add_line "DOCLI_SYS_API_URL=\"$api_url\"" "/etc/environment"
check_and_add_line "DOCLI_SYS_API_URL=\"$api_url\"" "$env_file"
check_and_add_line "DOCLI_CONFIG_TEAM_MAIL_ADMIN=\"$mail_admin\"" "/etc/environment"
check_and_add_line "DOCLI_CONFIG_TEAM_MAIL_ADMIN=\"$mail_admin\"" "$env_file"
check_and_add_line "DOCLI_CONFIG_TEAM_MAIL_OPS=\"$mail_ops\"" "/etc/environment"
check_and_add_line "DOCLI_CONFIG_TEAM_MAIL_OPS=\"$mail_ops\"" "$env_file"
check_and_add_line "DOCLI_CONFIG_TEAM_MAIL_SEC=\"$mail_sec\"" "/etc/environment"
check_and_add_line "DOCLI_CONFIG_TEAM_MAIL_SEC=\"$mail_sec\"" "$env_file"
check_and_add_line "DOCLI_CONFIG_TEAM_MAIL_DATA=\"$mail_data\"" "/etc/environment"
check_and_add_line "DOCLI_CONFIG_TEAM_MAIL_DATA=\"$mail_data\"" "$env_file"
check_and_add_line "DOCLI_CONFIG_TEAM_MAIL_DEV=\"$mail_dev\"" "/etc/environment"
check_and_add_line "DOCLI_CONFIG_TEAM_MAIL_DEV=\"$mail_dev\"" "$env_file"
check_and_add_line "DOCLI_CONFIG_TEAM_MAIL_GDPR=\"$mail_gdpr\"" "/etc/environment"
check_and_add_line "DOCLI_CONFIG_TEAM_MAIL_GDPR=\"$mail_gdpr\"" "$env_file"
check_and_add_line "DOCLI_VAR_SSL_SELFSIGNED_PK=\"$DOCLI/certs/key.pem\"" "/etc/environment"
check_and_add_line "DOCLI_VAR_SSL_SELFSIGNED_PK=\"$DOCLI/certs/key.pem\"" "$env_file"
check_and_add_line "DOCLI_VAR_SSL_SELFSIGNED_CRT=\"$DOCLI/certs/cert.pem\"" "/etc/environment"
check_and_add_line "DOCLI_VAR_SSL_SELFSIGNED_CRT=\"$DOCLI/certs/cert.pem\"" "$env_file"

echo "* DOCLI: Basic Setup complete *"
