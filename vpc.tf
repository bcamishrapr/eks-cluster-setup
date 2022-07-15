data "aws_availability_zones" "available" {
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  name                 = var.environment
  cidr                 = var.vpc["cidr"]
  azs                  = data.aws_availability_zones.available.names
  enable_nat_gateway   = true
  single_nat_gateway   = true
  public_subnets       = var.vpc["public_subnets"]
  private_subnets      = var.vpc["private_subnets"]
  enable_dns_hostnames = true
  tags = {
    "kubernetes.io/cluster/${var.environment}" = "shared"
  }
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.environment}" = "shared"
    "kubernetes.io/role/elb"                   = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.environment}" = "shared"
    "kubernetes.io/role/internal-elb"          = "1"
  }
}