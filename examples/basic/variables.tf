variable "aws_region" {
  description = "AWS region for the provider (also used to derive the region prefix)."
  type        = string
  default     = "us-east-1"
}

variable "account_name" {
  description = "Account name used in resource names."
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name used in resource names."
  type        = string
  default     = "myapp"
}
