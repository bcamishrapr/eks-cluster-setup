output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "cluster_id" {
  description = "EKS cluster name/id"
  value       = module.eks.cluster_id
}


/*output "kubectl_config" {
  description = "kubectl config as generated by the module."
  value       = module.eks.kubeconfig
}*/

/*output "config_map_aws_auth" {
  description = "A kubernetes configuration to authenticate to this EKS cluster."
  value       = module.eks.config_map_aws_auth
}*/


output "kube_info" {
  value = {
    "load_config_file" : false
    "kube_version" : module.eks.cluster_version
    "kube_api_url" : module.eks.cluster_endpoint
    "kube_api_ca" : module.eks.cluster_certificate_authority_data
    "kube_api_token" : data.aws_eks_cluster_auth.cluster.token
  }
  sensitive = true
}

output "cluster_iam_role_name" {
  description = "A kubernetes configuration to authenticate to this EKS cluster."
  value       = module.eks.cluster_iam_role_name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster."
  value       = module.eks.cluster_iam_role_arn
}

output "eks_managed_node_groups" {
  description = "Map of attribute maps for all EKS managed node groups created"
  value       = module.eks.eks_managed_node_groups
}

output "eks_managed_node_groups_autoscaling_group_names" {
  description = "List of the autoscaling group names created by EKS managed node groups"
  value       = module.eks.eks_managed_node_groups_autoscaling_group_names
}

output "service_account_for_helm" {
  value = kubernetes_service_account.sa_for_helm.metadata[0].name
}

output "security_group_id" {
  value = module.vpc.default_security_group_id
}

output "helm_token" {
  value     = data.kubernetes_secret.helm_secret.data.token
  sensitive = true
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}