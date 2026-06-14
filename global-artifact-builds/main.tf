terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  project = "retribution-x-499314"
  region  = "europe-west3"
}

# Enable project APIs
resource "google_project_service" "global_apis" {
  for_each = toset([
    "container.googleapis.com",
    "artifactregistry.googleapis.com",
    "iamcredentials.googleapis.com"
  ])
  project            = "retribution-x-499314"
  service            = each.key
  disable_on_destroy = false
}

# The Centralized Registry lives here safely away from the GKE cluster files
resource "google_artifact_registry_repository" "registry" {
  depends_on    = [google_project_service.global_apis]
  location      = "europe-west3"
  repository_id = "retribution-shared-registry"
  description   = "Centralized immutable repository for retribution_x artifacts"
  format        = "DOCKER"
}