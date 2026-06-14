terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    # 1. Added the Kubernetes provider plugin requirement
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.31"
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

# ==============================================================================
# NEW ADDITIONS BELOW: Logging into the GKE Cluster and building the Namespace
# ==============================================================================

# 2. Tell Terraform how to securely authenticate with your GKE Cluster endpoint
provider "kubernetes" {
  host                   = "https://${google_container_cluster.dev_cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.dev_cluster.master_auth[0].cluster_ca_certificate)
}

# Data block to fetch your active gcloud terminal access token dynamically
data "google_client_config" "default" {}

# 3. Declare the explicit, isolated namespace boundary inside GKE
resource "kubernetes_namespace" "app_space" {
  metadata {
    name = "retribution-platform-dev"
    labels = {
      managed-by = "terraform"
      env        = "dev"
    }
  }
}