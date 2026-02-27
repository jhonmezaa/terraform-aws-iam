provider "aws" {
  region = "us-east-1"
}

module "iam" {
  source = "../../iam"

  account_name = "prod"
  project_name = "platform"

  # ---------------------------------------------------------------------------
  # IAM Roles
  # ---------------------------------------------------------------------------
  roles = {
    # Service role for Lambda
    lambda-execution = {
      description      = "Lambda execution role for platform services"
      trusted_services = ["lambda.amazonaws.com"]
      managed_policy_arns = [
        "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
        "arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess"
      ]
      inline_policies = {
        sqs-access = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = [
                "sqs:SendMessage",
                "sqs:ReceiveMessage",
                "sqs:DeleteMessage"
              ]
              Resource = "arn:aws:sqs:us-east-1:123456789012:platform-queue"
            }
          ]
        })
      }
    }

    # EC2 instance role with instance profile
    ec2-app-server = {
      description             = "EC2 instance role for application servers"
      trusted_services        = ["ec2.amazonaws.com"]
      create_instance_profile = true
      managed_policy_arns = [
        "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
        "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
      ]
    }

    # Cross-account access role
    cross-account-deploy = {
      description          = "Allow CI/CD from tools account to deploy"
      trusted_role_arns    = ["arn:aws:iam::111111111111:root"]
      max_session_duration = 7200
      managed_policy_arns = [
        "arn:aws:iam::aws:policy/PowerUserAccess"
      ]
    }

    # GitHub Actions OIDC role
    github-actions = {
      description = "GitHub Actions deployment role"
      trusted_oidc_providers = [
        {
          provider_arn = "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
          conditions = [
            {
              test     = "StringEquals"
              variable = "token.actions.githubusercontent.com:aud"
              values   = ["sts.amazonaws.com"]
            },
            {
              test     = "StringLike"
              variable = "token.actions.githubusercontent.com:sub"
              values   = ["repo:myorg/myrepo:*"]
            }
          ]
        }
      ]
      managed_policy_arns = [
        "arn:aws:iam::aws:policy/AdministratorAccess"
      ]
    }

    # ECS task execution role
    ecs-task-execution = {
      description      = "ECS task execution role"
      trusted_services = ["ecs-tasks.amazonaws.com"]
      managed_policy_arns = [
        "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
      ]
    }
  }

  # ---------------------------------------------------------------------------
  # IAM Policies
  # ---------------------------------------------------------------------------
  policies = {
    s3-full-access = {
      description = "Full access to platform S3 buckets"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = ["s3:*"]
            Resource = [
              "arn:aws:s3:::prod-platform-*",
              "arn:aws:s3:::prod-platform-*/*"
            ]
          }
        ]
      })
    }

    secrets-read = {
      description = "Read access to Secrets Manager for platform secrets"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "secretsmanager:GetSecretValue",
              "secretsmanager:DescribeSecret"
            ]
            Resource = "arn:aws:secretsmanager:us-east-1:123456789012:secret:prod/platform/*"
          }
        ]
      })
    }

    deny-region = {
      description = "Deny all actions outside allowed regions"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect   = "Deny"
            Action   = "*"
            Resource = "*"
            Condition = {
              StringNotEquals = {
                "aws:RequestedRegion" = ["us-east-1", "us-west-2"]
              }
            }
          }
        ]
      })
    }
  }

  # ---------------------------------------------------------------------------
  # IAM Users
  # ---------------------------------------------------------------------------
  users = {
    ci-deployer = {
      name              = "ci-deployer"
      create_access_key = true
      managed_policy_arns = [
        "arn:aws:iam::aws:policy/PowerUserAccess"
      ]
      tags = {
        Purpose = "CI/CD deployment"
      }
    }

    monitoring-reader = {
      name = "monitoring-reader"
      managed_policy_arns = [
        "arn:aws:iam::aws:policy/ReadOnlyAccess"
      ]
      groups = ["readonly-group"]
    }
  }

  # ---------------------------------------------------------------------------
  # IAM Groups
  # ---------------------------------------------------------------------------
  groups = {
    administrators = {
      managed_policy_arns = [
        "arn:aws:iam::aws:policy/AdministratorAccess"
      ]
    }

    developers = {
      managed_policy_arns = [
        "arn:aws:iam::aws:policy/PowerUserAccess"
      ]
    }

    readonly = {
      managed_policy_arns = [
        "arn:aws:iam::aws:policy/ReadOnlyAccess"
      ]
    }
  }

  # ---------------------------------------------------------------------------
  # OIDC Providers
  # ---------------------------------------------------------------------------
  oidc_providers = {
    github = {
      url             = "https://token.actions.githubusercontent.com"
      client_id_list  = ["sts.amazonaws.com"]
      thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
    }
  }

  # ---------------------------------------------------------------------------
  # Account Settings
  # ---------------------------------------------------------------------------
  account_settings = {
    account_alias = "mycompany-prod"
    password_policy = {
      minimum_password_length        = 16
      require_lowercase_characters   = true
      require_uppercase_characters   = true
      require_numbers                = true
      require_symbols                = true
      allow_users_to_change_password = true
      max_password_age               = 90
      password_reuse_prevention      = 24
      hard_expiry                    = false
    }
  }

  tags = {
    Environment = "prod"
    Team        = "platform"
    ManagedBy   = "Terraform"
  }
}

# =============================================================================
# Outputs
# =============================================================================

output "role_arns" {
  value = module.iam.role_arns
}

output "role_names" {
  value = module.iam.role_names
}

output "policy_arns" {
  value = module.iam.policy_arns
}

output "user_arns" {
  value = module.iam.user_arns
}

output "group_arns" {
  value = module.iam.group_arns
}

output "group_names" {
  value = module.iam.group_names
}

output "instance_profile_arns" {
  value = module.iam.instance_profile_arns
}

output "oidc_provider_arns" {
  value = module.iam.oidc_provider_arns
}
