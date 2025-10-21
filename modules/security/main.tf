module "eks_cluster_sg" {
  source = "terraform-aws-modules/security-group/aws"
  version = "~>5.0"

  name = "${var.project_name}-${var.environment}-eks-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id = var.vpc_id

  ingress_rules = ["https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules = ["all-all"]

  tags = {
    Name        = "${var.project_name}-${var.environment}-eks-cluster-sg"
    Environment = var.environment
  }
}

module "eks_worker_nodes_sg" {
  source = "terraform-aws-modules/security-group/aws"
  version = "~>5.0"

  name = "${var.project_name}-${var.environment}-eks-worker-nodes-sg"
  description = "Security group for EKS worker nodes"
  vpc_id = var.vpc_id

  ingress_with_self = [
    {
        rule = "all-all"
        description = "Allow all traffic within the security group"
    }
  ]

  ingress_with_source_security_group_id = [
    {
        from_port                = 1025
        to_port                  = 65535
        protocol                 = "tcp"
        description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
        source_security_group_id = module.eks_cluster_sg.security_group_id
    },
    {
        from_port                = 443
        to_port                  = 443
        protocol                 = "tcp"
        description              = "Allow pods to communicate with the cluster API"
        source_security_group_id = module.eks_cluster_sg.security_group_id
    },
    {
        from_port                = 22
        to_port                  = 22
        protocol                 = "tcp"
        description              = "Allow SSH access from Bastion host"
        source_security_group_id = module.bastion_sg.security_group_id
    }
  ]

  ingress_with_cidr_blocks = [
    {
        # Spring Gateway Service의 'port' (TargetPort 아님)
        from_port= 80 
        to_port= 80
        protocol= "tcp"
        description = "Allow Internet traffic for NLB (Spring Gateway Service)"
        # NLB는 클라이언트 IP를 보존하므로 0.0.0.0/0 (인터넷)에서 열어야 함
        cidr_blocks = "0.0.0.0/0"
    },
    {
        # Spring Boot Admin Service의 'port' (TargetPort 아님)
        from_port= 443
        to_port= 443
        protocol= "tcp"
        description = "Allow Internet traffic for NLB (Spring Boot Admin Service)"
        # NLB는 클라이언트 IP를 보존하므로
        cidr_blocks = "0.0.0.0/0"
    }
]

  egress_rules = ["all-all"]

  tags = {
    Name = "${var.project_name}-${var.environment}-eks-worker-nodes-sg"
    Environment = var.environment
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

module "alb_sg" {
  source = "terraform-aws-modules/security-group/aws"
  version = "~>5.0"

  name = "${var.project_name}-${var.environment}-alb-sg"
  description = "Security group for ALB"
  vpc_id = var.vpc_id

  ingress_rules = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules = ["all-all"]

  tags = {
    Name        = "${var.project_name}-${var.environment}-alb-sg"
    Environment = var.environment
  }
}

module "rds_sg" {
  source = "terraform-aws-modules/security-group/aws"
  version = "~>5.0"

  name = "${var.project_name}-${var.environment}-rds-sg"
  description = "Security group for RDS"
  vpc_id = var.vpc_id

  ingress_with_source_security_group_id = [
    {
        from_port                = 5432
        to_port                  = 5432
        protocol                 = "tcp"
        description              = "Allow Postgres access from EKS worker nodes"
        source_security_group_id = module.eks_worker_nodes_sg.security_group_id
    }
  ]

  egress_rules = ["all-all"]

  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-sg"
    Environment = var.environment
  }
}

module "bastion_sg" {
    source = "terraform-aws-modules/security-group/aws"
    version = "~>5.0"
    
    name = "${var.project_name}-${var.environment}-bastion-sg"
    description = "Security group for Bastion host"
    vpc_id = var.vpc_id
    
    ingress_rules = ["ssh-tcp"]
    ingress_cidr_blocks = ["0.0.0.0/0"]
    egress_rules = ["all-all"]

    tags = {
      Name        = "${var.project_name}-${var.environment}-bastion-sg"
      Environment = var.environment
    }
}