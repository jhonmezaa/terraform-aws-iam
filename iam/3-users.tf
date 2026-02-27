# =============================================================================
# IAM Users
# =============================================================================

resource "aws_iam_user" "this" {
  for_each = local.all_users

  name                 = coalesce(each.value.name, each.key)
  path                 = each.value.path
  permissions_boundary = each.value.permissions_boundary
  force_destroy        = each.value.force_destroy

  tags = merge(var.tags, each.value.tags)
}

# =============================================================================
# IAM User - Login Profiles
# =============================================================================

resource "aws_iam_user_login_profile" "this" {
  for_each = {
    for key, user in local.all_users : key => user
    if user.create_login_profile
  }

  user                    = aws_iam_user.this[each.key].name
  pgp_key                 = each.value.pgp_key
  password_length         = each.value.password_length
  password_reset_required = each.value.password_reset_required
}

# =============================================================================
# IAM User - Access Keys
# =============================================================================

resource "aws_iam_access_key" "this" {
  for_each = {
    for key, user in local.all_users : key => user
    if user.create_access_key
  }

  user    = aws_iam_user.this[each.key].name
  pgp_key = each.value.pgp_key
  status  = each.value.access_key_status
}

# =============================================================================
# IAM User - Managed Policy Attachments
# =============================================================================

resource "aws_iam_user_policy_attachment" "this" {
  for_each = local.user_policy_attachments

  user       = aws_iam_user.this[each.value.user_key].name
  policy_arn = each.value.policy_arn
}

# =============================================================================
# IAM User - Inline Policies
# =============================================================================

resource "aws_iam_user_policy" "this" {
  for_each = local.user_inline_policies

  name   = each.value.policy_name
  user   = aws_iam_user.this[each.value.user_key].name
  policy = each.value.policy
}

# =============================================================================
# IAM User - Group Membership
# =============================================================================

resource "aws_iam_user_group_membership" "this" {
  for_each = {
    for key, user in local.all_users : key => user
    if length(user.groups) > 0
  }

  user   = aws_iam_user.this[each.key].name
  groups = each.value.groups
}
