locals {
  kind_config = <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
EOF

  control_planes = [
    for i in range(var.control_plane_count) : <<-EOF
  - role: control-plane
    image: ${var.kubernetes_image}
    kubeadmConfigPatches:
    - |
      kind: InitConfiguration
      nodeRegistration:
        kubeletExtraArgs:
          node-labels: "ingress-ready=true"
    extraPortMappings:
    - containerPort: 80
      hostPort: ${80 + i}
      protocol: TCP
EOF
  ]

  workers = [
    for i in range(var.worker_count) : <<-EOF
  - role: worker
    image: ${var.kubernetes_image}
EOF
  ]

  full_kind_config = join("\n", concat([local.kind_config], local.control_planes, local.workers, [""]))
}

resource "local_file" "kind_config" {
  content  = local.full_kind_config
  filename = "${path.module}/kind-config.yaml"
}

resource "null_resource" "create_kind_cluster" {
  triggers = {
    cluster_name = var.cluster_name
  }

  provisioner "local-exec" {
    command = <<EOT
      kind create cluster --config ${local_file.kind_config.filename} --name ${self.triggers.cluster_name}
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kind delete cluster --name ${self.triggers.cluster_name}"
  }
}
