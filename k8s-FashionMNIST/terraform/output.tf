
output "cluster_name" {
  description = "The name of the GKE cluster."
  value       = google_container_cluster.primary.name
}

output "node_pool_name" {
  description = "The name of the GPU node pool."
  value       = google_container_node_pool.gpu_node_pool.name
}

output "connect_k8s" {
  value = "gcloud container clusters get-credentials ${var.cluster_name} --zone ${var.zone}"
}
