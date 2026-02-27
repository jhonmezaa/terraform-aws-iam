# =============================================================================
# OIDC Providers
# =============================================================================

resource "aws_iam_openid_connect_provider" "this" {
  for_each = local.all_oidc_providers

  url             = each.value.url
  client_id_list  = length(each.value.client_id_list) > 0 ? each.value.client_id_list : ["sts.${local.dns_suffix}"]
  thumbprint_list = each.value.thumbprint_list

  tags = merge(var.tags, each.value.tags)
}
