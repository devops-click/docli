#!/usr/bin/env bash -eo pipefail
# Designed to be used for very fast installations
# Usage:
# curl -fsSL https://raw.githubusercontent.com/devops-click/docli/main/install_minimal.sh | bash
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/devops-click/docli/main/install_minimal.sh)"

# Create directories
[[ -d /opt/devops/bin ]]      || mkdir -p /opt/devops/bin
# [[ -d /opt/devops/scripts ]]  || mkdir -p /opt/devops/scripts

curl -fsSL https://raw.githubusercontent.com/devops-click/docli/main/.devops/docheck -o /opt/devops/bin/docheck || wget https://raw.githubusercontent.com/devops-click/docli/main/.devops/docheck -O /opt/devops/bin/docheck

sudo chmod +x /opt/devops/bin/*
# sudo chmod +x /opt/devops/scripts/*

echo "* DOCLI: Minimal installation completed successfully *"