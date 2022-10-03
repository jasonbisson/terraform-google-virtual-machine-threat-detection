# terraform-google-virtual-machine-threat-detection

This module will deploy an isolated project that will deploy a Google Compute instance that will execute a inactive crptominer binary to demostrate the capability of Virtual Machine Threat Detection to detect the memory footprint of a cryptominer.


The resources/services/activations/deletions that this module will create/trigger are:

- Create a Google Cloud project
- Download the inactive crypto miner from https://github.com/GoogleCloudPlatform/security-response-automation
- Copy the inactive crypto miner to a Storage Bucket
- Create a VPC with firewall rules blocking both Ingres and Egress except to subnet for private.googleapis.com
- Create Private DNS Zone for private googleapis and DNS record for storag.googleapis.com
- Create a GCE instance with startup script to launch the inactive cryptominer and shutdown instance in 60 minutes.


## Usage

Basic usage of this module is as follows:

```hcl
module "virtual_machine_threat_detection" {
  source  = "jasonbisson/virtual-machine-threat-detection/"
  version = "~> 0.1"

  org_id          = var.org_id
  billing_account = var.billing_account
  folder_id       = var.folder_id
  environment     = var.environment
  project_name    = var.project_name

}
```

Functional examples are included in the
[examples](./examples/) directory.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| billing\_account | The billing account id associated with the project, e.g. XXXXXX-YYYYYY-ZZZZZZ | `string` | n/a | yes |
| can\_ip\_forward | Enable IP forwarding, for NAT instances for example | `string` | `"false"` | no |
| disk\_size\_gb | Boot disk size in GB | `string` | `"100"` | no |
| disk\_type | Boot disk type, can be either pd-ssd, local-ssd, or pd-standard | `string` | `"pd-standard"` | no |
| dnszone | The Private DNS zone to resolve private storage api | `string` | `"googleapis.com"` | no |
| environment | Environment tag to help identify the entire deployment | `string` | n/a | yes |
| folder\_id | The folder to deploy project in | `string` | n/a | yes |
| labels | Labels, provided as a map | `map(any)` | `{}` | no |
| machine\_type | Machine type to application | `string` | `"n1-standard-2"` | no |
| org\_id | The numeric organization id | `string` | n/a | yes |
| project\_name | Prefix of Google Project name | `string` | n/a | yes |
| region | The GCP region to create and test resources in | `string` | `"us-central1"` | no |
| source\_image\_family | The OS Image family | `string` | `"debian-11"` | no |
| source\_image\_project | Google Cloud project with OS Image | `string` | `"debian-cloud"` | no |
| zone | The GCP zone to create the instance in | `string` | `"us-central1-a"` | no |

## Outputs

No output.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

These sections describe requirements for using this module.

### Software

The following dependencies must be available:

- [Terraform][terraform] v0.13
- [Terraform Provider for GCP][terraform-provider-gcp] plugin v3.0
- [git command line][https://git-scm.com/downloads] to download repo with inactive miner
- [gsutil][https://cloud.google.com/storage/docs/gsutil] to copy the inactive miner to Storage Bucket
- Security Command Center premium with VMTD enabled on destination folder

### Service Account
A service account with the following roles must be used to provision
the resources of this module:

- Project Creator: `roles/resourcemanager.projectCreator)`
- Compute Admin: `roles/compute.admin`
- Storage Admin: `roles/storage.admin`
- DNS Admin: `roles/dns.admin`

### APIs

The [Project Factory module][project-factory-module] is used to
provision the project with the necessary APIs enabled.

- Google Cloud Identity & Access Management: `iam.googleapis.com`
- Google Cloud Compute Engine: `compute.googleapis.com`
- Google Cloud DNS: `dns.googleapis.com`
- Google Cloud Storage: `storage.googleapis.com`

## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for
information on contributing to this module.

[iam-module]: https://registry.terraform.io/modules/terraform-google-modules/iam/google
[project-factory-module]: https://registry.terraform.io/modules/terraform-google-modules/project-factory/google
[terraform-provider-gcp]: https://www.terraform.io/docs/providers/google/index.html
[terraform]: https://www.terraform.io/downloads.html

## Security Disclosures

Please see our [security disclosure process](./SECURITY.md).

## Troubleshooting 

### Coin Miner alert not triggering after 60 minutes

To enable SSH access using Identity Aware Proxy use the following commands:
- `mv ssh_access.template ssh_access.tf` to rename firewall template to allow ssh access
- `terraform plan` to see firewall update in the infrastructure plan
- `terraform apply` to apply firewall update to infrastructure build
- ssh to only gce instance in project and run `ps -ef |grep inactivated_miner`
