/**
 * Copyright 2021 Google LLC
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

locals {
  zipfile = "inactivated_miner.tar.gz"
  binary  = "inactivated_miner"
}


module "project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 11.0"

  name              = var.project_name
  random_project_id = "true"
  org_id            = var.org_id
  folder_id         = var.folder_id
  billing_account   = var.billing_account

  activate_apis = [
    "iam.googleapis.com",
    "compute.googleapis.com",
    "dns.googleapis.com",
    "storage.googleapis.com"
  ]
}

data "google_compute_image" "image" {
  family  = var.source_image_family
  project = var.source_image_project
}

data "template_file" "startup_script_config" {
  template = file("${path.module}/files/startup.sh")
  vars = {
    BUCKET = google_storage_bucket.miner_bucket.url
    BINARY = local.binary
  }
}

resource "random_id" "random_suffix" {
  byte_length = 4
}

resource "google_service_account" "main" {
  project      = module.project.project_id
  account_id   = "${var.environment}-${random_id.random_suffix.hex}"
  display_name = "${var.environment}${random_id.random_suffix.hex}"
}

resource "google_compute_network" "vpc_network" {
  project                 = module.project.project_id
  name                    = "${var.environment}-${random_id.random_suffix.hex}"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "subnet" {
  project                  = module.project.project_id
  name                     = "${var.environment}-${random_id.random_suffix.hex}"
  ip_cidr_range            = "10.2.0.0/16"
  region                   = var.region
  private_ip_google_access = true
  network                  = google_compute_network.vpc_network.name

}

resource "google_compute_firewall" "egress" {
  project            = module.project.project_id
  name               = "deny-all-egress"
  description        = "Block all egress ${var.environment}"
  network            = google_compute_network.vpc_network.name
  priority           = 1000
  direction          = "EGRESS"
  destination_ranges = ["0.0.0.0/0"]
  deny {
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "ingress" {
  project       = module.project.project_id
  name          = "deny-all-ingress"
  description   = "Block all Ingress ${var.environment}"
  network       = google_compute_network.vpc_network.name
  priority      = 1000
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  deny {
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "googleapi_egress" {
  project            = module.project.project_id
  name               = "allow-googleapi-egress"
  description        = "Allow connectivity to storage ${var.environment}"
  network            = google_compute_network.vpc_network.name
  priority           = 999
  direction          = "EGRESS"
  destination_ranges = ["199.36.153.8/30"]
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}

resource "google_dns_managed_zone" "private" {
  project     = module.project.project_id
  name        = "${var.environment}-${random_id.random_suffix.hex}"
  dns_name    = "storage.googleapis.com."
  description = "Private DNS zone for storage api"
  visibility  = "private"
  private_visibility_config {
    networks {
      network_url = google_compute_network.vpc_network.id
    }
  }
}

resource "google_dns_record_set" "default" {
  project      = module.project.project_id
  managed_zone = google_dns_managed_zone.private.name
  name         = "storage.googleapis.com."
  type         = "A"
  rrdatas      = ["199.36.153.8", "199.36.153.9", "199.36.153.10", "199.36.153.11"]
  ttl          = 86400

  depends_on = [
    google_dns_managed_zone.private
  ]
}

resource "google_storage_bucket" "miner_bucket" {
  project                     = module.project.project_id
  name                        = "${module.project.project_id}-${random_id.random_suffix.hex}"
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_binding" "customers" {
  bucket = google_storage_bucket.miner_bucket.name
  role   = "roles/storage.admin"
  members = [
    "serviceAccount:${google_service_account.main.email}"
  ]
}

resource "null_resource" "download_miner" {
  provisioner "local-exec" {
    command = <<EOF
    cd /tmp
    git clone "https://github.com/GoogleCloudPlatform/security-response-automation.git"
    cd security-response-automation
    tar -zxvf ${local.zipfile}
    gsutil cp ${local.binary} ${google_storage_bucket.miner_bucket.url}
    EOF
  }
  depends_on = [google_storage_bucket.miner_bucket]
}

resource "google_compute_instance" "default" {
  project        = module.project.project_id
  zone           = var.zone
  name           = "${var.environment}-${random_id.random_suffix.hex}"
  machine_type   = var.machine_type
  labels         = var.labels
  tags           = [var.environment]
  can_ip_forward = var.can_ip_forward

  service_account {
    email  = google_service_account.main.email
    scopes = ["cloud-platform"]
  }

  boot_disk {
    initialize_params {
      image = data.google_compute_image.image.self_link
      size  = var.disk_size_gb
      type  = var.disk_type
    }
  }

  metadata_startup_script = data.template_file.startup_script_config.rendered

  network_interface {
    network            = google_compute_network.vpc_network.name
    subnetwork         = google_compute_subnetwork.subnet.name
    subnetwork_project = module.project.project_id
  }

  lifecycle {
    create_before_destroy = "false"
  }
  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = true
    enable_vtpm                 = true
  }
  depends_on = [null_resource.download_miner]
}

