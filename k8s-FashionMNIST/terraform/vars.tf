variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "region" {
  description = "The GCP region for the cluster."
  type        = string
  default     = "us-west1"
}

variable "zone" {
  description = "The GCP zone for the cluster."
  type        = string
  default     = "us-west1-a"
}

variable "cluster_name" {
  description = "The name of the GKE cluster."
  type        = string
  default     = "gpu-cluster"
}


