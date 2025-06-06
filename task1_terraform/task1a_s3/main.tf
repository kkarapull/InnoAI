terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "cost_center" {
  description = "The cost center to tag resources with."
  type        = string
  default     = "ACME-DEVOPS-01"
}

resource "random_id" "suffix" {
  byte_length = 3
}

# Logging bucket where access logs will be stored
resource "aws_s3_bucket" "logging_bucket" {
  bucket = "acme-logs-storage-${random_id.suffix.hex}"

  tags = {
    cost_center = var.cost_center
  }
}

# Block public access for the logging bucket
resource "aws_s3_bucket_public_access_block" "logging_bucket_access" {
  bucket = aws_s3_bucket.logging_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# Primary bucket for raw logs with enhanced security and features
resource "aws_s3_bucket" "raw_logs" {
  bucket = "acme-raw-logs-${random_id.suffix.hex}"

  tags = {
    cost_center = var.cost_center
  }
}

# Enable versioning for the raw_logs bucket
resource "aws_s3_bucket_versioning" "raw_logs_versioning" {
  bucket = aws_s3_bucket.raw_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption for the raw_logs bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "raw_logs_sse" {
  bucket = aws_s3_bucket.raw_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Enable access logging for the raw_logs bucket
resource "aws_s3_bucket_logging" "raw_logs_logging" {
  bucket = aws_s3_bucket.raw_logs.id

  target_bucket = aws_s3_bucket.logging_bucket.id
  target_prefix = "log/"
}

# Block all public access for the raw_logs bucket
resource "aws_s3_bucket_public_access_block" "raw_logs_access" {
  bucket = aws_s3_bucket.raw_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
