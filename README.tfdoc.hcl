header {
  image = "https://raw.githubusercontent.com/mineiros-io/brand/3bffd30e8bdbbde32c143e2650b2faa55f1df3ea/mineiros-primary-logo.svg"
  url   = "https://mineiros.io/?ref=terraform-google-organization-policy"

  badge "build" {
    image = "https://github.com/mineiros-io/terraform-google-organization-policy/workflows/Tests/badge.svg"
    url   = "https://github.com/mineiros-io/terraform-google-organization-policy/actions"
    text  = "Build Status"
  }

  badge "semver" {
    image = "https://img.shields.io/github/v/tag/mineiros-io/terraform-google-organization-policy.svg?label=latest&sort=semver"
    url   = "https://github.com/mineiros-io/terraform-google-organization-policy/releases"
    text  = "GitHub tag (latest SemVer)"
  }

  badge "terraform" {
    image = "https://img.shields.io/badge/Terraform-1.x-623CE4.svg?logo=terraform"
    url   = "https://github.com/hashicorp/terraform/releases"
    text  = "Terraform Version"
  }

  badge "tf-gcp-provider" {
    image = "https://img.shields.io/badge/google-4-1A73E8.svg?logo=terraform"
    url   = "https://github.com/terraform-providers/terraform-provider-google/releases"
    text  = "Google Provider Version"
  }

  badge "slack" {
    image = "https://img.shields.io/badge/slack-@mineiros--community-f32752.svg?logo=slack"
    url   = "https://mineiros.io/slack"
    text  = "Join Slack"
  }
}

section {
  title   = "terraform-google-organization-policy"
  toc     = true
  content = <<-END
    A [Terraform](https://www.terraform.io) module to create [Google Organization Policies](https://cloud.google.com/resource-manager/docs/organization-policy/overview) on [Google Cloud Services (GCP)](https://cloud.google.com/).

    **_This module supports Terraform version 1
    and is compatible with the Terraform Google Provider version 4._**

    This module is part of our Infrastructure as Code (IaC) framework
    that enables our users and customers to easily deploy and manage reusable,
    secure, and production-grade cloud infrastructure.
  END

  section {
    title   = "Module Features"
    content = <<-END
      This module implements the following Terraform resources

      - `google_org_policy_policy`
    END
  }

  section {
    title   = "Getting Started"
    content = <<-END
      Most common usage of the module:

      ```hcl
        module "terraform-module-template" {
          source = "git@github.com:mineiros-io/terraform-module-template.git?ref=v0.0.1"

          name   = "projects/test-project/policies/iam.disableServiceAccountKeyUpload"
          parent = "projects/test-project"

          spec = {
            rules = {
              condition = {
                description = "A sample condition for the policy"
                expression  = "resource.matchLabels('labelKeys/123', 'labelValues/345')"
                location    = "sample-location.log"
                title       = "sample-condition"
              }
              values = {
                allowed_values = ["projects/allowed-project"]
                denied_values  = ["projects/denied-project"]
              }
            }

            rules = {
              allow_all = true
            }
          }
        }
      ```
    END
  }

  section {
    title   = "Module Argument Reference"
    content = <<-END
      See [variables.tf] and [examples/] for details and use-cases.
    END

    section {
      title = "Main Resource Configuration"

      variable "name" {
        required    = true
        type        = string
        description = <<-END
          The resource name of the Policy.

          Must be one of the following forms, where constraint_name is the name of the constraint which this Policy configures:
          - projects/{project_number}/policies/{constraint_name}
          - folders/{folder_id}/policies/{constraint_name}
          - organizations/{organization_id}/policies/{constraint_name}

          For example, "projects/123/policies/compute.disableSerialPortAccess".

          **Note**: projects/{project_id}/policies/{constraint_name} is also an acceptable name for API requests, but responses will return the name using the equivalent project number.
        END
      }

      variable "parent" {
        required    = true
        type        = string
        description = "The parent of the resource."
      }

      variable "spec" {
        type        = object(policy_spec)
        description = "Basic information about the Organization Policy."

        attribute "inherit_from_parent" {
          type        = bool
          description = <<-END
            Determines the inheritance behavior for this Policy.

            If `inherit_from_parent` is true, `PolicyRules` set higher up in the hierarchy (up to the closest root) are inherited and present in the effective policy.

            If it is false, then no rules are inherited, and this Policy becomes the new root for evaluation.

            This field can be set only for Policies which configure list constraints.
          END
        }

        attribute "reset" {
          type        = bool
          description = <<-END
            Ignores policies set above this resource and restores the `constraint_default` enforcement behavior of the specific Constraint at this resource.

            This field can be set in policies for either list or boolean constraints. If set, rules must be empty and `inherit_from_parent` must be set to false.
          END
        }

        attribute "rules" {
          type        = list(policy_rule)
          description = <<-END
            Up to 10 PolicyRules are allowed.
            In Policies for boolean constraints, the following requirements apply:
            - There must be one and only one PolicyRule where condition is unset.
            - BooleanPolicyRules with conditions must set `enforced` to the opposite of the PolicyRule without a condition.
            - During policy evaluation, PolicyRules with conditions that are true for a target resource take precedence.
          END

          attribute "allow_all" {
            type        = bool # TODO: should it be string "TRUE"?
            description = <<-END
              Setting this to true means that all values are allowed. This field can be set only in `Policies` for list constraints.
            END
          }

          attribute "deny_all" {
            type        = bool # TODO: should it be string "FALSE"?
            description = <<-END
              Setting this to true means that all values are denied. This field can be set only in Policies for list constraints.
            END
          }

          attribute "enforce" {
            type        = bool
            description = <<-END
              If `true`, then the `Policy` is enforced. If `false`, then any configuration is acceptable.

              This field can be set only in Policies for boolean constraints.
            END
          }

          attribute "condition" {
            type        = object(condition)
            description = <<-END
              A condition which determines whether this rule is used in the evaluation of the policy.

              When set, the `expression` field in the `Expr' must include from 1 to 10 subexpressions, joined by the "||" or "&&" operators.

              Each subexpression must be of the form `"resource.matchTag('/tag_key_short_name, 'tag_value_short_name')"`. or `"resource.matchTagId('tagKeys/key_id', 'tagValues/value_id')"`. where key_name and value_name are the resource names for Label Keys and Values. These names are available from the Tag Manager Service.

              An example expression is: `"resource.matchTag('123456789/environment, 'prod')"`. or `"resource.matchTagId('tagKeys/123', 'tagValues/456')"`.
            END

            attribute "description" {
              type        = string
              description = <<-END
                 Description of the expression. This is a longer text which describes the expression, e.g. when hovered over it in a UI.
              END
            }

            attribute "expression" {
              type        = string
              description = <<-END
                Textual representation of an expression in Common Expression Language syntax.
              END
            }

            attribute "location" {
              type        = string
              description = <<-END
                String indicating the location of the expression for error reporting, e.g. a file name and a position in the file.
              END
            }

            attribute "title" {
              type        = string
              description = <<-END
                Title for the expression, i.e. a short string describing its purpose. This can be used e.g. in UIs which allow to enter the expression.
              END
            }
          }

          attribute "values" {
            type        = object(values)
            description = <<-END

            END
            attribute "allowed_values" {
              type        = set(string)
              description = <<-END
                List of values allowed at this resource.
              END
            }
            attribute "denied_values" {
              type        = set(string)
              description = <<-END
                List of values denied at this resource.
              END
            }
          }
        }
      }
    }

    section {
      title = "Module Configuration"

      variable "module_enabled" {
        type        = bool
        default     = true
        description = <<-END
          Specifies whether resources in the module will be created.
        END
      }

      variable "module_depends_on" {
        type        = list(dependency)
        description = <<-END
          A list of dependencies.
          Any object can be _assigned_ to this list to define a hidden external dependency.
        END

        default        = []
        readme_example = <<-END
          module_depends_on = [
            null_resource.name
          ]
        END
      }
    }
  }

  section {
    title   = "Module Outputs"
    content = <<-END
      The following attributes are exported in the outputs of the module:
    END

    output "policy" {
      description = "All outputs of the created 'google_org_policy_policy' resource."
      type        = resource(google_org_policy_policy)
    }

    output "module_enabled" {
      type        = bool
      description = <<-END
          Whether this module is enabled.
        END
    }
  }

  section {
    title = "External Documentation"

    section {
      title   = "AWS Documentation IAM"
      content = <<-END
        - https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html
        - https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies.html
        - https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2_instance-profiles.html
      END
    }

    section {
      title   = "Terraform AWS Provider Documentation"
      content = <<-END
        - https://www.terraform.io/docs/providers/aws/r/iam_role.html
        - https://www.terraform.io/docs/providers/aws/r/iam_role_policy.html
        - https://www.terraform.io/docs/providers/aws/r/iam_role_policy_attachment.html
        - https://www.terraform.io/docs/providers/aws/r/iam_instance_profile.html
      END
    }
  }

  section {
    title   = "Module Versioning"
    content = <<-END
      This Module follows the principles of [Semantic Versioning (SemVer)].

      Given a version number `MAJOR.MINOR.PATCH`, we increment the:

      1. `MAJOR` version when we make incompatible changes,
      2. `MINOR` version when we add functionality in a backwards compatible manner, and
      3. `PATCH` version when we make backwards compatible bug fixes.
    END

    section {
      title   = "Backwards compatibility in `0.0.z` and `0.y.z` version"
      content = <<-END
        - Backwards compatibility in versions `0.0.z` is **not guaranteed** when `z` is increased. (Initial development)
        - Backwards compatibility in versions `0.y.z` is **not guaranteed** when `y` is increased. (Pre-release)
      END
    }
  }

  section {
    title   = "About Mineiros"
    content = <<-END
      [Mineiros][homepage] is a remote-first company headquartered in Berlin, Germany
      that solves development, automation and security challenges in cloud infrastructure.

      Our vision is to massively reduce time and overhead for teams to manage and
      deploy production-grade and secure cloud infrastructure.

      We offer commercial support for all of our modules and encourage you to reach out
      if you have any questions or need help. Feel free to email us at [hello@mineiros.io] or join our
      [Community Slack channel][slack].
    END
  }

  section {
    title   = "Reporting Issues"
    content = <<-END
      We use GitHub [Issues] to track community reported issues and missing features.
    END
  }

  section {
    title   = "Contributing"
    content = <<-END
      Contributions are always encouraged and welcome! For the process of accepting changes, we use
      [Pull Requests]. If you'd like more information, please see our [Contribution Guidelines].
    END
  }

  section {
    title   = "Makefile Targets"
    content = <<-END
      This repository comes with a handy [Makefile].
      Run `make help` to see details on each available target.
    END
  }

  section {
    title   = "License"
    content = <<-END
      [![license][badge-license]][apache20]

      This module is licensed under the Apache License Version 2.0, January 2004.
      Please see [LICENSE] for full details.

      Copyright &copy; 2020-2022 [Mineiros GmbH][homepage]
    END
  }
}

references {
  ref "homepage" {
    value = "https://mineiros.io/?ref=terraform-google-organization-policy"
  }
  ref "hello@mineiros.io" {
    value = " mailto:hello@mineiros.io"
  }
  ref "badge-license" {
    value = "https://img.shields.io/badge/license-Apache%202.0-brightgreen.svg"
  }
  ref "releases-terraform" {
    value = "https://github.com/hashicorp/terraform/releases"
  }
  ref "releases-aws-provider" {
    value = "https://github.com/terraform-providers/terraform-provider-aws/releases"
  }
  ref "apache20" {
    value = "https://opensource.org/licenses/Apache-2.0"
  }
  ref "slack" {
    value = "https://mineiros.io/slack"
  }
  ref "terraform" {
    value = "https://www.terraform.io"
  }
  ref "aws" {
    value = "https://aws.amazon.com/"
  }
  ref "semantic versioning (semver)" {
    value = "https://semver.org/"
  }
  ref "variables.tf" {
    value = "https://github.com/mineiros-io/terraform-google-organization-policy/blob/main/variables.tf"
  }
  ref "examples/" {
    value = "https://github.com/mineiros-io/terraform-google-organization-policy/blob/main/examples"
  }
  ref "issues" {
    value = "https://github.com/mineiros-io/terraform-google-organization-policy/issues"
  }
  ref "license" {
    value = "https://github.com/mineiros-io/terraform-google-organization-policy/blob/main/LICENSE"
  }
  ref "makefile" {
    value = "https://github.com/mineiros-io/terraform-google-organization-policy/blob/main/Makefile"
  }
  ref "pull requests" {
    value = "https://github.com/mineiros-io/terraform-google-organization-policy/pulls"
  }
  ref "contribution guidelines" {
    value = "https://github.com/mineiros-io/terraform-google-organization-policy/blob/main/CONTRIBUTING.md"
  }
}
