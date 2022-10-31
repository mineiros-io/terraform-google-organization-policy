resource "google_org_policy_policy" "policy" {
  count = var.module_enabled ? 1 : 0

  name   = var.name
  parent = var.parent

  dynamic "spec" {
    for_each = var.spec != null ? [var.spec] : []

    content {
      dynamic "rules" {
        for_each = try(spec.value.rules, [])

        content {
          allow_all = try(rules.value.allow_all, null)
          deny_all  = try(rules.value.deny_all, null)
          enforce   = try(rules.value.enforce, null)

          dynamic "condition" {
            for_each = try([rules.value.condition], [])

            content {
              description = try(condition.value.description, null)
              expression  = try(condition.value.expression, null)
              location    = try(condition.value.location, null)
              title       = try(condition.value.title, null)
            }
          }

          dynamic "values" {
            for_each = try([rules.value.values], [])

            content {
              allowed_values = try(values.value.allowed_values, null)
              denied_values  = try(values.value.denied_values, null)
            }
          }
        }
      }
    }
  }

  dynamic "timeouts" {
    for_each = try([var.module_timeouts.google_org_policy_policy], [])

    content {
      create = try(timeouts.value.create, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }

  depends_on = [var.module_depends_on]
}
