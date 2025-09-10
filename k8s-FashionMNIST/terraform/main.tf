
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_container_cluster" "primary" {
  name               = var.cluster_name
  location           = var.zone
  initial_node_count = 1  
  # remove_default_node_pool = true # Remove the default node pool

  network_policy {
    enabled = false
  }

  # We can enable other features as needed, e.g., logging, monitoring
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  # Enable Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}

resource "google_container_node_pool" "gpu_node_pool" {
  name       = "gpu-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    machine_type = "g2-standard-8" # Recommended machine type for L4 GPUs
    disk_size_gb = 100
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    guest_accelerator {
      type  = "nvidia-l4"
      count = 1
    }

    # Ensure GPU drivers are automatically installed
    metadata = {
      disable-legacy-endpoints = "true"
      "nvidia-driver-version"  = "latest" # Or a specific version like "535.104.05"
    }

    # Add a taint to ensure only GPU-requiring pods schedule here
    taint {
      key    = "nvidia.com/gpu"
      value  = "present"
      effect = "NO_SCHEDULE"
    }
  }
  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

