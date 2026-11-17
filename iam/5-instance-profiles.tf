# =============================================================================
# IAM Instance Profiles
# =============================================================================

resource "aws_iam_instance_profile" "this" {
  for_each = local.instance_profiles

  name = aws_iam_role.this[each.key].name
  role = aws_iam_role.this[each.key].name
  path = each.value.path

  tags = merge(local.tags, each.value.tags, {
    Name      = aws_iam_role.this[each.key].name
    ManagedBy = "Terraform"
  })

  lifecycle {
    create_before_destroy = true
  }
}
