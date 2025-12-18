GCP Online Boutique – Cloud-Native Migration & DevOps Challenge
==============================================================

Overview
--------

This repository demonstrates the **migration and modernization** of a legacy,
VM-based monolithic SaaS application to **Google Cloud Platform (GCP)** using
**Infrastructure as Code (Terraform)**, **Google Kubernetes Engine (GKE)**, and
**containerized microservices**.

The solution focuses on:

- Automation
- Security (least privilege)
- Scalability
- Operational clarity
- Future-proof design

The implementation intentionally balances **technical depth** with
**operational pragmatism**.

---

Architecture Summary
--------------------

### Core Components

- Custom **VPC** with non-overlapping CIDR ranges
- **GKE (zonal cluster)** for cost-efficient Kubernetes
- **Private cluster networking**
- **Node pools** with least-privileged service accounts
- **Artifact Registry** for container images
- **CI/CD** demonstrated and explained
- **Application deployment & rollout** validated

---

Networking Design
--------------------

| Component | CIDR |
|---------|------|
| Nodes | `10.0.0.0/16` |
| Pods | `10.1.0.0/16` |
| Services | `10.2.0.0/16` |

### Why this design

- Clear separation of concerns
- Prevents IP overlap
- Supports future expansion (multi-cluster, peering)
- Aligns with GKE networking best practices

---

Repository Structure (Best Practice)
--------------------------------------

```text
terraform/
├── main.tf              # Root orchestration
├── variables.tf         # Global variables
├── outputs.tf           # Shared outputs
├── versions.tf          # Provider & Terraform versions
├── backend.tf           # Remote state (GCS)
├── cloudbuild.yaml      # CI pipeline for Cloudbuild
|
├── envs/
│   └── dev/
│       └── terraform.tfvars
│
└── modules/
    ├── network/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    └── gke/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf

### Why this structure is a best practice

- Clear separation of concerns between infrastructure layers
- Reusable Terraform modules (network, GKE)
- Environment isolation without code duplication
- Safe collaboration for multiple infrastructure engineers
- Easy promotion from DEV → UAT → PROD

Terraform **state is shared**, but **configuration is isolated**, preventing
accidental cross-environment impact.

---

## Environment Strategy (DEV / UAT / PROD)

### Current setup
envs/dev/terraform.tfvars

Adding UAT and PROD environments (NOT IMPLEMENTED IN THIS REPO KEEPING THE CHALLANGE IN MIND)

envs/
├── dev/
│   └── terraform.tfvars
├── uat/
│   └── terraform.tfvars
└── prod/
    └── terraform.tfvars

Each environment:

- Uses the same Terraform codebase
- Differs only via variable values:
- Region / zone
- Node size and count
- Autoscaling limits
- Access CIDRs

```

```
EXAMPLE USAGE

terraform apply -var-file=envs/prod/terraform.tfvars

```
This approach ensures:
----------------------

- Predictability
- Auditability
- Zero code duplication
- Safe environment promotion

Security Approach
-----------------

- Private GKE cluster
- No public node IPs
- Least-privileged service accounts
- NAT Gateway for outbound internet access
- Master Authorized Networks for control-plane access
- No secrets committed to Git
- Security was designed by default, not added later.

CI/CD (Demonstrated & Explained)
-------------------------------

What was demonstrated

- Container image build
- Push to Artifact Registry
- Rolling update on GKE
- Zero-downtime deployment
- CI/CD approach (production-ready)
- GitHub → Cloud Build
- Docker builds executed on Linux runners (avoids CPU architecture mismatch)
- Kubernetes rollout via kubectl set image
- CI/CD was intentionally kept simple for clarity while still demonstrating
- the full deployment lifecycle.

Known Issues & Lessons Learned
------------------------------


**Issue**

1. Regional clusters replicate node pools across zones, increasing SSD quota
requirements.

**Resolution**

Switched to a zonal GKE cluster, which satisfies availability requirements
for this use case while remaining cost-efficient.

**Design decision**

- Reduced cost
- Simpler operations
- Fully aligned with challenge scope

**2. CPU Architecture Mismatch (ARM vs amd64)**

**Issue**

Images built on Apple Silicon caused:

```
exec format error

```

Resolution

**Moved all image builds to Cloud Build (Linux amd64).**

**Lesson**
CI systems should own builds — not developer laptops.

**3. Cloud Build → GKE Connectivity (By Design)**

**Observed behavior**

```
kubectl timeout / API unreachable

```

**Reason**

Private GKE control plane
No public endpoint exposure

**Why this is correct**


- Strong security posture
- CI/CD should run from trusted networks or private runners
- **This behavior was expected, accepted, and documented.**

**Future Enhancements (Intentionally Not Implemented)**
-------------------------------------------------------

```

Service Mesh (Istio / ASM)
--------------------------
In a production environment, a service mesh could be introduced to:

- Enforce mTLS between services
- Enable canary and blue/green deployments
- Centralize traffic policy and observability

Why it was not deployed at this stage
- Adds significant operational complexity
- Not required for current scale
- Best introduced when there is a clear business driver
```



CI check Thu Dec 18 15:21:26 CET 2025
QUICK SMOKE TEST
