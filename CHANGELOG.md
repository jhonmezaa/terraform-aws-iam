# Changelog

All notable changes to this project will be documented in this file.

## [v1.2.0] - 2026-11-17

### Added

- `tags_common` variable (project convention); `tags` is kept as a backward-compatible alias merged on top of it
- `Name` and `ManagedBy = "Terraform"` tags on every taggable resource
- `roles[*].trust_policy_conditions`: conditions added to every generated trust statement (e.g. `sts:ExternalId`)
- `roles[*].trust_policy_extra_actions`: extra actions for generated trust statements (e.g. `sts:TagSession`)
- `users[*].ssh_public_key`, `ssh_key_encoding` and `ssh_key_status` (`aws_iam_user_ssh_key`)
- Outputs: `policy_names`, `user_names`, `user_login_profile_passwords` (sensitive), `user_access_key_ses_smtp_passwords_v4` (sensitive), `user_ssh_keys`, `account_alias`
- Validations: `max_session_duration` range, role trust required, `access_key_status` and SSH key values
- Examples: `variables.tf` and `outputs.tf`

### Changed

- `trusted_oidc_providers[*].conditions` is now optional (defaults to `[]`)
- Generated role names are truncated to 64 characters and policy/group names to 128 (AWS limits)
- Validation error messages in Spanish (project convention)
- Remove unused `aws_caller_identity` data source and unused locals

### Fixed

- `account_settings` with only `account_alias` or only `password_policy` no longer depends on `&&` short-circuiting
- Complete example: user group membership referenced a non-existent group name (`readonly-group`); it now uses `group_keys`
- README: `source` pinned with `?ref=`, inputs/outputs aligned with the code, group membership exclusivity note

### Upgrade notes

- No resource is recreated. Taggable resources get an in-place update adding the `Name` and `ManagedBy` tags.
- Generated names that already fit the AWS limits are unchanged; longer ones were previously rejected by AWS.

## [v1.1.5] - 2026-10-27

### Changed

- Docs: normalize CHANGELOG format (preamble moved to the top, `v`-prefixed version headers)
- Docs: add missing CHANGELOG entries for v1.1.0 and v1.1.1

## [v1.1.4] - 2026-10-27

### Fixed

- Replace deprecated `data.aws_region.current.id` with `data.aws_region.current.region` (deprecated in AWS provider v6)

## [v1.1.3] - 2026-10-27

### Changed

- Use minimum-only version constraints in the reusable module: AWS provider `~> 6.0` -> `>= 6.0`
- Set module `required_version` to `>= 1.3` (was `~> 1.0`): the module uses `optional()` object type attributes, introduced in Terraform 1.3
- Example root modules keep pessimistic `~>` constraints (AWS provider `~> 6.0`, Terraform `~> 1.3`)
- Update requirements in README accordingly

## [v1.1.2] - 2026-04-25

### Changed

- Update README documentation and CHANGELOG formatting

## [v1.1.1] - 2026-02-28

### Changed

- Update README

## [v1.1.0] - 2026-02-27

### Added

- `group_keys` support for user group membership: users can reference groups created in the same module by key instead of the full generated group name

## [v1.0.0] - 2026-02-27

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
