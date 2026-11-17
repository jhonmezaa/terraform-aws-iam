locals {
  # =============================================================================
  # Region Prefix Mapping
  # =============================================================================

  region_prefix_map = {
    # US Regions
    "us-east-1" = "ause1"
    "us-east-2" = "ause2"
    "us-west-1" = "ausw1"
    "us-west-2" = "ausw2"
    # EU Regions
    "eu-west-1"    = "euwe1"
    "eu-west-2"    = "euwe2"
    "eu-west-3"    = "euwe3"
    "eu-central-1" = "euce1"
    "eu-central-2" = "euce2"
    "eu-north-1"   = "euno1"
    "eu-south-1"   = "euso1"
    "eu-south-2"   = "euso2"
    # AP Regions
    "ap-southeast-1" = "apse1"
    "ap-southeast-2" = "apse2"
    "ap-southeast-3" = "apse3"
    "ap-southeast-4" = "apse4"
    "ap-northeast-1" = "apne1"
    "ap-northeast-2" = "apne2"
    "ap-northeast-3" = "apne3"
    "ap-south-1"     = "apso1"
    "ap-south-2"     = "apso2"
    "ap-east-1"      = "apea1"
    # SA Regions
    "sa-east-1" = "saea1"
    # CA Regions
    "ca-central-1" = "cace1"
    "ca-west-1"    = "cawe1"
    # ME Regions
    "me-south-1"   = "meso1"
    "me-central-1" = "mece1"
    # AF Regions
    "af-south-1" = "afso1"
    # IL Regions
    "il-central-1" = "ilce1"
  }

  region_prefix = var.region_prefix != null ? var.region_prefix : lookup(
    local.region_prefix_map,
    data.aws_region.current.region,
    data.aws_region.current.region
  )

  # Name prefix: includes region prefix with trailing dash, or empty string
  name_prefix = var.use_region_prefix ? "${local.region_prefix}-" : ""

  # =============================================================================
  # Account and Partition Info
  # =============================================================================

  dns_suffix = data.aws_partition.current.dns_suffix

  # =============================================================================
  # Tags
  # =============================================================================

  # var.tags is kept for backward compatibility; it overrides var.tags_common on key conflicts
  tags = merge(var.tags_common, var.tags)

  # =============================================================================
  # IAM Roles - Trust Policy Construction
  # =============================================================================

  # Build trust policy documents for roles that don't provide raw assume_role_policy
  roles_with_generated_policy = {
    for key, role in var.roles : key => role
    if var.create && role.assume_role_policy == null
  }

  # All roles to create
  all_roles = {
    for key, role in var.roles : key => role
    if var.create
  }

  # Role names: truncated to 64 chars (AWS IAM limit), trailing hyphen removed.
  # Instance profiles reuse the role name.
  role_names = {
    for key, role in local.all_roles : key => coalesce(
      role.name,
      trimsuffix(substr("${local.name_prefix}iam-role-${var.account_name}-${var.project_name}-${key}", 0, 64), "-")
    )
  }

  # =============================================================================
  # IAM Role - Managed Policy Attachments (flattened)
  # =============================================================================

  role_policy_attachments = merge([
    for role_key, role in local.all_roles : {
      for idx, policy_arn in role.managed_policy_arns :
      "${role_key}:${idx}" => {
        role_key   = role_key
        policy_arn = policy_arn
      }
    }
  ]...)

  # =============================================================================
  # IAM Role - Inline Policies (flattened)
  # =============================================================================

  role_inline_policies = merge([
    for role_key, role in local.all_roles : {
      for policy_name, policy_doc in role.inline_policies :
      "${role_key}:${policy_name}" => {
        role_key    = role_key
        policy_name = policy_name
        policy      = policy_doc
      }
    }
  ]...)

  # =============================================================================
  # IAM Role - Instance Profiles
  # =============================================================================

  instance_profiles = {
    for key, role in local.all_roles : key => role
    if role.create_instance_profile
  }

  # =============================================================================
  # IAM Policies
  # =============================================================================

  all_policies = {
    for key, policy in var.policies : key => policy
    if var.create
  }

  # Policy names: truncated to 128 chars (AWS IAM limit), trailing hyphen removed
  policy_names = {
    for key, policy in local.all_policies : key => coalesce(
      policy.name,
      trimsuffix(substr("${local.name_prefix}iam-policy-${var.account_name}-${var.project_name}-${key}", 0, 128), "-")
    )
  }

  # =============================================================================
  # IAM Users
  # =============================================================================

  all_users = {
    for key, user in var.users : key => user
    if var.create
  }

  # User managed policy attachments (flattened)
  user_policy_attachments = merge([
    for user_key, user in local.all_users : {
      for idx, policy_arn in user.managed_policy_arns :
      "${user_key}:${idx}" => {
        user_key   = user_key
        policy_arn = policy_arn
      }
    }
  ]...)

  # User inline policies (flattened)
  user_inline_policies = merge([
    for user_key, user in local.all_users : {
      for policy_name, policy_doc in user.inline_policies :
      "${user_key}:${policy_name}" => {
        user_key    = user_key
        policy_name = policy_name
        policy      = policy_doc
      }
    }
  ]...)

  # =============================================================================
  # IAM Groups
  # =============================================================================

  all_groups = {
    for key, group in var.groups : key => group
    if var.create
  }

  # Group names: truncated to 128 chars (AWS IAM limit), trailing hyphen removed
  group_names = {
    for key, group in local.all_groups : key => coalesce(
      group.name,
      trimsuffix(substr("${local.name_prefix}iam-group-${var.account_name}-${var.project_name}-${key}", 0, 128), "-")
    )
  }

  # Group managed policy attachments (flattened)
  group_policy_attachments = merge([
    for group_key, group in local.all_groups : {
      for idx, policy_arn in group.managed_policy_arns :
      "${group_key}:${idx}" => {
        group_key  = group_key
        policy_arn = policy_arn
      }
    }
  ]...)

  # Group inline policies (flattened)
  group_inline_policies = merge([
    for group_key, group in local.all_groups : {
      for policy_name, policy_doc in group.inline_policies :
      "${group_key}:${policy_name}" => {
        group_key   = group_key
        policy_name = policy_name
        policy      = policy_doc
      }
    }
  ]...)

  # =============================================================================
  # OIDC Providers
  # =============================================================================

  all_oidc_providers = {
    for key, provider in var.oidc_providers : key => provider
    if var.create
  }

  # =============================================================================
  # Account Settings
  # =============================================================================

  create_account_settings = var.create && var.account_settings != null
  # try() keeps these null-safe on Terraform < 1.12, where && does not short-circuit
  create_password_policy = local.create_account_settings && try(var.account_settings.password_policy, null) != null
  create_account_alias   = local.create_account_settings && try(var.account_settings.account_alias, null) != null
}
