# =============================================================================
# IAM Roles
# =============================================================================

output "roles" {
  description = "Map of IAM roles created, keyed by the role identifier."
  value = {
    for key, role in aws_iam_role.this : key => {
      arn       = role.arn
      name      = role.name
      unique_id = role.unique_id
    }
  }
}

output "role_arns" {
  description = "Map of IAM role ARNs, keyed by role identifier."
  value = {
    for key, role in aws_iam_role.this : key => role.arn
  }
}

output "role_names" {
  description = "Map of IAM role names, keyed by role identifier."
  value = {
    for key, role in aws_iam_role.this : key => role.name
  }
}

# =============================================================================
# IAM Instance Profiles
# =============================================================================

output "instance_profiles" {
  description = "Map of IAM instance profiles created, keyed by role identifier."
  value = {
    for key, profile in aws_iam_instance_profile.this : key => {
      arn       = profile.arn
      name      = profile.name
      unique_id = profile.unique_id
    }
  }
}

output "instance_profile_arns" {
  description = "Map of IAM instance profile ARNs, keyed by role identifier."
  value = {
    for key, profile in aws_iam_instance_profile.this : key => profile.arn
  }
}

# =============================================================================
# IAM Policies
# =============================================================================

output "policies" {
  description = "Map of IAM policies created, keyed by policy identifier."
  value = {
    for key, policy in aws_iam_policy.this : key => {
      arn  = policy.arn
      name = policy.name
      id   = policy.id
    }
  }
}

output "policy_arns" {
  description = "Map of IAM policy ARNs, keyed by policy identifier."
  value = {
    for key, policy in aws_iam_policy.this : key => policy.arn
  }
}

# =============================================================================
# IAM Users
# =============================================================================

output "users" {
  description = "Map of IAM users created, keyed by user identifier."
  value = {
    for key, user in aws_iam_user.this : key => {
      arn       = user.arn
      name      = user.name
      unique_id = user.unique_id
    }
  }
}

output "user_arns" {
  description = "Map of IAM user ARNs, keyed by user identifier."
  value = {
    for key, user in aws_iam_user.this : key => user.arn
  }
}

output "user_login_profiles" {
  description = "Map of IAM user login profile details (encrypted passwords)."
  value = {
    for key, profile in aws_iam_user_login_profile.this : key => {
      encrypted_password = profile.encrypted_password
      key_fingerprint    = profile.key_fingerprint
    }
  }
}

output "user_access_keys" {
  description = "Map of IAM user access key details. Secret is sensitive."
  value = {
    for key, access_key in aws_iam_access_key.this : key => {
      id                             = access_key.id
      encrypted_secret               = access_key.encrypted_secret
      key_fingerprint                = access_key.key_fingerprint
      encrypted_ses_smtp_password_v4 = access_key.encrypted_ses_smtp_password_v4
    }
  }
}

output "user_access_key_ids" {
  description = "Map of IAM user access key IDs, keyed by user identifier."
  value = {
    for key, access_key in aws_iam_access_key.this : key => access_key.id
  }
}

output "user_access_key_secrets" {
  description = "Map of IAM user access key secrets (sensitive), keyed by user identifier."
  value = {
    for key, access_key in aws_iam_access_key.this : key => access_key.secret
  }
  sensitive = true
}

# =============================================================================
# IAM Groups
# =============================================================================

output "groups" {
  description = "Map of IAM groups created, keyed by group identifier."
  value = {
    for key, group in aws_iam_group.this : key => {
      arn       = group.arn
      name      = group.name
      unique_id = group.unique_id
      id        = group.id
    }
  }
}

output "group_arns" {
  description = "Map of IAM group ARNs, keyed by group identifier."
  value = {
    for key, group in aws_iam_group.this : key => group.arn
  }
}

output "group_names" {
  description = "Map of IAM group names, keyed by group identifier."
  value = {
    for key, group in aws_iam_group.this : key => group.name
  }
}

# =============================================================================
# OIDC Providers
# =============================================================================

output "oidc_providers" {
  description = "Map of OIDC providers created, keyed by provider identifier."
  value = {
    for key, provider in aws_iam_openid_connect_provider.this : key => {
      arn = provider.arn
      url = provider.url
    }
  }
}

output "oidc_provider_arns" {
  description = "Map of OIDC provider ARNs, keyed by provider identifier."
  value = {
    for key, provider in aws_iam_openid_connect_provider.this : key => provider.arn
  }
}

# =============================================================================
# Account Settings
# =============================================================================

output "account_password_policy_expire_passwords" {
  description = "Whether passwords in the account expire."
  value       = try(aws_iam_account_password_policy.this[0].expire_passwords, null)
}
