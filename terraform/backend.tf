terraform {
  backend "gcs" {
    bucket  = "metal-arc-481413-g9-tfstate"
    prefix  = "gke/dev"
  }
}
