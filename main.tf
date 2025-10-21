module "network" {
  source = "./modules/network"

  project_name = var.project_name
  environment  = var.environment
}

module "security" {
  source = "./modules/security"

  project_name = var.project_name
  environment  = var.environment

  vpc_id       = module.network.vpc_id
  vpc_cidr     = module.network.vpc_cidr_block
  cluster_name = "${var.project_name}-${var.environment}-eks"
}