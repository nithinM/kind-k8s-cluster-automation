output "cluster_name" {
  description = "The name of the KinD cluster"
  value       = var.cluster_name
}

output "cluster_status" {
  description = "Status of the KinD cluster creation"
  value       = "KinD cluster ${var.cluster_name} created with ${var.control_plane_count} control-plane nodes and ${var.worker_count} worker nodes."
}
