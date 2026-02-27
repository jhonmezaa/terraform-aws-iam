# =============================================================================
# General Configuration Variables
# =============================================================================

variable "create" {
  description = "Whether to create IAM resources. Affects all resources in this module."
  type        = bool
  default     = true
}

variable "account_name" {
  description = "Account name for resource naming (e.g., 'prod', 'staging', 'dev')."
  type        = string

  validation {
    condition     = length(var.account_name) > 0 && length(var.account_name) <= 32
    error_message = "account_name must be between 1 and 32 characters."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.account_name))
    error_message = "account_name can only contain lowercase letters, numbers, and hyphens."
  }
}

variable "project_name" {
  description = "Project name for resource naming (e.g., 'myapp', 'platform')."
  type        = string

  validation {
    condition     = length(var.project_name) > 0 && length(var.project_name) <= 32
    error_message = "project_name must be between 1 and 32 characters."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "project_name can only contain lowercase letters, numbers, and hyphens."
  }
}

variable "region_prefix" {
  description = "Region prefix for naming. If not provided, will be derived from current region."
  type        = string
  default     = null
}

variable "use_region_prefix" {
  description = "Whether to include the region prefix in resource names."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags to apply to all IAM resources that support tagging."
  type        = map(string)
  default     = {}
}

# =============================================================================
# IAM Roles
# =============================================================================

variable "roles" {
  description = <<-EOT
    Map of IAM roles to create. Each key is a logical identifier for the role.
    Supports trusted services, cross-account trust, OIDC federation, raw assume role policies,
    managed policy attachments, inline policies, and instance profile creation.
  EOT
  type = map(object({
    name                  = optional(string)
    description           = optional(string)
    path                  = optional(string, "/")
    max_session_duration  = optional(number, 3600)
    force_detach_policies = optional(bool, false)
    permissions_boundary  = optional(string)

    # Trust policy / assume role
    assume_role_policy = optional(string) # Raw JSON trust policy (takes precedence)
    trusted_services   = optional(list(string), [])
    trusted_role_arns  = optional(list(string), [])
    trusted_oidc_providers = optional(list(object({
      provider_arn = string
      conditions = list(object({
        test     = string
        variable = string
        values   = list(string)
      }))
    })), [])

    # Attached policies
    managed_policy_arns = optional(list(string), [])
    inline_policies     = optional(map(string), {})

    # Instance profile
    create_instance_profile = optional(bool, false)

    tags = optional(map(string), {})
  }))
  default = {}
}

# =============================================================================
# IAM Policies
# =============================================================================

variable "policies" {
  description = <<-EOT
    Map of IAM managed policies to create. Each key is a logical identifier for the policy.
    The policy value must be a valid JSON IAM policy document.
  EOT
  type = map(object({
    name        = optional(string)
    description = optional(string)
    path        = optional(string, "/")
    policy      = string
    tags        = optional(map(string), {})
  }))
  default = {}
}

# =============================================================================
# IAM Users
# =============================================================================

variable "users" {
  description = <<-EOT
    Map of IAM users to create. Each key is a logical identifier for the user.
    Supports login profiles, access keys, group membership, managed and inline policies.
  EOT
  type = map(object({
    name                 = optional(string)
    path                 = optional(string, "/")
    permissions_boundary = optional(string)
    force_destroy        = optional(bool, false)

    # Login profile
    create_login_profile    = optional(bool, false)
    pgp_key                 = optional(string)
    password_length         = optional(number, 20)
    password_reset_required = optional(bool, true)

    # Access key
    create_access_key = optional(bool, false)
    access_key_status = optional(string)

    # Policies and groups
    managed_policy_arns = optional(list(string), [])
    inline_policies     = optional(map(string), {})
    groups              = optional(list(string), [])

    tags = optional(map(string), {})
  }))
  default = {}
}

# =============================================================================
# IAM Groups
# =============================================================================

variable "groups" {
  description = <<-EOT
    Map of IAM groups to create. Each key is a logical identifier for the group.
    Supports managed policy attachments, inline policies, and user membership lists.
  EOT
  type = map(object({
    name = optional(string)
    path = optional(string, "/")

    # Policies
    managed_policy_arns = optional(list(string), [])
    inline_policies     = optional(map(string), {})

    # Users to add to this group
    user_names = optional(list(string), [])
  }))
  default = {}
}

# =============================================================================
# OIDC Providers
# =============================================================================

variable "oidc_providers" {
  description = <<-EOT
    Map of OIDC providers to create. Each key is a logical identifier for the provider.
    Commonly used for GitHub Actions and EKS OIDC integration.
  EOT
  type = map(object({
    url             = string
    client_id_list  = optional(list(string), [])
    thumbprint_list = optional(list(string), [])
    tags            = optional(map(string), {})
  }))
  default = {}
}

# =============================================================================
# Account Settings
# =============================================================================

variable "account_settings" {
  description = <<-EOT
    Account-level IAM settings including password policy and account alias.
    Set to null to skip account settings entirely.
  EOT
  type = object({
    account_alias = optional(string)

    password_policy = optional(object({
      minimum_password_length        = optional(number, 14)
      require_lowercase_characters   = optional(bool, true)
      require_uppercase_characters   = optional(bool, true)
      require_numbers                = optional(bool, true)
      require_symbols                = optional(bool, true)
      allow_users_to_change_password = optional(bool, true)
      max_password_age               = optional(number, 90)
      password_reuse_prevention      = optional(number, 24)
      hard_expiry                    = optional(bool, false)
    }))
  })
  default = null
}
