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
