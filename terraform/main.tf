provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google" {
  alias   = "beta"
  project = var.project_id
  region  = var.region
}

module "network" {
  source      = "./modules/network"
  vpc_name    = "ob-vpc"
  subnet_name = "ob-subnet"
  region      = var.region
}

module "gke" {
  source = "./modules/gke"

  providers = {
    google = google.beta
  }

  project_id   = var.project_id
  region       = var.region
  zone         = var.zone
  env          = var.env
  cluster_name = "ob-gke"

  vpc_id     = module.network.vpc_id
  subnet_id  = module.network.subnet_id
  admin_cidr = var.admin_cidr
}
