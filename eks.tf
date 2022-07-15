locals {
  main_tags = {
    ManagedBy = "prasoon-infra-eks"
    Cluster   = "eks-k8s/${var.environment}"
  }
  tags = merge(local.main_tags, var.eks["eks_extra_tags"])
}


module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.26.1"
  cluster_version = "1.22"
  cluster_name    = var.environment
  create          = var.if-create-cluster
  subnet_ids      = concat(module.vpc.public_subnets, module.vpc.private_subnets)
  vpc_id          = module.vpc.vpc_id
  tags            = local.tags // This will create tag for all the resources managed by EKS
  #cluster_tags                  = local.tags // This is only for EKS-cluster tagging
  create_cluster_security_group   = true
  create_iam_role                 = true
  cluster_endpoint_private_access = var.eks["cluster_endpoint_private_access"]
  cluster_endpoint_public_access  = var.eks["cluster_endpoint_public_access"]
  eks_managed_node_groups = {
    nodegroup = {
      min_size     = var.managed_node_groups["min_size"]
      max_size     = var.managed_node_groups["max_size"]
      desired_size = var.managed_node_groups["desired_size"]
      taints       = var.managed_node_groups["taints"]

    }
    nodegroup2_spot1 = {
      launch_template_name   = ""
      create_launch_template = false
      disk_size              = 10
      min_size               = var.managed_node_groups_spot["min_size"]
      max_size               = var.managed_node_groups_spot["max_size"]
      desired_size           = var.managed_node_groups_spot["desired_size"]
      capacity_type          = var.managed_node_groups_spot["capacity_type"]
      instance_types         = ["m6a.2xlarge"]
    }
  }

  eks_managed_node_group_defaults = {
    instance_types         = ["m5.xlarge"]
    disk_size              = 10
    subnet_ids             = module.vpc.private_subnets
    description            = "EKS managed node groups"
    launch_template_name   = ""
    create_launch_template = false
    labels = {
      "group-name" = "prasooncloud"
    }
    tags = {
      "Name"                                         = "${var.environment}-proficloud-eks-asg",
      "k8s.io/cluster-autoscaler/enabled"            = "true",
      "k8s.io/cluster-autoscaler/${var.environment}" = "owned",
      "kubernetes.io/cluster/${var.environment}"     = "owned"
    }
  }

  manage_aws_auth_configmap = true
  cluster_enabled_log_types = ["audit", "api", "authenticator"]

  #custom_oidc_thumbprints = []
  #openid_connect_audiences = []
  #config_output_path              = "${var.output_path}/eks"

  /*
  //This is used to add node IAM role to aws_auth_configmap

  aws_auth_node_iam_role_arns_non_windows = [
    module.eks_managed_node_groups.iam_role_arn
  ]*/

  aws_auth_roles = [
    {
      rolearn  = var.aws_eks_role_arn
      username = "yourroleusername"
      groups   = ["system:masters"]
    }
  ]

  aws_auth_users = [
    {
      userarn  = var.infra-eks-user
      username = "infra-eks"
      groups   = ["system:masters"]
    }
  ]
}
resource "null_resource" "add_eks_cluster_to_kube_config" {
  triggers = {
    cluster_ca = module.eks.cluster_certificate_authority_data
  }
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region ${var.region} --name ${var.environment}"
  }
}

### Helm service account with permanent token ###
resource "kubernetes_service_account" "sa_for_helm" {
  metadata {
    name      = "terraform-helm-service-account"
    namespace = "kube-system"
  }
  automount_service_account_token = true
  depends_on                      = [module.eks.kubeconfig]
}

resource "kubernetes_cluster_role_binding" "cluster_role_for_helm" {
  metadata {
    name = "terraform-helm-cluster-role"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.sa_for_helm.metadata.0.name
    namespace = "kube-system"
  }
  depends_on = [module.eks.kubeconfig]
}

data "kubernetes_secret" "helm_secret" {
  metadata {
    namespace = "kube-system"
    name      = kubernetes_service_account.sa_for_helm.default_secret_name
  }
}
