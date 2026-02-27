provider "aws" {
  region = "us-east-1"
}

module "iam" {
  source = "../../iam"

  account_name = "dev"
  project_name = "myapp"

  # ---------------------------------------------------------------------------
  # IAM Roles
  # ---------------------------------------------------------------------------
  roles = {
    lambda-execution = {
      description      = "Lambda execution role"
      trusted_services = ["lambda.amazonaws.com"]
      managed_policy_arns = [
        "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
      ]
    }

    ec2-instance = {
      description             = "EC2 instance role for application servers"
      trusted_services        = ["ec2.amazonaws.com"]
      create_instance_profile = true
      managed_policy_arns = [
        "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      ]
    }
  }

  # ---------------------------------------------------------------------------
  # IAM Policies
  # ---------------------------------------------------------------------------
  policies = {
    s3-read = {
      description = "Allow read access to application S3 bucket"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "s3:GetObject",
              "s3:ListBucket"
            ]
            Resource = [
              "arn:aws:s3:::my-app-bucket",
              "arn:aws:s3:::my-app-bucket/*"
            ]
          }
        ]
      })
    }
  }

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

# =============================================================================
# Outputs
# =============================================================================

output "role_arns" {
  value = module.iam.role_arns
}

output "policy_arns" {
  value = module.iam.policy_arns
}

output "instance_profile_arns" {
  value = module.iam.instance_profile_arns
}
