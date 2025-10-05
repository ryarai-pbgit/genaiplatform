# Redis (ElastiCache) Configuration
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project_name}-redis-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name        = "${var.project_name}-redis-subnet-group"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_security_group" "redis" {
  name_prefix = "${var.project_name}-redis-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-redis-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Redis Parameter Group for Langfuse
resource "aws_elasticache_parameter_group" "main" {
  family = "redis7"
  name   = "${var.project_name}-redis-params"
  
  parameter {
    name  = "maxmemory-policy"
    value = "noeviction"
  }
}

# Single Node Redis Instance (開発用)
resource "aws_elasticache_cluster" "main" {
  cluster_id           = "${var.project_name}-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = aws_elasticache_parameter_group.main.name
  port                 = 6379
  
  # サブネットグループ
  subnet_group_name    = aws_elasticache_subnet_group.main.name
  
  # セキュリティグループ
  security_group_ids   = [aws_security_group.redis.id]
  
  # スナップショット設定（開発用なので最小限）
  snapshot_retention_limit = 1
  snapshot_window         = "03:00-05:00"
  maintenance_window      = "sun:05:00-sun:07:00"
  
  # 暗号化設定（開発用なので無効）
  # Single Nodeでは暗号化設定は不要

  tags = {
    Name        = "${var.project_name}-redis"
    Environment = var.environment
    Project     = var.project_name
  }
}

