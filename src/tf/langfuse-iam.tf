# Langfuse用IAMロールとポリシー

# OIDCプロバイダーの情報を取得
data "aws_eks_cluster" "main" {
  name = module.eks.cluster_name

  depends_on = [module.eks]
}

# Langfuse用のIAMロール
resource "aws_iam_role" "langfuse" {
  name = "${var.project_name}-langfuse-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(data.aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:genai-platform:langfuse"
            "${replace(data.aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-langfuse-role"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Langfuse用S3アクセスポリシー
resource "aws_iam_policy" "langfuse_s3" {
  name        = "${var.project_name}-langfuse-s3-policy"
  description = "S3 access policy for Langfuse"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:ListBucket",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Effect = "Allow"
        Resource = [
          "${aws_s3_bucket.langfuse.arn}/*",
          aws_s3_bucket.langfuse.arn
        ]
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-langfuse-s3-policy"
    Environment = var.environment
    Project     = var.project_name
  }
}


# Langfuse用RDSアクセスポリシー
resource "aws_iam_policy" "langfuse_rds" {
  name        = "${var.project_name}-langfuse-rds-policy"
  description = "RDS access policy for Langfuse"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "rds-db:connect"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:rds-db:${var.aws_region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_rds_cluster.main.cluster_identifier}/postgres"
        ]
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-langfuse-rds-policy"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Langfuse用Secrets Managerアクセスポリシー
resource "aws_iam_policy" "langfuse_secrets" {
  name        = "${var.project_name}-langfuse-secrets-policy"
  description = "Secrets Manager access policy for Langfuse"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${var.project_name}-*"
        ]
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-langfuse-secrets-policy"
    Environment = var.environment
    Project     = var.project_name
  }
}

# ポリシーをロールにアタッチ
resource "aws_iam_role_policy_attachment" "langfuse_s3" {
  role       = aws_iam_role.langfuse.name
  policy_arn = aws_iam_policy.langfuse_s3.arn
}

resource "aws_iam_role_policy_attachment" "langfuse_secrets" {
  role       = aws_iam_role.langfuse.name
  policy_arn = aws_iam_policy.langfuse_secrets.arn
}

resource "aws_iam_role_policy_attachment" "langfuse_rds" {
  role       = aws_iam_role.langfuse.name
  policy_arn = aws_iam_policy.langfuse_rds.arn
}

# IAM Policy for ClickHouse S3 access
resource "aws_iam_policy" "clickhouse_s3" {
  name        = "${var.project_name}-clickhouse-s3-policy"
  description = "S3 access policy for ClickHouse"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.clickhouse.arn,
          "${aws_s3_bucket.clickhouse.arn}/*"
        ]
      }
    ]
  })

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# ClickHouse用のIAMロール
resource "aws_iam_role" "langfuse_clickhouse" {
  name = "${var.project_name}-langfuse-clickhouse-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(data.aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:genai-platform:langfuse-clickhouse"
            "${replace(data.aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# ClickHouse用ポリシーをロールにアタッチ
resource "aws_iam_role_policy_attachment" "clickhouse_s3" {
  role       = aws_iam_role.langfuse_clickhouse.name
  policy_arn = aws_iam_policy.clickhouse_s3.arn
}

# 現在のAWSアカウントIDを取得
data "aws_caller_identity" "current" {}
