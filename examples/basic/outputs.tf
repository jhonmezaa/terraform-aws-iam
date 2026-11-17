output "role_arns" {
  description = "Role arns created by the module."
  value       = module.iam.role_arns
}

output "policy_arns" {
  description = "Policy arns created by the module."
  value       = module.iam.policy_arns
}

output "instance_profile_arns" {
  description = "Instance profile arns created by the module."
  value       = module.iam.instance_profile_arns
}
