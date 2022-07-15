variable "deployment_key" {
  type    = string
  default = null
}

variable "vpc" {
  type = object({
    cidr                 = string
    public_subnets       = list(string)
    private_subnets      = list(string)
    enable_dns_hostnames = string
  })
}

variable "eks" {
  type = object({
    eks_extra_tags                  = map(string)
    cluster_endpoint_private_access = string
    cluster_endpoint_public_access  = string
  })
}

variable "managed_node_groups" {
  type = object({

    min_size     = string
    max_size     = string
    desired_size = string
    taints       = any
  })
}

variable "managed_node_groups_spot" {
  type = object({

    min_size      = string
    max_size      = string
    desired_size  = string
    capacity_type = string
  })
}

variable "region" {
  type = string
}

variable "environment" {
  type    = string
  default = "infrastructure"
}

variable "output_path" {
  type = string
}

variable "remote_state_data" {
  type = string
}

variable "aws_eks_role_arn" {
  type = string
}

variable "infra-eks-user" {
  type = string
}

variable "if-create-cluster" {
  type = bool
}

variable "PATH" {
  type = any
}

variable "endpoint" {
  type = string
}
variable "tf_cloud_enabled" {
  type = bool
}

