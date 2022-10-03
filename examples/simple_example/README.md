# Simple Example

This example illustrates how to use the `virtual-machine-threat-detection` module.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| billing\_account | The billing account id associated with the project, e.g. XXXXXX-YYYYYY-ZZZZZZ | `string` | n/a | yes |
| environment | Environment tag to help identify the entire deployment | `string` | `"vmtd"` | no |
| folder\_id | The folder to deploy project in | `string` | n/a | yes |
| org\_id | The numeric organization id | `string` | n/a | yes |
| project\_name | Prefix of Google Project name | `string` | `"vmtd"` | no |

## Outputs

No output.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

To provision this example, run the following from within this directory:
- `terraform init` to get the plugins
- `terraform plan` to see the infrastructure plan
- `terraform apply` to apply the infrastructure build
- `terraform destroy` to destroy the built infrastructure
