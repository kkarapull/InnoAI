# This file demonstrates the fix for the IAM Role.
# Note: A real EKS setup would require more resources.

provider "aws" {
  region = "us-east-1"
}

# Patched IAM Role for the EKS Cluster
resource "aws_iam_role" "eks_cluster" {
  name = "acme-eks-cluster-2025"

  # GOAL 1: Patched the policy to allow both eks.amazonaws.com and ec2.amazonaws.com
  # The "Service" principal can now be a list of services.
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Sid    = "EKSClusterRole",
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
      # Added this statement for EC2, required by managed node groups.
      # A better approach for multiple services is to list them.
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Sid    = "EC2NodeGroupRole",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# GOAL 2: Added an inline policy to allow creating CloudWatch log groups.
# It is better to create a separate policy resource than using `inline_policy`.
resource "aws_iam_role_policy" "eks_cloudwatch_logs" {
  name = "EKSCloudWatchLogCreation"
  role = aws_iam_role.eks_cluster.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}
