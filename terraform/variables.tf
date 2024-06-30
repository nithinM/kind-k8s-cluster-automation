variable "control_plane_count" {
  description = "Number of control plane nodes"
  type        = number
#   default     = 1
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
#   default     = 2
}

variable "cluster_name" {
  description = "Name of the KinD cluster"
  type        = string
#   default     = "kind-cluster"
}

variable "kubernetes_image" {
  description = "The Kubernetes image with SHA256 digest to use for the KinD cluster"
  type        = string
#   default     = "kindest/node:v1.30.0@sha256:047357ac0cfea04663786a612ba1eaba9702bef25227a794b52890dd8bcd692e"
}
