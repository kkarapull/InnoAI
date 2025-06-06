#!/bin/bash

# This script creates the directory structure and files for the Enhanced DevOps project.
echo "🚀 Starting project setup..."

# --- Create Directory Structure ---
echo "    -> Creating directories..."
mkdir -p task1_terraform/task1a_s3
mkdir -p task1_terraform/task1b_iam
mkdir -p task2_kubernetes

# --- Create README.md ---
echo "    -> Creating README.md..."
cat <<'EOF' > README.md
# Enhanced DevOps Prompt Engineering Results

This repository contains the solutions for the DevOps engineering tasks involving Terraform and Kubernetes, as completed by Gemini.

## 📝 Table of Contents

- [Task 1: Terraform Enhancements](#task-1-terraform-enhancements)
  - [Task 1.A: Secure S3 Bucket Configuration](#task-1a-secure-s3-bucket-configuration)
  - [Task 1.B: IAM Role Policy Patch](#task-1b-iam-role-policy-patch)
- [Task 2: Kubernetes Production Readiness](#task-2-kubernetes-production-readiness)
  - [Optimized Manifest](#optimized-manifest)
  - [Prompts for AI Assistants](#prompts-for-ai-assistants)

---

## Task 1: Terraform Enhancements

This section contains Terraform code for configuring AWS resources.

### Task 1.A: Secure S3 Bucket Configuration

The `task1_terraform/task1a_s3/main.tf` file configures two S3 buckets:
1.  **A primary bucket** with versioning, server-side encryption (SSE-S3), and blocked public access.
2.  **A logging bucket** to store access logs for the primary bucket.

Both buckets are tagged with a `cost_center`.

**Validation:**
Running `terraform plan` in this directory will show two `aws_s3_bucket` resources to be created with all the specified settings. `terraform validate` will pass without errors.

### Task 1.B: IAM Role Policy Patch

The `task1_terraform/task1b_iam/eks.tf` file contains a patched `aws_iam_role` resource.

**Fixes:**
1.  The `assume_role_policy` is corrected to allow principals from both `eks.amazonaws.com` and `ec2.amazonaws.com`, which is required for EKS managed node groups.
2.  An `aws_iam_role_policy` is attached to grant the role permissions to create CloudWatch log groups, a common requirement for EKS clusters.

---

## Task 2: Kubernetes Production Readiness

This section addresses the task of hardening a Kubernetes manifest for production use.

### Optimized Manifest

The `task2_kubernetes/optimized-manifest.yaml` file is the result of a thorough review. It fixes critical security, reliability, and performance issues found in the original manifest.

**Key Improvements:**
- **Secrets Management**: Hardcoded secrets are removed and replaced with references to a Kubernetes `Secret` object.
- **High Availability**: The replica count is increased, and a `PodDisruptionBudget` is added to prevent downtime during voluntary disruptions.
- **Security Context**: The container is configured to run as a non-root user with minimal privileges.
- **Probes**: A `livenessProbe` is added to ensure the application is automatically restarted if it becomes unresponsive.
- **Image Tagging**: The `:latest` tag is replaced with a specific version (`1.2.3`) to ensure deterministic deployments.
- **Networking**: The Service type is changed from `LoadBalancer` to `ClusterIP`, and an `Ingress` resource is added for controlled external access.

### Prompts for AI Assistants

The `task2_kubernetes/prompts.md` file provides example prompts that can be used with AI assistants like Gemini or Cursor to achieve the optimizations.
EOF

# --- Create Terraform S3 File ---
echo "    -> Creating task1_terraform/task1a_s3/main.tf..."
cat <<'EOF' > task1_terraform/task1a_s3/main.tf
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
EOF

# --- Create Terraform IAM File ---
echo "    -> Creating task1_terraform/task1b_iam/eks.tf..."
cat <<'EOF' > task1_terraform/task1b_iam/eks.tf
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
EOF

# --- Create Kubernetes Optimized Manifest ---
echo "    -> Creating task2_kubernetes/optimized-manifest.yaml..."
cat <<'EOF' > task2_kubernetes/optimized-manifest.yaml
# 1. SECRET MANAGEMENT
# Create this secret object first to store sensitive data.
# Apply it with `kubectl apply -f secret.yaml`
# ---
# apiVersion: v1
# kind: Secret
# metadata:
#   name: payment-service-secrets
#   namespace: production
# type: Opaque
# data:
#   DB_PASSWORD: "ZGItcGFzc3dvcmQtMTIzLWNoYW5nZWQ=" # Base64 encoded password
#   API_KEY: "c2tfdGVzdF9hYmNkZWZnaGlqa2xtbm9wcXJzdHV2d3h5ejEyMzQ1Ng==" # Base64 encoded API key
---
# 2. HIGH AVAILABILITY: PodDisruptionBudget
# Ensures that a minimum number of pods are running during voluntary disruptions.
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: payment-service-pdb
  namespace: production
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: payment-service
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: payment-service
  namespace: production
spec:
  # 3. RELIABILITY: Increased replica count for high availability.
  replicas: 2
  selector:
    matchLabels:
      app: payment-service
  template:
    metadata:
      labels:
        app: payment-service
    spec:
      # 4. SECURITY: Use a dedicated service account
      serviceAccountName: payment-service-sa
      containers:
      - name: payment-api
        # 5. BEST PRACTICE: Use a specific, immutable image tag instead of 'latest'.
        image: company/payment-service:1.2.3
        ports:
        - containerPort: 8080
        env:
        # 6. SECURITY: Reference secrets from a Secret object, do not hardcode them.
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: payment-service-secrets
              key: DB_PASSWORD
        - name: API_KEY
          valueFrom:
            secretKeyRef:
              name: payment-service-secrets
              key: API_KEY
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
        # 7. SECURITY: Apply security context to run as a non-root user and drop privileges.
        securityContext:
          allowPrivilegeEscalation: false
          runAsNonRoot: true
          runAsUser: 10001
          capabilities:
            drop:
              - "ALL"
        # 8. RELIABILITY: Add a liveness probe to restart the container if it's unhealthy.
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 15
          periodSeconds: 20
        readinessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
---
# 9. BEST PRACTICE: Use ClusterIP for internal services and expose via Ingress.
# This prevents direct exposure to the internet.
apiVersion: v1
kind: Service
metadata:
  name: payment-service
  namespace: production
spec:
  selector:
    app: payment-service
  ports:
  - port: 80
    targetPort: 8080
  type: ClusterIP
---
# 10. NETWORKING: Add an Ingress to manage external access to the service.
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: payment-service-ingress
  namespace: production
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - http:
      paths:
      - path: /payments
        pathType: Prefix
        backend:
          service:
            name: payment-service
            port:
              number: 80
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: payment-service-hpa
  namespace: production
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: payment-service
  # 11. RELIABILITY: Set minReplicas to match the deployment's desired state for availability.
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 80
EOF

# --- Create Prompts Markdown File ---
echo "    -> Creating task2_kubernetes/prompts.md..."
cat <<'EOF' > task2_kubernetes/prompts.md
# Prompts for Optimizing Kubernetes Manifests

Here are prompts designed for AI assistants like Gemini and interactive tools like Cursor to improve Kubernetes configurations.

---

### **Prompt for Gemini (or other chat-based AIs)**

**Goal:** Get a complete, production-ready manifest with explanations.

**Prompt:**

"You are a Senior DevOps Engineer specializing in Kubernetes security and reliability. I have a Kubernetes manifest for a critical payment microservice that needs to be deployed to production. Your task is to analyze and rewrite this manifest to make it production-ready.

Please address the following issues:
1.  **Security**: Remove hardcoded secrets, apply a strict security context to run as a non-root user, and prevent privilege escalation.
2.  **Reliability**: Ensure high availability by setting an appropriate replica count, adding a liveness probe, and including a PodDisruptionBudget.
3.  **Best Practices**: Replace the `:latest` image tag with a specific version, use a `ClusterIP` service, and add an `Ingress` resource for controlled external access.

Please provide the final, fully-corrected YAML, including all necessary resources (`Secret`, `Deployment`, `Service`, `HPA`, `PDB`, `Ingress`). Add comments in the YAML to explain each change you made."

**[Paste the original Kubernetes YAML here]**

---

### **Interactive Prompts for Cursor**

**Goal:** Use Cursor's context-aware features to fix the manifest step-by-step.

1.  **Open the `.yaml` file in Cursor.**

2.  **Handling Secrets:**
    * Highlight the `env` block in the `Deployment`.
    * Press `Cmd+K` (or `Ctrl+K`) and ask:
        > "How should I properly handle these sensitive values in Kubernetes? Show me the code for creating a Secret and how to reference it here."

3.  **Applying Security Context:**
    * Highlight the empty `securityContext: {}` block.
    * Press `Cmd+K` and ask:
        > "What security context settings should I apply here for best security practices? The container should run as a non-root user and have minimal privileges."

4.  **Improving Reliability:**
    * Highlight the entire `Deployment` resource.
    * Press `Cmd+K` and ask:
        > "This deployment has `replicas: 1`. How can I make it highly available? Also, it's missing a probe to detect if the application has crashed. Please add what's missing."

5.  **Adding Missing Resources:**
    * With the cursor in a blank area of the file, press `Cmd+K` and ask:
        > "What additional Kubernetes resources should I add to make this deployment truly production-ready? I'm thinking about things like preventing downtime during node maintenance and managing external traffic."
        *Follow-up*: "Great, please generate the YAML for a `PodDisruptionBudget` and an `Ingress` resource for this service."

6.  **Fixing the Service Type:**
    * Highlight the `Service` manifest.
    * Press `Cmd+K` and ask:
        > "Is `type: LoadBalancer` a good idea for this service? If not, what should I change it to and why?"
EOF

echo "✅ Project setup complete. All files have been created."