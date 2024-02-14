# DevOps.click Base Setup Script

## Introduction

The **DevOps.click** Installation Script is a versatile tool designed to set up your environment efficiently. It detects your operating system, installs essential packages, creates necessary directories, and configures environment variables. It's compatible with a range of Linux distributions, MacOS, and Windows Subsystem for Linux (WSL).

## Prerequisites

- Root or sudo privileges are required for the script to run successfully.
- For MacOS users, [Homebrew](https://brew.sh/) must be installed for package management.
- For WSL users, a Debian/Ubuntu-based distribution is assumed.

## Usage

To run the script, use the following command:

```bash
curl -s https://config.devops.click/install.sh | sudo bash -s -- [OPTIONS]
```

### Options

- `--install-dir <path>`  : Specify the installation directory. Defaults to `/opt/docli` for Linux and `$HOME/docli` for MacOS and WSL.
- `--api-url <url>`       : Set the API URL. Defaults to `https://api.devops.click/v1/setup`.
- `--mail-default <email>`: Default email address for various configurations.
- `--mail-admin <email>`  : Email address for the admin team.
- `--mail-ops <email>`    : Email address for the operations team.
- `--mail-sec <email>`    : Email address for the security team.
- `--mail-data <email>`   : Email address for the data team.
- `--mail-dev <email>`    : Email address for the development team.
- `--mail-gdpr <email>`   : Email address for GDPR-related communications.

### Example

```bash
curl -s https://configs.devops.click/install.sh | sudo bash -s -- \
--install-dir "/custom/install/dir" \
--api-url "https://new.api.url" \
--mail-default "defaultmail@devops.click"
```

## Script Functionality

- **Root/Sudo Check**:        Ensures the script is run with appropriate privileges.
- **OS Detection**:           Automatically identifies the operating system (including WSL and MacOS) and its version.
- **Architecture Detection**: Determines the machine's architecture (ARM64 or x86_64).
- **Package Installation**:   Updates the system and installs `nano` and `jq`.
- **Directory Creation**:     Creates a set of directories under the specified installation path.
- **Environment File**:       Generates a `.docli_envs` file in the installation directory with configurable environment variables.

## Notes

- Ensure that the environment variables and email addresses are set according to your organization's requirements.
- The script's behavior might vary depending on the specific configuration of the operating system.
