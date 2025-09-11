variable "project_id" {
  description = "The GCP project ID where the resources will be created."
  type        = string
}

variable "region" {
  description = "The GCP region for the bucket."
  type        = string
  default     = "us-west1"
}

variable "bucket_name_prefix" {
  description = "The name of the GCS bucket."
  type        = string
}

variable "k8s_namespace" {
  description = "The Kubernetes namespace where the service account exists for Workload Identity."
  type        = string
  default = "default"
}

variable "k8s_service_account_name" {
  description = "The name of the Kubernetes service account that needs access to the bucket via Workload Identity."
  type        = string
  default = "training"
}