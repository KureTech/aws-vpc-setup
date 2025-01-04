# AWS region
variable "region" {
  type        = string
  description = "AWS region to deploy resources in"
  default     = "us-west-2"
}

# VPC CIDR block
variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

# Public Subnet CIDR blocks (3 AZs)
variable "public_subnet_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks for the public subnets"
  default     = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

# Private Subnet CIDR blocks (3 AZs)
variable "private_subnet_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks for the private subnets"
  default     = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
}

# Availability Zones
variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones for subnets"
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

# VPC Flow Log Configuration
variable "flow_log_group_name" {
  type        = string
  description = "CloudWatch Log Group for VPC Flow Logs"
  default     = "production-vpc-flow-logs"
}

# Define a variable for log retention
variable "log_retention_days" {
  description = "The number of days to retain flow logs in CloudWatch"
  type        = number
  default     = 30
}


# VPC Name
variable "vpc_name" {
  type        = string
  description = "The name of the VPC"
  default     = "production-vpc"  # You can change the default value or leave it empty for tfvars to provide it
}

variable "oidc_thumbprint" {
  description = "The thumbprint for GitHub OIDC provider SSL certificate."
  type        = list(string)
  default     = ["9e99a8a038de80b24b91ab3a4f22356d7a470e4d"] # Default value for testing, replace with dynamic
}
variable "github_repos" {
  type    = list(string)
  default = ["kuretech/repo1", "kuretech/repo2"]
}

variable "github_branch" {
  type    = string
  default = "main"
}

variable "environment" {
  description = "The environment the resource is deployed in (e.g., prod, dev, staging)"
  type        = string
}

variable "owner" {
  description = "The owner of the resource (e.g., the team or individual responsible)"
  type        = string
}

variable "project" {
  description = "The name of the project the resource belongs to"
  type        = string
}

variable "cost_center" {
  description = "Cost center associated with the resource"
  type        = string
}

variable "created_by" {
  description = "The individual who created the resource"
  type        = string
}

variable "application" {
  description = "The application associated with the resource"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply across resources"
  type        = map(string)
  default     = {}
}