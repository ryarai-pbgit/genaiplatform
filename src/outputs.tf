# EKS Cluster outputs
output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_certificate_authority_data" {
  description = "EKS cluster certificate authority data"
  value       = module.eks.cluster_certificate_authority_data
}


# RDS outputs
output "rds_endpoint" {
  description = "RDS Aurora cluster endpoint"
  value       = aws_rds_cluster.main.endpoint
}

output "rds_port" {
  description = "RDS Aurora cluster port"
  value       = aws_rds_cluster.main.port
}

# S3 outputs
output "s3_bucket_name" {
  description = "S3 bucket name for Langfuse"
  value       = aws_s3_bucket.langfuse.bucket
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN for Langfuse"
  value       = aws_s3_bucket.langfuse.arn
}

# ClickHouse S3 outputs
output "clickhouse_s3_bucket_name" {
  description = "S3 bucket name for ClickHouse"
  value       = aws_s3_bucket.clickhouse.bucket
}

output "clickhouse_s3_bucket_arn" {
  description = "S3 bucket ARN for ClickHouse"
  value       = aws_s3_bucket.clickhouse.arn
}

# Redis outputs
output "redis_endpoint" {
  description = "Redis cluster endpoint"
  value       = aws_elasticache_cluster.main.cache_nodes[0].address
}

output "redis_port" {
  description = "Redis cluster port"
  value       = aws_elasticache_cluster.main.port
}

# Langfuse IAM outputs
output "langfuse_role_arn" {
  description = "Langfuse IAM role ARN"
  value       = aws_iam_role.langfuse.arn
}

output "langfuse_role_name" {
  description = "Langfuse IAM role name"
  value       = aws_iam_role.langfuse.name
}

# VPC outputs
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}
