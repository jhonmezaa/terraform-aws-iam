# =============================================================================
# IAM Managed Policies
# =============================================================================

resource "aws_iam_policy" "this" {
  for_each = local.all_policies

  name = coalesce(
    each.value.name,
    "${local.name_prefix}iam-policy-${var.account_name}-${var.project_name}-${each.key}"
  )

  description = each.value.description
  path        = each.value.path
  policy      = each.value.policy

  tags = merge(var.tags, each.value.tags)
}
