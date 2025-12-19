GKE 

## 🎥 Demo: End-to-End CI/CD and Deployment (VIDEO IS IN 4K 60FPS for the NERDS :P)

Watch a walkthrough of the deployment and operational flow for this project:

▶️ https://youtu.be/20l9sGCXJNg


GCP Online Boutique – Cloud-Native DevOps Challenge
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

Upstream Services: Google Online Boutique (microservices-demo)
--------------------------------------------------------------

This project is built on top of Google’s official Online Boutique reference application:

``` 
git clone https://github.com/GoogleCloudPlatform/microservices-demo
```

- That repository contains:
- Source code for all microservices
- Pre-built, official container images
- Kubernetes manifests for running the full application

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

How this repository ties in
----------------------------

| Component / Service | Ownership | Source |
|--------------------|-----------|--------|
| Frontend           | Owned     | This repository (custom image built via Cloud Build) |
| Ad Service         | Upstream  | Google Online Boutique (`microservices-demo`) |
| Cart Service       | Upstream  | Google Online Boutique (`microservices-demo`) |
| Checkout Service   | Upstream  | Google Online Boutique (`microservices-demo`) |
| Currency Service   | Upstream  | Google Online Boutique (`microservices-demo`) |
| Email Service      | Upstream  | Google Online Boutique (`microservices-demo`) |
| Payment Service    | Upstream  | Google Online Boutique (`microservices-demo`) |
| Product Catalog    | Upstream  | Google Online Boutique (`microservices-demo`) |
| Recommendation     | Upstream  | Google Online Boutique (`microservices-demo`) |
| Shipping Service   | Upstream  | Google Online Boutique (`microservices-demo`) |
| Redis Cart         | Upstream  | Google Online Boutique (`microservices-demo`) |
| Load Generator     | Upstream  | Google Online Boutique (`microservices-demo`) |


This repository does not duplicate or rebuild all upstream services.
Instead, it extends the upstream project by owning and customizing only the frontend.

This mirrors real-world practice where teams often:

- Own a subset of services
- Consume others as stable platform dependencies

## ▶️ How to Run the Entire Application (End-to-End)

This project extends Google’s **Online Boutique** reference application by owning and customizing only the `frontend` service, while consuming all other services from the upstream project.

---

### Step 1 Clone this repository

```
git clone https://github.com/neoisone/gcp-online-boutique.git
cd gcp-online-boutique
```

### Step 2 Clone the upstream Online Boutique repository
```
git clone https://github.com/GoogleCloudPlatform/microservices-demo.git
cd microservices-demo
```

This repository provides:

- Kubernetes manifests for all backend services
- References to official container images (no build required)

### Step 3 Apply upstream Kubernetes manifests
- Ensure kubectl is pointing to your GKE cluster, then run:

```
kubectl apply -f microservices-demo/release/kubernetes-manifests.yaml

```

This deploys upstream services such as:

- cartservice
- checkoutservice
- paymentservice
- recommendationservice
- redis-cart
- and others

👉 These services will start using official Google images immediately.

### Step 4 Deploy the custom frontend from this repository

Switch back to this repository and apply the frontend manifest:

cd ../gcp-online-boutique
kubectl apply -f kubernetes/frontend.yaml


Update the frontend image reference to your Artifact Registry:
image: us-central1-docker.pkg.dev/<PROJECT_ID>/<REPO_NAME>/frontend:<TAG>

This custom frontend will:

Communicate with all upstream backend services
Replace the default frontend provided by microservices-demo

### Step 5 Set up CI for the frontend (recommended)

- Create a Cloud Build trigger with:
- Source: GitHub
- Branch: <choose your branch>
- Build config: cloudbuild.yaml
Every commit to ^BRANCH will:

- Build the frontend container image
- Push it to Artifact Registry
- Update the frontend Kubernetes deployment
- No other services are rebuilt.

### Step 6 Scale services up

By default, deployments may be scaled to zero.
Start the full application with:

```
kubectl get deployments -o name | xargs -I {} kubectl scale {} --replicas=1

```

### Step 7 Access the application

Retrieve the external IP of the frontend service:

```
kubectl get svc frontend-external
```

Open the EXTERNAL-IP in your browser to access the application.

---

### Networking Design
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

### Repository Structure (Best Practice)
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
### This approach ensures:
----------------------

- Predictability
- Auditability
- Zero code duplication
- Safe environment promotion

### Security Approach
-----------------

- Private GKE cluster
- No public node IPs
- Least-privileged service accounts
- NAT Gateway for outbound internet access
- Master Authorized Networks for control-plane access
- No secrets committed to Git
- Security was designed by default, not added later.

### CI/CD (Demonstrated & Explained)
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

### Known Issues & Lessons Learned
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

```
## Production-Grade CD for Private GKE Clusters

In a production setup, Continuous Deployment (CD) can be safely introduced for **private GKE clusters** using secure, identity-first patterns.

Key enhancements:
- **Private execution environments** (e.g. Cloud Build Private Pools) to deploy from within the VPC
- **Workload Identity Federation** to avoid static credentials and kubeconfig files
- **GitOps-based CD** (e.g. Argo CD or Flux) with controllers running inside the cluster
- **Progressive rollouts** such as canary or blue/green deployments

This approach enables secure, auditable deployments without exposing the Kubernetes control plane to the public internet.
```



CI check Thu Dec 18 15:21:26 CET 2025
QUICK SMOKE TEST
