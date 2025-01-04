# Provider Configuration
provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

# Create VPC
resource "aws_vpc" "vpcname_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(
    {
      Name        = var.vpc_name
      Environment = var.environment
      Owner       = var.owner
      Project     = var.project
      CostCenter  = var.cost_center
      CreatedBy   = var.created_by
      Application = var.application
      Purpose     = "VPC for ${var.project}"
      Region      = var.region
    },
    var.common_tags 
  )
}

# Create Public Subnets
resource "aws_subnet" "public_subnet" {
  for_each = toset(var.public_subnet_cidr_blocks)

  vpc_id                  = aws_vpc.vpcname_vpc.id
  cidr_block              = each.value
  availability_zone       = element(data.aws_availability_zones.available.names, index(var.public_subnet_cidr_blocks, each.value))
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name        = "public-subnet-${each.value}"
      Environment = var.environment
      Owner       = var.owner
      Project     = var.project
      CostCenter  = var.cost_center
      CreatedBy   = var.created_by
      Application = var.application
      Purpose     = "VPC for ${var.project}"
      Region      = var.region
    },
    var.common_tags  
  )
}

# Create Private Subnets
resource "aws_subnet" "private_subnet" {
  for_each = toset(var.private_subnet_cidr_blocks)

  vpc_id                  = aws_vpc.vpcname_vpc.id
  cidr_block              = each.value
  availability_zone       = element(data.aws_availability_zones.available.names, index(var.private_subnet_cidr_blocks, each.value))
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name        = "private-subnet-${each.value}"
      Environment = var.environment
      Owner       = var.owner
      Project     = var.project
      CostCenter  = var.cost_center
      CreatedBy   = var.created_by
      Application = var.application
      Purpose     = "VPC for ${var.project}"
      Region      = var.region
    },
    var.common_tags  
  )
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpcname_vpc.id
  
  tags = merge(
    {
      Name        = "vpcname-igw"
      Environment = var.environment
      Owner       = var.owner
      Project     = var.project
      CostCenter  = var.cost_center
      CreatedBy   = var.created_by
      Application = var.application
      Purpose     = "VPC for ${var.project}"
      Region      = var.region
    },
    var.common_tags  
  )
}

# Create Elastic IPs for NAT Gateway
resource "aws_eip" "nat_eip" {
  count  = length(var.private_subnet_cidr_blocks)
  domain = "vpc"
  tags = merge(
    {
      Name        = "nat-eip-${count.index + 1}"
      Environment = var.environment
      Owner       = var.owner
      Project     = var.project
      CostCenter  = var.cost_center
      CreatedBy   = var.created_by
      Application = var.application
      Purpose     = "VPC for ${var.project}"
      Region      = var.region
    },
    var.common_tags  
  )
}

# Create NAT Gateways
resource "aws_nat_gateway" "nat_gateway" {
  for_each = toset(var.private_subnet_cidr_blocks)

  allocation_id = aws_eip.nat_eip[index(var.private_subnet_cidr_blocks, each.value)].id
  subnet_id     = element(values(aws_subnet.public_subnet)[*].id, index(var.private_subnet_cidr_blocks, each.value))
  
  tags = merge(
    {
      Name        = "nat-gateway-${each.value}"
      Environment = var.environment
      Owner       = var.owner
      Project     = var.project
      CostCenter  = var.cost_center
      CreatedBy   = var.created_by
      Application = var.application
      Purpose     = "VPC for ${var.project}"
      Region      = var.region
    },
    var.common_tags  
  )
}


# Create Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpcname_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    {
      Name        = "public-route-table"
      Environment = var.environment
      Owner       = var.owner
      Project     = var.project
      CostCenter  = var.cost_center
      CreatedBy   = var.created_by
      Application = var.application
      Purpose     = "VPC for ${var.project}"
      Region      = var.region
    },
    var.common_tags  
  )
}

# Associate Public Subnets with Route Table
resource "aws_route_table_association" "public_association" {
  for_each = aws_subnet.public_subnet

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create Private Route Tables
resource "aws_route_table" "private_route_table" {
  for_each = aws_nat_gateway.nat_gateway

  vpc_id = aws_vpc.vpcname_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = each.value.id
  }

  tags = merge(
    {
      Name        = "private-route-table-${each.key}"
      Environment = var.environment
      Owner       = var.owner
      Project     = var.project
      CostCenter  = var.cost_center
      CreatedBy   = var.created_by
      Application = var.application
      Purpose     = "VPC for ${var.project}"
      Region      = var.region
    },
    var.common_tags  
  )
}

# Associate Private Subnets with Route Tables
resource "aws_route_table_association" "private_association" {
  for_each = aws_subnet.private_subnet

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_table[each.key].id
}

# Create Security Group for Web
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.vpcname_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name        = "web-sg"
      Environment = var.environment
      Owner       = var.owner
      Project     = var.project
      CostCenter  = var.cost_center
      CreatedBy   = var.created_by
      Application = var.application
      Purpose     = "VPC for ${var.project}"
      Region      = var.region
    },
    var.common_tags  
  )
}

# Create IAM Role for Flow Logs
resource "aws_iam_role" "flow_log_role" {
  name               = "FlowLogRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Create Flow Logs
resource "aws_flow_log" "vpc_flow_log" {
  vpc_id           = aws_vpc.vpcname_vpc.id
  traffic_type     = "ALL"
  log_destination  = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:vpc-flow-logs"
  iam_role_arn     = aws_iam_role.flow_log_role.arn
}

# Create CloudWatch Log Group
resource "aws_cloudwatch_log_group" "vpc_flow_log_group" {
  name              = "vpc-flow-logs-${aws_vpc.vpcname_vpc.id}"
  retention_in_days = var.log_retention_days
}

# IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions" {
  name               = "GitHubActionsRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action    = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = "repo:${join(",", var.github_repos)}:ref:refs/heads/${var.github_branch}"
          }
        }
      }
    ]
  })
}

# IAM Role Policy for GitHub Actions
resource "aws_iam_role_policy" "github_actions_policy" {
  name   = "GitHubActionsPolicy"
  role   = aws_iam_role.github_actions.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "ec2:CreateVpc",
          "ec2:CreateSubnet",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:CreateInternetGateway",
          "ec2:AttachInternetGateway",
          "ec2:CreateRouteTable",
          "ec2:AssociateRouteTable",
          "ec2:CreateNatGateway",
          "ec2:CreateSecurityGroup",
          "ec2:CreateNetworkAcl"
        ]
        Resource = "*"  # Consider narrowing down to more specific resources
      }
    ]
  })

  depends_on = [aws_iam_role.github_actions]  # Ensure IAM role is created before attaching policy
}

# IAM OIDC Provider for GitHub Actions

resource "aws_iam_openid_connect_provider" "github_oidc" {
  count = length(data.aws_iam_openid_connect_provider.github_oidc.id) > 0 ? 0 : 1

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = var.oidc_thumbprint
  depends_on = [aws_iam_role.github_actions]  # Ensure IAM role is created before OIDC provider
}
data "aws_iam_openid_connect_provider" "github_oidc" {
  url = "https://token.actions.githubusercontent.com"
}
