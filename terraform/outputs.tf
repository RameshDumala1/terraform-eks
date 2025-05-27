output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "kubeconfig" {
  value = <<EOT
Run the following command to configure your kubeconfig:

aws eks --region ${var.aws_region} update-kubeconfig --name ${module.eks.cluster_name}
EOT
}
