/**
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
variable "org_id" {
  description = "The numeric organization id"
  type        = string
}

variable "folder_id" {
  description = "The folder to deploy project in"
  type        = string
}

variable "billing_account" {
  description = "The billing account id associated with the project, e.g. XXXXXX-YYYYYY-ZZZZZZ"
  type        = string
}

variable "project_name" {
  description = "Prefix of Google Project name"
  type        = string
}

variable "environment" {
  description = "Environment tag to help identify the entire deployment"
  type        = string
}

variable "region" {
  description = "The GCP region to create and test resources in"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone to create the instance in"
  type        = string
  default     = "us-central1-a"
}

variable "dnszone" {
  description = "The Private DNS zone to resolve private storage api"
  type        = string
  default     = "googleapis.com"
}

variable "machine_type" {
  description = "Machine type to application"
  type        = string
  default     = "n1-standard-1"
}

variable "disk_size_gb" {
  description = "Boot disk size in GB"
  default     = "100"
}

variable "disk_type" {
  description = "Boot disk type, can be either pd-ssd, local-ssd, or pd-standard"
  default     = "pd-standard"
}

variable "can_ip_forward" {
  description = "Enable IP forwarding, for NAT instances for example"
  type        = string
  default     = "false"
}

variable "labels" {
  type        = map(any)
  description = "Labels, provided as a map"
  default     = {}
}

variable "source_image_family" {
  description = "The OS Image family"
  type        = string
  default     = "debian-11"
}

variable "source_image_project" {
  description = "Google Cloud project with OS Image"
  type        = string
  default     = "debian-cloud"
}
