module "vpc" {
  source  = "./modules/vpc"
  project = var.project
}

module "security_groups" {
  source  = "./modules/security-groups"
  project = var.project
  vpc_id  = module.vpc.vpc_id

}

module "alb" {
  source = "./modules/alb"

  vpc_id                  = module.vpc.vpc_id
  alb_sg_id               = module.security_groups.alb_sg_id
  public_subnet_ids       = module.vpc.public_subnet_ids
  monitoring_instance_id  = module.compute.monitoring_instance_id
  project                 = var.project
}

module "compute" {
  source = "./modules/compute"

  private_subnet_ids  = module.vpc.private_subnet_ids
  private_ec2_sg_id   = module.security_groups.private_ec2_sg_id
  role                = var.role   
  project             = var.project

  grafana_tg_arn      = module.alb.grafana_tg_arn
  prometheus_tg_arn   = module.alb.prometheus_tg_arn
}


module "nacl" {
  source             = "./modules/nacl"
  project            = var.project
  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = module.vpc.vpc_cidr
  private_subnet_ids = module.vpc.private_subnet_ids
}
