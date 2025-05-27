resource "aws_iam_user" "eks_user" {
  name = var.iam_user_name
}

resource "aws_iam_user_policy" "eks_user_policy" {
  name = "eks-access-policy"
  user = aws_iam_user.eks_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:AccessKubernetesApi"
        ]
        Resource = "*"
      }
    ]
  })
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"
  subnet_ids      = var.subnet_ids
  vpc_id          = var.vpc_id

  eks_managed_node_groups = {
    default = {
      min_size       = var.node_min_size
      max_size       = var.node_max_size
      desired_size   = var.node_desired_size
      instance_types = var.node_instance_types
      disk_size      = var.node_disk_size
    }
  }

  create_aws_auth_configmap = true

  aws_auth_users = [
    {
      userarn  = aws_iam_user.eks_user.arn
      username = "eks-admin"
      groups   = ["system:masters"]
    }
  ]

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
