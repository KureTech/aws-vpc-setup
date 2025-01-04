terraform {
  backend "s3" {
    bucket         = var.bucket
    key            = "vpc/${var.vpc_name}/terraform.tfstate"
    region         = var.region
    encrypt        = true
  }
}
