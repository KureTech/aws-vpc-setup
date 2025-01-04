region                  = "us-east-1"
vpc_cidr_block          = "10.10.0.0/16"
public_subnet_cidr_blocks = ["10.10.0.0/24", "10.10.1.0/24", "10.10.2.0/24"]
private_subnet_cidr_blocks = ["10.10.3.0/24", "10.10.4.0/24", "10.10.5.0/24"]
availability_zones      = ["us-east-1a", "us-east-1b", "us-east-1c"]
vpc_name                = "PROD"
github_repos            = ["kuretech/repo1", "kuretech/repo2"]
github_branch           = "main"
log_retention_days = 1

environment="PROD"
owner = "KureTech"
project = "KureTech Projects"
cost_center = "123456"
created_by = "KureTech"
application = "KureTech Apps"

# Common Tags (for shared usage across resources)
common_tags = {
  "ManagedBy" = "Terraform"
  "Support"   = "24x7"
  "Compliance" = "SOC2",
   Type        = "Infrastructure",
   security_compliance = "SOC2-compliant"
}
