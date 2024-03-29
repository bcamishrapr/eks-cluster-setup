provider "aws" {
  region = var.region
  #THIS KEY SHOULD CONFIGURED IN TF-WORKSPACE
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "terraform_remote_state" "eks_ws_state" {
  backend = "remote"
  config = {
    organization = "your-org"
    workspaces = {
      name = "prasoon-wp"
    }
  }
}  
  
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  #load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.kubernetes_secret.helm_secret.data.token
  }
}
    
#IF YOU INSTALL GRAFANA HELM CHART ALSO   
    
#provider "grafana" {
  #url  = var.grafana_url
  #auth = var.grafana_auth
#}*/
    
