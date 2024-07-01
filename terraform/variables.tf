variable "control_plane_count" {
  description = "Number of control plane nodes"
  type        = number
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
}

variable "cluster_name" {
  description = "Name of the KinD cluster"
  type        = string
}

variable "kubernetes_image" {
  description = "The Kubernetes image with SHA256 digest to use for the KinD cluster"
  type        = string
}
