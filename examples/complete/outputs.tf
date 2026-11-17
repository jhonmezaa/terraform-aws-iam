output "role_arns" {
  description = "Role arns created by the module."
  value       = module.iam.role_arns
}

output "role_names" {
  description = "Role names created by the module."
  value       = module.iam.role_names
}

output "policy_arns" {
  description = "Policy arns created by the module."
  value       = module.iam.policy_arns
}

output "user_arns" {
  description = "User arns created by the module."
  value       = module.iam.user_arns
}

output "group_arns" {
  description = "Group arns created by the module."
  value       = module.iam.group_arns
}

output "group_names" {
  description = "Group names created by the module."
  value       = module.iam.group_names
}

output "instance_profile_arns" {
  description = "Instance profile arns created by the module."
  value       = module.iam.instance_profile_arns
}

output "oidc_provider_arns" {
  description = "Oidc provider arns created by the module."
  value       = module.iam.oidc_provider_arns
}
