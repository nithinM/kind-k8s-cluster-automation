module "cluster" {
  source = "./modules/cluster"

  control_plane_count = var.control_plane_count
  worker_count        = var.worker_count
  cluster_name        = var.cluster_name
  kubernetes_image    = var.kubernetes_image
}
