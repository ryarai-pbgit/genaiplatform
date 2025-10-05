# S3 Bucket for Langfuse exports
resource "aws_s3_bucket" "langfuse" {
  bucket = "${var.project_name}-langfuse-${random_string.bucket_suffix.result}"

  tags = {
    Name        = "${var.project_name}-langfuse"
    Environment = var.environment
  }
}

# Random string for bucket suffix
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "langfuse" {
  bucket = aws_s3_bucket.langfuse.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Server Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "langfuse" {
  bucket = aws_s3_bucket.langfuse.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "langfuse" {
  bucket = aws_s3_bucket.langfuse.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket for ClickHouse storage
resource "aws_s3_bucket" "clickhouse" {
  bucket = "${var.project_name}-clickhouse-${random_string.bucket_suffix.result}"

  tags = {
    Name        = "${var.project_name}-clickhouse"
    Environment = var.environment
    Purpose     = "ClickHouse storage"
  }
}

# S3 Bucket Versioning for ClickHouse - DISABLED
# ClickHouseはマージ処理で多くのファイルを書き込み・更新するため、
# バージョニングを有効にするとストレージ消費量が急速に増加する
resource "aws_s3_bucket_versioning" "clickhouse" {
  bucket = aws_s3_bucket.clickhouse.id
  versioning_configuration {
    status = "Suspended"  # バージョニングを無効化
  }
}

# S3 Bucket Server Side Encryption for ClickHouse
resource "aws_s3_bucket_server_side_encryption_configuration" "clickhouse" {
  bucket = aws_s3_bucket.clickhouse.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Public Access Block for ClickHouse
resource "aws_s3_bucket_public_access_block" "clickhouse" {
  bucket = aws_s3_bucket.clickhouse.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Lifecycle Configuration for ClickHouse
resource "aws_s3_bucket_lifecycle_configuration" "clickhouse" {
  bucket = aws_s3_bucket.clickhouse.id

  rule {
    id     = "clickhouse_lifecycle"
    status = "Enabled"

    # 不完全なマルチパートアップロードの削除（7日後）
    # ClickHouseがアップロードを試行したが、完了前に中断した場合のクリーンアップ
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    # 注意: 削除ライフサイクルポリシーは有効にしない
    # ClickHouseの内部整合性モデルを破壊する可能性があるため
    # 代わりにLangfuseアプリケーションまたはClickHouse TTLを使用
  }
}

# S3 Bucket CORS Configuration for ClickHouse
resource "aws_s3_bucket_cors_configuration" "clickhouse" {
  bucket = aws_s3_bucket.clickhouse.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# S3 Bucket Logging Configuration for ClickHouse
resource "aws_s3_bucket_logging" "clickhouse" {
  bucket = aws_s3_bucket.clickhouse.id

  target_bucket = aws_s3_bucket.clickhouse.id
  target_prefix = "logs/"
}

# IAM resources moved to langfuse-iam.tf
