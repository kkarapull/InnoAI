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
