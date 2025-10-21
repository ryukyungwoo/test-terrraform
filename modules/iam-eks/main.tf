module "eks_cluster_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.0"

  create_role = true
  role_name = "${var.project_name}-${var.environment}-eks-cluster-role"

  # eks.amazonaws.com이 assume 할 수 있도록
  trusted_role_services = ["eks.amazonaws.com"]

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  ]

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

module "eks_worker_node_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.0"

  create_role = true
  role_name = "${var.project_name}-${var.environment}-eks-worker-node-role"

  # ec2.amazonaws.com이 assume 할 수 있도록
  trusted_role_services = ["ec2.amazonaws.com"]

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_iam_instance_profile" "eks_worker_nodes" {
  name = "${var.project_name}-${var.environment}-eks-worker-node-profile"
  role = module.eks_worker_node_iam_role.iam_role_name

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}



  # OIDC Provider (주석 처리)
  # resource "aws_iam_openid_connect_provider" "eks" {
  #   # EKS 클러스터 생성 후 활성화
  # }

  # IRSA Roles (주석 처리)
  # AWS Load Balancer Controller Role
  # module "aws_load_balancer_controller_irsa_role" {
  #   # 나중에 활성화
  # }