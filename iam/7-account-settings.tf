# =============================================================================
# Account Alias
# =============================================================================

resource "aws_iam_account_alias" "this" {
  count = local.create_account_alias ? 1 : 0

  account_alias = var.account_settings.account_alias
}

# =============================================================================
# Account Password Policy
# =============================================================================

resource "aws_iam_account_password_policy" "this" {
  count = local.create_password_policy ? 1 : 0

  minimum_password_length        = var.account_settings.password_policy.minimum_password_length
  require_lowercase_characters   = var.account_settings.password_policy.require_lowercase_characters
  require_uppercase_characters   = var.account_settings.password_policy.require_uppercase_characters
  require_numbers                = var.account_settings.password_policy.require_numbers
  require_symbols                = var.account_settings.password_policy.require_symbols
  allow_users_to_change_password = var.account_settings.password_policy.allow_users_to_change_password
  max_password_age               = var.account_settings.password_policy.max_password_age
  password_reuse_prevention      = var.account_settings.password_policy.password_reuse_prevention
  hard_expiry                    = var.account_settings.password_policy.hard_expiry
}
