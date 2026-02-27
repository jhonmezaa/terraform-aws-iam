# =============================================================================
# IAM Roles - Trust Policy Documents (generated from trusted_services, trusted_role_arns, trusted_oidc_providers)
# =============================================================================

data "aws_iam_policy_document" "role_trust" {
  for_each = local.roles_with_generated_policy

  # Trust AWS services (e.g., ec2.amazonaws.com, lambda.amazonaws.com)
  dynamic "statement" {
    for_each = length(each.value.trusted_services) > 0 ? [1] : []

    content {
      sid     = "AllowServiceAssume"
      effect  = "Allow"
      actions = ["sts:AssumeRole"]

      principals {
        type        = "Service"
        identifiers = each.value.trusted_services
      }
    }
  }

  # Trust cross-account or same-account IAM role ARNs
  dynamic "statement" {
    for_each = length(each.value.trusted_role_arns) > 0 ? [1] : []

    content {
      sid     = "AllowCrossAccountAssume"
      effect  = "Allow"
      actions = ["sts:AssumeRole"]

      principals {
        type        = "AWS"
        identifiers = each.value.trusted_role_arns
      }
    }
  }

  # Trust OIDC providers (GitHub Actions, EKS IRSA, etc.)
  dynamic "statement" {
    for_each = each.value.trusted_oidc_providers

    content {
      sid     = "AllowOIDCAssume${statement.key}"
      effect  = "Allow"
      actions = ["sts:AssumeRoleWithWebIdentity"]

      principals {
        type        = "Federated"
        identifiers = [statement.value.provider_arn]
      }

      dynamic "condition" {
        for_each = statement.value.conditions

        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}

# =============================================================================
# IAM Roles
# =============================================================================

resource "aws_iam_role" "this" {
  for_each = local.all_roles

  name = coalesce(
    each.value.name,
    "${local.name_prefix}iam-role-${var.account_name}-${var.project_name}-${each.key}"
  )

  description           = each.value.description
  path                  = each.value.path
  max_session_duration  = each.value.max_session_duration
  force_detach_policies = each.value.force_detach_policies
  permissions_boundary  = each.value.permissions_boundary

  assume_role_policy = coalesce(
    each.value.assume_role_policy,
    try(data.aws_iam_policy_document.role_trust[each.key].json, null)
  )

  tags = merge(var.tags, each.value.tags)
}

# =============================================================================
# IAM Role - Managed Policy Attachments
# =============================================================================

resource "aws_iam_role_policy_attachment" "this" {
  for_each = local.role_policy_attachments

  role       = aws_iam_role.this[each.value.role_key].name
  policy_arn = each.value.policy_arn
}

# =============================================================================
# IAM Role - Inline Policies
# =============================================================================

resource "aws_iam_role_policy" "this" {
  for_each = local.role_inline_policies

  name   = each.value.policy_name
  role   = aws_iam_role.this[each.value.role_key].name
  policy = each.value.policy
}
