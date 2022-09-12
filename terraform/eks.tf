data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "java-cluster"
  cluster_version = "1.23"
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id
  # kubeconfig_output_path = "~/.kube/"

  eks_managed_node_groups = {
    dep-node-group = {
      desired_capacity = 1
      max_capacity     = 2
      min_capacity     = 1
      instanace_type   = "t2.micro"
    }
  }
}

resource "null_resource" "java" {
  depends_on = [module.eks]
  provisioner "local-exec" {
    command = " aws eks update-kubeconfig --name java-cluster --region us-east-1"
    environment = {
      AWS_CLUSTER_NAME = "java-cluster"
    }
  }
}
