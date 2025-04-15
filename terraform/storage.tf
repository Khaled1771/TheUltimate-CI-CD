# S3 Bucket for Artifacts
resource "aws_s3_bucket" "artifacts" {
  bucket = var.artifacts_bucket_name  

  tags = {
    Name        = var.artifacts_bucket_name  
    Environment = var.environment
    Project     = var.project_name
  }
}

# Enable versioning for artifacts
resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access to the artifacts bucket
resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket policy to allow access from CI/CD tools
resource "aws_s3_bucket_policy" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            aws_iam_role.jenkins.arn,
            aws_iam_role.sonarqube.arn,
            aws_iam_role.nexus.arn
          ]
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.artifacts.arn,
          "${aws_s3_bucket.artifacts.arn}/*"
        ]
      }
    ]
  })
}

# S3 Bucket for Cache
resource "aws_s3_bucket" "cache" {
  bucket = "${var.project_name}-cache-${var.environment}"
  
  tags = {
    Name        = "${var.project_name}-cache-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_s3_bucket_versioning" "cache" {
  bucket = aws_s3_bucket.cache.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cache" {
  bucket = aws_s3_bucket.cache.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "cache" {
  bucket = aws_s3_bucket.cache.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket policy for cache bucket
resource "aws_s3_bucket_policy" "cache" {
  bucket = aws_s3_bucket.cache.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            aws_iam_role.jenkins.arn,
            aws_iam_role.sonarqube.arn,
            aws_iam_role.nexus.arn
          ]
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.cache.arn,
          "${aws_s3_bucket.cache.arn}/*"
        ]
      }
    ]
  })
}

# Output the bucket names for reference in other modules
output "artifacts_bucket_name" {
  description = "Name of the artifacts S3 bucket"
  value       = aws_s3_bucket.artifacts.id
}

output "cache_bucket_name" {
  description = "Name of the cache S3 bucket"
  value       = aws_s3_bucket.cache.id
}