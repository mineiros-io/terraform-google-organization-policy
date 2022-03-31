[<img src="https://raw.githubusercontent.com/mineiros-io/brand/3bffd30e8bdbbde32c143e2650b2faa55f1df3ea/mineiros-primary-logo.svg" width="400"/>](https://mineiros.io/?ref=terraform-google-organization-policy)

[![Build Status](https://github.com/mineiros-io/terraform-google-organization-policy/workflows/Tests/badge.svg)](https://github.com/mineiros-io/terraform-google-organization-policy/actions)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/mineiros-io/terraform-google-organization-policy.svg?label=latest&sort=semver)](https://github.com/mineiros-io/terraform-google-organization-policy/releases)
[![Terraform Version](https://img.shields.io/badge/Terraform-1.x-623CE4.svg?logo=terraform)](https://github.com/hashicorp/terraform/releases)
[![Google Provider Version](https://img.shields.io/badge/google-4-1A73E8.svg?logo=terraform)](https://github.com/terraform-providers/terraform-provider-google/releases)
[![Join Slack](https://img.shields.io/badge/slack-@mineiros--community-f32752.svg?logo=slack)](https://mineiros.io/slack)

# terraform-google-organization-policy

A [Terraform](https://www.terraform.io) module to create [Google Organization Policies](https://cloud.google.com/resource-manager/docs/organization-policy/overview) on [Google Cloud Services (GCP)](https://cloud.google.com/).

**_This module supports Terraform version 1
and is compatible with the Terraform Google Provider version 4._**

This module is part of our Infrastructure as Code (IaC) framework
that enables our users and customers to easily deploy and manage reusable,
secure, and production-grade cloud infrastructure.


- [Module Features](#module-features)
- [Getting Started](#getting-started)
- [Module Argument Reference](#module-argument-reference)
  - [Main Resource Configuration](#main-resource-configuration)
  - [Module Configuration](#module-configuration)
- [Module Outputs](#module-outputs)
- [External Documentation](#external-documentation)
  - [AWS Documentation IAM](#aws-documentation-iam)
  - [Terraform AWS Provider Documentation](#terraform-aws-provider-documentation)
- [Module Versioning](#module-versioning)
  - [Backwards compatibility in `0.0.z` and `0.y.z` version](#backwards-compatibility-in-00z-and-0yz-version)
- [About Mineiros](#about-mineiros)
- [Reporting Issues](#reporting-issues)
- [Contributing](#contributing)
- [Makefile Targets](#makefile-targets)
- [License](#license)

## Module Features

This module implements the following Terraform resources

- `google_org_policy_policy`

## Getting Started

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

## Module Argument Reference

See [variables.tf] and [examples/] for details and use-cases.

### Main Resource Configuration

- [**`name`**](#var-name): *(**Required** `string`)*<a name="var-name"></a>

  The resource name of the Policy.

  Must be one of the following forms, where constraint_name is the name of the constraint which this Policy configures:
  - projects/{project_number}/policies/{constraint_name}
  - folders/{folder_id}/policies/{constraint_name}
  - organizations/{organization_id}/policies/{constraint_name}

  For example, "projects/123/policies/compute.disableSerialPortAccess".

  **Note**: projects/{project_id}/policies/{constraint_name} is also an acceptable name for API requests, but responses will return the name using the equivalent project number.

- [**`parent`**](#var-parent): *(**Required** `string`)*<a name="var-parent"></a>

  The parent of the resource.

- [**`spec`**](#var-spec): *(Optional `object(policy_spec)`)*<a name="var-spec"></a>

  Basic information about the Organization Policy.

  The `policy_spec` object accepts the following attributes:

  - [**`inherit_from_parent`**](#attr-spec-inherit_from_parent): *(Optional `bool`)*<a name="attr-spec-inherit_from_parent"></a>

    Determines the inheritance behavior for this Policy.

    If `inherit_from_parent` is true, `PolicyRules` set higher up in the hierarchy (up to the closest root) are inherited and present in the effective policy.

    If it is false, then no rules are inherited, and this Policy becomes the new root for evaluation.

    This field can be set only for Policies which configure list constraints.

  - [**`reset`**](#attr-spec-reset): *(Optional `bool`)*<a name="attr-spec-reset"></a>

    Ignores policies set above this resource and restores the `constraint_default` enforcement behavior of the specific Constraint at this resource.

    This field can be set in policies for either list or boolean constraints. If set, rules must be empty and `inherit_from_parent` must be set to false.

  - [**`rules`**](#attr-spec-rules): *(Optional `list(policy_rule)`)*<a name="attr-spec-rules"></a>

    Up to 10 PolicyRules are allowed.
    In Policies for boolean constraints, the following requirements apply:
    - There must be one and only one PolicyRule where condition is unset.
    - BooleanPolicyRules with conditions must set `enforced` to the opposite of the PolicyRule without a condition.
    - During policy evaluation, PolicyRules with conditions that are true for a target resource take precedence.

    Each `policy_rule` object in the list accepts the following attributes:

    - [**`allow_all`**](#attr-spec-rules-allow_all): *(Optional `bool`)*<a name="attr-spec-rules-allow_all"></a>

      Setting this to true means that all values are allowed. This field can be set only in `Policies` for list constraints.

    - [**`deny_all`**](#attr-spec-rules-deny_all): *(Optional `bool`)*<a name="attr-spec-rules-deny_all"></a>

      Setting this to true means that all values are denied. This field can be set only in Policies for list constraints.

    - [**`enforce`**](#attr-spec-rules-enforce): *(Optional `bool`)*<a name="attr-spec-rules-enforce"></a>

      If `true`, then the `Policy` is enforced. If `false`, then any configuration is acceptable.

      This field can be set only in Policies for boolean constraints.

    - [**`condition`**](#attr-spec-rules-condition): *(Optional `object(condition)`)*<a name="attr-spec-rules-condition"></a>

      A condition which determines whether this rule is used in the evaluation of the policy.

      When set, the `expression` field in the `Expr' must include from 1 to 10 subexpressions, joined by the "||" or "&&" operators.

      Each subexpression must be of the form `"resource.matchTag('/tag_key_short_name, 'tag_value_short_name')"`. or `"resource.matchTagId('tagKeys/key_id', 'tagValues/value_id')"`. where key_name and value_name are the resource names for Label Keys and Values. These names are available from the Tag Manager Service.

      An example expression is: `"resource.matchTag('123456789/environment, 'prod')"`. or `"resource.matchTagId('tagKeys/123', 'tagValues/456')"`.

      The `condition` object accepts the following attributes:

      - [**`description`**](#attr-spec-rules-condition-description): *(Optional `string`)*<a name="attr-spec-rules-condition-description"></a>

        Description of the expression. This is a longer text which describes the expression, e.g. when hovered over it in a UI.

      - [**`expression`**](#attr-spec-rules-condition-expression): *(Optional `string`)*<a name="attr-spec-rules-condition-expression"></a>

        Textual representation of an expression in Common Expression Language syntax.

      - [**`location`**](#attr-spec-rules-condition-location): *(Optional `string`)*<a name="attr-spec-rules-condition-location"></a>

        String indicating the location of the expression for error reporting, e.g. a file name and a position in the file.

      - [**`title`**](#attr-spec-rules-condition-title): *(Optional `string`)*<a name="attr-spec-rules-condition-title"></a>

        Title for the expression, i.e. a short string describing its purpose. This can be used e.g. in UIs which allow to enter the expression.

    - [**`values`**](#attr-spec-rules-values): *(Optional `object(values)`)*<a name="attr-spec-rules-values"></a>

      The `values` object accepts the following attributes:

      - [**`allowed_values`**](#attr-spec-rules-values-allowed_values): *(Optional `set(string)`)*<a name="attr-spec-rules-values-allowed_values"></a>

        List of values allowed at this resource.

      - [**`denied_values`**](#attr-spec-rules-values-denied_values): *(Optional `set(string)`)*<a name="attr-spec-rules-values-denied_values"></a>

        List of values denied at this resource.

### Module Configuration

- [**`module_enabled`**](#var-module_enabled): *(Optional `bool`)*<a name="var-module_enabled"></a>

  Specifies whether resources in the module will be created.

  Default is `true`.

- [**`module_timeouts`**](#var-module_timeouts): *(Optional `map(timeout)`)*<a name="var-module_timeouts"></a>

  A map of timeout objects that is keyed by Terraform resource name
  defining timeouts for `create`, `update` and `delete` Terraform operations.

  Supported resources are: `google_org_policy_policy`.

  Example:

  ```hcl
  module_timeouts = {
    google_org_policy_policy = {
      create = "20m"
      update = "20m"
      delete = "20m"
    }
  }
  ```

  Each `timeout` object in the map accepts the following attributes:

  - [**`create`**](#attr-module_timeouts-create): *(Optional `string`)*<a name="attr-module_timeouts-create"></a>

    Timeout for create operations.

  - [**`update`**](#attr-module_timeouts-update): *(Optional `string`)*<a name="attr-module_timeouts-update"></a>

    Timeout for update operations.

  - [**`delete`**](#attr-module_timeouts-delete): *(Optional `string`)*<a name="attr-module_timeouts-delete"></a>

    Timeout for delete operations.

- [**`module_depends_on`**](#var-module_depends_on): *(Optional `list(dependency)`)*<a name="var-module_depends_on"></a>

  A list of dependencies.
  Any object can be _assigned_ to this list to define a hidden external dependency.

  Default is `[]`.

  Example:

  ```hcl
  module_depends_on = [
    null_resource.name
  ]
  ```

## Module Outputs

The following attributes are exported in the outputs of the module:

- [**`policy`**](#output-policy): *(`resource(google_org_policy_policy)`)*<a name="output-policy"></a>

  All outputs of the created 'google_org_policy_policy' resource.

- [**`module_enabled`**](#output-module_enabled): *(`bool`)*<a name="output-module_enabled"></a>

  Whether this module is enabled.

## External Documentation

### AWS Documentation IAM

- https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html
- https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies.html
- https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2_instance-profiles.html

### Terraform AWS Provider Documentation

- https://www.terraform.io/docs/providers/aws/r/iam_role.html
- https://www.terraform.io/docs/providers/aws/r/iam_role_policy.html
- https://www.terraform.io/docs/providers/aws/r/iam_role_policy_attachment.html
- https://www.terraform.io/docs/providers/aws/r/iam_instance_profile.html

## Module Versioning

This Module follows the principles of [Semantic Versioning (SemVer)].

Given a version number `MAJOR.MINOR.PATCH`, we increment the:

1. `MAJOR` version when we make incompatible changes,
2. `MINOR` version when we add functionality in a backwards compatible manner, and
3. `PATCH` version when we make backwards compatible bug fixes.

### Backwards compatibility in `0.0.z` and `0.y.z` version

- Backwards compatibility in versions `0.0.z` is **not guaranteed** when `z` is increased. (Initial development)
- Backwards compatibility in versions `0.y.z` is **not guaranteed** when `y` is increased. (Pre-release)

## About Mineiros

[Mineiros][homepage] is a remote-first company headquartered in Berlin, Germany
that solves development, automation and security challenges in cloud infrastructure.

Our vision is to massively reduce time and overhead for teams to manage and
deploy production-grade and secure cloud infrastructure.

We offer commercial support for all of our modules and encourage you to reach out
if you have any questions or need help. Feel free to email us at [hello@mineiros.io] or join our
[Community Slack channel][slack].

## Reporting Issues

We use GitHub [Issues] to track community reported issues and missing features.

## Contributing

Contributions are always encouraged and welcome! For the process of accepting changes, we use
[Pull Requests]. If you'd like more information, please see our [Contribution Guidelines].

## Makefile Targets

This repository comes with a handy [Makefile].
Run `make help` to see details on each available target.

## License

[![license][badge-license]][apache20]

This module is licensed under the Apache License Version 2.0, January 2004.
Please see [LICENSE] for full details.

Copyright &copy; 2020-2022 [Mineiros GmbH][homepage]


<!-- References -->

[homepage]: https://mineiros.io/?ref=terraform-google-organization-policy
[hello@mineiros.io]: mailto:hello@mineiros.io
[badge-license]: https://img.shields.io/badge/license-Apache%202.0-brightgreen.svg
[releases-terraform]: https://github.com/hashicorp/terraform/releases
[releases-aws-provider]: https://github.com/terraform-providers/terraform-provider-aws/releases
[apache20]: https://opensource.org/licenses/Apache-2.0
[slack]: https://mineiros.io/slack
[terraform]: https://www.terraform.io
[aws]: https://aws.amazon.com/
[semantic versioning (semver)]: https://semver.org/
[variables.tf]: https://github.com/mineiros-io/terraform-google-organization-policy/blob/main/variables.tf
[examples/]: https://github.com/mineiros-io/terraform-google-organization-policy/blob/main/examples
[issues]: https://github.com/mineiros-io/terraform-google-organization-policy/issues
[license]: https://github.com/mineiros-io/terraform-google-organization-policy/blob/main/LICENSE
[makefile]: https://github.com/mineiros-io/terraform-google-organization-policy/blob/main/Makefile
[pull requests]: https://github.com/mineiros-io/terraform-google-organization-policy/pulls
[contribution guidelines]: https://github.com/mineiros-io/terraform-google-organization-policy/blob/main/CONTRIBUTING.md
