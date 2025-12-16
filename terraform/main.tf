provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

module "network" {
  source      = "./modules/network"
  vpc_name    = "ob-vpc"
  subnet_name = "ob-subnet"
  region      = var.region
}
