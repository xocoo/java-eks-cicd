resource "kubernetes_config_map" "aws-auth" {
  data = {
    "mapRoles" = <<EOT
    - rolearn: arn:aws:iam::261039457655:role/NodeInstanceRole
      username: system:node:{{EC2PrivateDNSName}}
      groups:
      - system:bootstrappers
      - system:nodes      
    - rolearn: arn:aws:sts::261039457655:assumed-role/codebuild-eks-role/AWSCodeBuild-8a4c022c-7d15-4ed9-b6c8-25d8b0240754
      username: codebuild-eks-role
      groups:
        - system:masters
    EOT
  }

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
}
