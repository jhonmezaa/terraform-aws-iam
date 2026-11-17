# terraform-aws-iam

Terraform module for managing AWS IAM resources including roles, policies, users, groups, OIDC providers, instance profiles, and account-level settings.

## Features

- **IAM Roles**: Service roles, cross-account roles, OIDC-federated roles (GitHub Actions, EKS IRSA), with managed and inline policy attachments
- **IAM Policies**: Custom managed policies with full control over name, description, path, and policy document
- **IAM Users**: Users with optional login profiles, access keys, group memberships, and policy attachments
- **IAM Groups**: Groups with managed and inline policy attachments, plus user membership management
- **Instance Profiles**: Automatically created alongside IAM roles when enabled
- **OIDC Providers**: GitHub Actions, EKS, and custom OIDC provider registration
- **Account Settings**: Password policy enforcement and account alias management
- **Unified Naming**: Consistent `{region_prefix}-iam-{type}-{account_name}-{project_name}-{key}` naming convention

## Usage

### Basic - Lambda and EC2 Roles

```hcl
module "iam" {
  source = "github.com/jhonmezaa/terraform-aws-iam//iam?ref=v1.2.0"

  account_name = "dev"
  project_name = "myapp"

  roles = {
    lambda-execution = {
      description      = "Lambda execution role"
      trusted_services = ["lambda.amazonaws.com"]
      managed_policy_arns = [
        "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
      ]
    }

    ec2-instance = {
      description             = "EC2 instance role"
      trusted_services        = ["ec2.amazonaws.com"]
      create_instance_profile = true
      managed_policy_arns = [
        "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      ]
    }
  }

  tags_common = {
    Environment = "dev"
  }
}
```

### GitHub Actions OIDC Role

```hcl
module "iam" {
  source = "github.com/jhonmezaa/terraform-aws-iam//iam?ref=v1.2.0"

  account_name = "prod"
  project_name = "platform"

  oidc_providers = {
    github = {
      url             = "https://token.actions.githubusercontent.com"
      client_id_list  = ["sts.amazonaws.com"]
      thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
    }
  }

  roles = {
    github-deploy = {
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
  }
}
```

### Cross-Account Role

```hcl
module "iam" {
  source = "github.com/jhonmezaa/terraform-aws-iam//iam?ref=v1.2.0"

  account_name = "prod"
  project_name = "shared"

  roles = {
    cross-account-deploy = {
      description          = "Allow CI/CD from tools account"
      trusted_role_arns    = ["arn:aws:iam::111111111111:root"]
      max_session_duration = 7200
      trust_policy_conditions = [
        {
          test     = "StringEquals"
          variable = "sts:ExternalId"
          values   = ["my-external-id"]
        }
      ]
      managed_policy_arns = [
        "arn:aws:iam::aws:policy/PowerUserAccess"
      ]
    }
  }
}
```

### Users and Groups

```hcl
module "iam" {
  source = "github.com/jhonmezaa/terraform-aws-iam//iam?ref=v1.2.0"

  account_name = "prod"
  project_name = "platform"

  groups = {
    administrators = {
      managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    }
    developers = {
      managed_policy_arns = ["arn:aws:iam::aws:policy/PowerUserAccess"]
    }
  }

  users = {
    ci-deployer = {
      name              = "ci-deployer"
      create_access_key = true
      managed_policy_arns = [
        "arn:aws:iam::aws:policy/PowerUserAccess"
      ]
      # Reference groups created by this module by key
      group_keys = ["developers"]
    }
  }
}
```

> **Note:** `groups[*].user_names` uses `aws_iam_group_membership`, which is _exclusive_ for the group.
> Do not combine it with `users[*].groups` / `users[*].group_keys` for the same group, or Terraform will
> show a perpetual diff. Pick one membership style per group.

### Account Password Policy

```hcl
module "iam" {
  source = "github.com/jhonmezaa/terraform-aws-iam//iam?ref=v1.2.0"

  account_name = "prod"
  project_name = "security"

  account_settings = {
    account_alias = "mycompany-prod"
    password_policy = {
      minimum_password_length      = 16
      require_uppercase_characters = true
      require_lowercase_characters = true
      require_numbers              = true
      require_symbols              = true
      max_password_age             = 90
      password_reuse_prevention    = 24
    }
  }
}
```

## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | >= 1.3  |
| aws       | >= 6.0  |

## Inputs

| Name              | Description                      | Type          | Default                |
| ----------------- | -------------------------------- | ------------- | ---------------------- |
| create            | Whether to create IAM resources  | `bool`        | `true`                 |
| account_name      | Account name for resource naming | `string`      | required               |
| project_name      | Project name for resource naming | `string`      | required               |
| region_prefix     | Region prefix override           | `string`      | `null` (auto-detected) |
| use_region_prefix | Include region prefix in names   | `bool`        | `true`                 |
| tags_common       | Common tags for all resources    | `map(string)` | `{}`                   |
| tags              | Legacy alias of `tags_common` (merged on top of it) | `map(string)` | `{}` |
| roles             | Map of IAM roles to create       | `map(object)` | `{}`                   |
| policies          | Map of IAM policies to create    | `map(object)` | `{}`                   |
| users             | Map of IAM users to create       | `map(object)` | `{}`                   |
| groups            | Map of IAM groups to create      | `map(object)` | `{}`                   |
| oidc_providers    | Map of OIDC providers to create  | `map(object)` | `{}`                   |
| account_settings  | Account-level IAM settings       | `object`      | `null`                 |

## Outputs

| Name                    | Description                                 |
| ----------------------- | ------------------------------------------- |
| roles                   | Map of role details (ARN, name, unique_id)  |
| role_arns               | Map of role ARNs                            |
| role_names              | Map of role names                           |
| instance_profiles       | Map of instance profile details             |
| instance_profile_arns   | Map of instance profile ARNs                |
| policies                | Map of policy details (ARN, name, id)       |
| policy_arns             | Map of policy ARNs                          |
| users                   | Map of user details (ARN, name, unique_id)  |
| user_arns               | Map of user ARNs                            |
| user_login_profiles     | Map of encrypted login profile details      |
| user_access_keys        | Map of access key details                   |
| user_access_key_ids     | Map of access key IDs                       |
| user_access_key_secrets | Map of access key secrets (sensitive)       |
| groups                  | Map of group details (ARN, name, unique_id) |
| group_arns              | Map of group ARNs                           |
| group_names             | Map of group names                          |
| oidc_providers          | Map of OIDC provider details                |
| oidc_provider_arns      | Map of OIDC provider ARNs                   |
| policy_names            | Map of policy names                         |
| user_names              | Map of user names                           |
| user_login_profile_passwords | Map of plaintext login passwords (sensitive, only without `pgp_key`) |
| user_access_key_ses_smtp_passwords_v4 | Map of SES SMTP passwords (sensitive, only without `pgp_key`) |
| user_ssh_keys           | Map of SSH key details (id, fingerprint, status) |
| account_alias           | Account alias (if managed)                  |
| account_password_policy_expire_passwords | Whether account passwords expire |

### Notable object attributes

- `roles[*]`: `name`, `description`, `path`, `max_session_duration` (3600-43200), `force_detach_policies`,
  `permissions_boundary`, `assume_role_policy` (raw JSON, takes precedence), `trusted_services`,
  `trusted_role_arns`, `trusted_oidc_providers` (`provider_arn`, optional `conditions`),
  `trust_policy_conditions` (added to every generated trust statement, e.g. `sts:ExternalId`),
  `trust_policy_extra_actions` (e.g. `sts:TagSession`), `managed_policy_arns`, `inline_policies`,
  `create_instance_profile`, `tags`. Each role must define `assume_role_policy` or at least one trusted principal.
- `users[*]`: `name`, `path`, `permissions_boundary`, `force_destroy`, `create_login_profile`, `pgp_key`,
  `password_length`, `password_reset_required`, `create_access_key`, `access_key_status`,
  `ssh_public_key`, `ssh_key_encoding` (`SSH`/`PEM`), `ssh_key_status`, `managed_policy_arns`,
  `inline_policies`, `groups` (literal group names), `group_keys` (keys of `groups`), `tags`.

## Naming Convention

Resources follow the pattern: `{region_prefix}-iam-{type}-{account_name}-{project_name}-{key}`

Examples:

- Role: `ause1-iam-role-prod-myapp-lambda-execution`
- Policy: `ause1-iam-policy-prod-myapp-s3-read`
- Group: `ause1-iam-group-prod-myapp-developers`

Generated names are truncated to the AWS limits (64 characters for roles/instance profiles, 128 for
policies and groups). Any resource can be named explicitly with `name`. IAM users are named after
their key (or `name`), since they usually represent real identities. All taggable resources get
`merge(tags_common, tags, <resource tags>, { Name, ManagedBy = "Terraform" })`; IAM groups do not
support tags.

## License

MIT License - see [LICENSE](LICENSE) for details.
