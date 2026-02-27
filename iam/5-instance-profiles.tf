# =============================================================================
# IAM Instance Profiles
# =============================================================================

resource "aws_iam_instance_profile" "this" {
  for_each = local.instance_profiles

  name = aws_iam_role.this[each.key].name
  role = aws_iam_role.this[each.key].name
  path = each.value.path

  tags = merge(var.tags, each.value.tags)

  lifecycle {
    create_before_destroy = true
  }
}
