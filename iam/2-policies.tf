# =============================================================================
# IAM Managed Policies
# =============================================================================

resource "aws_iam_policy" "this" {
  for_each = local.all_policies

  name = local.policy_names[each.key]

  description = each.value.description
  path        = each.value.path
  policy      = each.value.policy

  tags = merge(local.tags, each.value.tags, {
    Name      = local.policy_names[each.key]
    ManagedBy = "Terraform"
  })
}
