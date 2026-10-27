# Changelog


## [v1.1.3] - 2026-10-27

### Changed

- Use minimum-only version constraints in the reusable module: AWS provider `~> 6.0` -> `>= 6.0`
- Set module `required_version` to `>= 1.3` (was `~> 1.0`): the module uses `optional()` object type attributes, introduced in Terraform 1.3
- Example root modules keep pessimistic `~>` constraints (AWS provider `~> 6.0`, Terraform `~> 1.3`)
- Update requirements in README accordingly

## [v1.1.2] - 2026-04-25

### Changed

- Update README documentation and CHANGELOG formatting

All notable changes to this project will be documented in this file.

## [1.0.0] - 2026-02-27

### Added

- IAM Roles with support for trusted services, cross-account trust, and OIDC federation
- IAM Managed Policies with customizable names, descriptions, and paths
- IAM Users with optional login profiles, access keys, group membership, and policy attachments
- IAM Groups with managed policy attachments, inline policies, and user membership
- IAM Instance Profiles linked to IAM roles
- OIDC Providers for GitHub Actions, EKS IRSA, and custom providers
- Account Settings including password policy and account alias
- Unified naming convention with region prefix support
- Basic and complete examples
