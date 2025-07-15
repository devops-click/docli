# Changelog
All notable changes to this project will be documented in this file.

## [Unreleased]
### Added
- New feature that does X.

### Changed
- Updates to function Y due to reasons Z.

## [0.0.04] - 2023-09-13
### Added
- Added Installation Script.
- Added docli.
- Added 1Password function.
- Added Packer module.
- Added Setup module. (For MacOS and Linux auto-config)
- Added SSO module. (For SSO Interactions, for instance AWS and Azure)
- Added SYS module. (System functions)
- Added Template for .docli_envs

## [0.0.05] - 2023-10-09
### Added
- `main/setup` functionalities:
  - Added older releases fix section.
  - Added new functions and new functionalities.
  - Moved java installation for a new function to enable granular selection of packages or --skip function.
  - Added support for Linux system setups.
  - Added skip function for --skip.
- Minor ajdustments on `main/packer`.

### Fixed
- Fixed a bug on `main/setup` version `1.2` that wrongly added the `$PATH` to the variable `TFENV_ARCH`.
- Fixed a bug on `main/setup` version `1.2` that wrongly duplicate entries like elasticsearch on version change. Now it will upsert entries.

### Removed
- Deprecated feature A in favor of feature X.

## [0.0.06] - 2024-08-05
### Improved
- `main/setup` functionalities:
  - Package Installation Lists and TAPS to reduce duplicated code.
- `bin/runtf` functionalities:
  - Upgraded Default Terraform from `1.6.3` to `1.9.3` (latest).

...

## [0.0.22] - 2024-10-04
### Improved
- `all_modules` functionalities:
  - Removes unused functions.
  - Changes DOCLI_DEBUG call.
  - Changes bash set options and set them dynamically.
- RESETs all modules but .devops/version to version 0.0.01 so they can follow the same standards.

## [0.0.23] - 2024-10-08
### Improved
- `all_modules` functionalities:
  - Fixes all DOCLI_DEBUG/UNSET/VERBOSE arguments. Changes from true/false to on/off so it does not break 1 line comparisons.

## [0.0.24] - 2024-10-08
### Improved
- Fixes sourcing in docli, docheck and runbuild.

## [0.0.25] - 2024-10-08
### Improved
- Fixes problems with realpath and sourced scripts.
- Significant changes in DOCLI main info mode
- Adds `docli_generate_markdown_doc`
- Adds `docli_module_array`/`x_docli_module_array`

## [0.0.26] - 2024-10-08
### Improved
- Adds logging for all main functions into `$DOCLI/logs/`.

## [0.0.27] - 2024-10-09
### Improved
- Fixes setenv problem that causes shell to break.
- Updates client cert generation process.

## [0.0.37] - 2025-01-10
### Fixes
- Fix to Nexus Container Image generation.

## [0.0.38] - 2025-01-23
### Fixes
- Fix build images.

## [0.0.39] - 2025-01-27
### Fixes
- Fix in tools installation.

## [0.0.40] - 2025-02-11
### Improved
- Uploaded required scripts.

## [0.0.41] - 2025-04-03
### Improved
- Makes BitBucket `repository` terraform flexible, able to work with multiple terraform states in a per-project basis.

## [0.0.42] - 2025-04-04
### Fix
- Fix a issue in `runpacker_call` where a condition had incorrect brackets.

## [0.0.43] - 2025-06-02
### Improved
- Refactored `x_runbuild` to be more efficient when generating container images.

## [0.0.44] - 2025-07-15
### Improved
- `REQUIRED_TF_VERSION` set to `1.12.2` as default.
