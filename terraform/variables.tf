variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central"
}

variable "zone" {
  description = "GCP zone for zonal GKE cluster"
  type        = string
}

variable "env" {
  description = "Environment name (dev, prod)"
  type        = string
  default     = "dev"
}

variable "admin_cidr" {
  description = "CIDR allowed to access GKE control plane"
  type        = string
}
