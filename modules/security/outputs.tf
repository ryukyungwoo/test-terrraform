
output "eks_cluster_sg_id" {
    description = "Security group ID for EKS cluster"
    value       = module.eks_cluster_sg.security_group_id
}

output "eks_nodes_sg_id" {
    description = "Security group ID for EKS nodes"
    value       = module.eks_worker_nodes_sg.security_group_id
}

output "alb_sg_id" {
    description = "Security group ID for ALB"
    value       = module.alb_sg.security_group_id
}

output "rds_sg_id" {
    description = "Security group ID for RDS"
    value       = module.rds_sg.security_group_id
}

output "bastion_sg_id" {
    description = "Security group ID for Bastion host"
    value       = module.bastion_sg.security_group_id
}