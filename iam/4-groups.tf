# =============================================================================
# IAM Groups
# =============================================================================

resource "aws_iam_group" "this" {
  for_each = local.all_groups

  name = coalesce(
    each.value.name,
    "${local.name_prefix}iam-group-${var.account_name}-${var.project_name}-${each.key}"
  )

  path = each.value.path
}

# =============================================================================
# IAM Group - Membership
# =============================================================================

resource "aws_iam_group_membership" "this" {
  for_each = {
    for key, group in local.all_groups : key => group
    if length(group.user_names) > 0
  }

  name  = "${aws_iam_group.this[each.key].name}-membership"
  group = aws_iam_group.this[each.key].name
  users = each.value.user_names
}

# =============================================================================
# IAM Group - Managed Policy Attachments
# =============================================================================

resource "aws_iam_group_policy_attachment" "this" {
  for_each = local.group_policy_attachments

  group      = aws_iam_group.this[each.value.group_key].name
  policy_arn = each.value.policy_arn
}

# =============================================================================
# IAM Group - Inline Policies
# =============================================================================

resource "aws_iam_group_policy" "this" {
  for_each = local.group_inline_policies

  name   = each.value.policy_name
  group  = aws_iam_group.this[each.value.group_key].name
  policy = each.value.policy
}
