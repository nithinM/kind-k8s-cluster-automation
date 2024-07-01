output "cluster_name" {
  description = "The name of the KinD cluster"
  value       = var.cluster_name
}

output "cluster_ready" {
  value = null_resource.create_kind_cluster.id
}