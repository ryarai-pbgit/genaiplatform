# EKS Cluster (Autoモード) - モジュールを使用
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.3.1"

  name                   = "${var.project_name}-eks"
  kubernetes_version     = "1.33"
  endpoint_public_access = true

  # VPC設定
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.private[*].id

  # EKS Auto Mode設定
  compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

  # アクセスエントリ（CLIユーザーとマネジメントコンソールユーザー）
  access_entries = var.eks_access_entries

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}