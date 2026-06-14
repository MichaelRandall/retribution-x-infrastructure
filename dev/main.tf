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

# The Cluster stands on its own feet
resource "google_container_cluster" "dev_cluster" {
  name             = "retribution-dev-cluster"
  location         = "europe-west3"
  enable_autopilot = true
  
  deletion_protection = false
}