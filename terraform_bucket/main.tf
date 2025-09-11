# Configure the Google Cloud provider
provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  desired_bucket_name = "${var.bucket_name_prefix}-${var.region}"
  # Use a data source that lists all buckets in the project to check for existence
  # without causing a Terraform error if the specific bucket is not found.
  bucket_names_in_project = [for bucket in data.google_storage_buckets.all_project_buckets.buckets : bucket.name]
  bucket_exists           = contains(local.bucket_names_in_project, local.desired_bucket_name)
}

# Data source to list all buckets in the project to determine if the desired bucket exists.
data "google_storage_buckets" "all_project_buckets" {
  project = var.project_id
}

# Resource: GCP Storage Bucket
# This resource will create the bucket IF it does not already exist.
# If a bucket with the same name exists, this resource will not be created (count = 0).
resource "google_storage_bucket" "example_bucket" {
  count = local.bucket_exists ? 0 : 1 # Create only if the bucket does NOT exist

  name                        = local.desired_bucket_name
  location                    = var.region
  project                     = var.project_id
  uniform_bucket_level_access = true # Enable Uniform bucket-level access

  lifecycle {
    prevent_destroy = true # Protect against accidental deletion of the bucket
  }
}

# Data source to get details of an existing bucket IF it exists.
# This is needed if the bucket already exists and `example_bucket` resource has `count = 0`,
# so we can still reference its attributes (e.g., name, self_link).
data "google_storage_bucket" "existing_bucket_details" {
  count = local.bucket_exists ? 1 : 0 # Fetch details only if the bucket DOES exist

  name = local.desired_bucket_name
}

# Local to abstract which bucket reference to use.
# It will either be the newly created bucket (if it didn't exist)
# or the details of the existing bucket (if it did exist).
locals {
  actual_bucket = local.bucket_exists ? data.google_storage_bucket.existing_bucket_details[0] : google_storage_bucket.example_bucket[0]
}

# IAM rule for the Kubernetes Service Account to read and write the bucket
# This assumes Workload Identity is configured for the GKE cluster,
# allowing the Kubernetes service account to impersonate a GCP Service Account.
# The `member` string format `serviceAccount:PROJECT_ID.svc.id.goog[NAMESPACE/KSA_NAME]`
# is required for Workload Identity.
resource "google_storage_bucket_iam_member" "k8s_sa_access" {
  bucket = local.actual_bucket.name # Reference the abstract bucket (either created or existing)
  role   = "roles/storage.objectAdmin" # Provides read, write, and delete object access within the bucket

  member = "serviceAccount:${var.project_id}.svc.id.goog[${var.k8s_namespace}/${var.k8s_service_account_name}]"
}