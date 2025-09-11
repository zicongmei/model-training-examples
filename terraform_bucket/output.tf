output "bucket_name" {
  description = "The name of the created or referenced GCP Storage Bucket."
  value       = local.actual_bucket.name
}

output "bucket_self_link" {
  description = "The self_link of the created or referenced GCP Storage Bucket."
  value       = local.actual_bucket.self_link
}

output "bucket_url" {
  description = "The URL of the created or referenced GCP Storage Bucket."
  value       = local.actual_bucket.url
}

output "iam_member_granted_access" {
  description = "The IAM member (Kubernetes Service Account via Workload Identity) granted access to the bucket."
  value       = google_storage_bucket_iam_member.k8s_sa_access.member
}

output "iam_role_granted" {
  description = "The role granted to the IAM member on the bucket."
  value       = google_storage_bucket_iam_member.k8s_sa_access.role
}