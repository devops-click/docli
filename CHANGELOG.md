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
