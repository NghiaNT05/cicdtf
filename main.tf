#root
module "vpc" {
  source = "./vpc"
}
module "ec2" {
  source = "./web"
  prisub = module.vpc.prisub
  sg_application = module.vpc.sg_application
  pubsub = module.vpc.pubsub
  sg_web = module.vpc.sg_web
  sg_bastion = module.vpc.sg_bastion
  sg_dp = module.vpc.sg_dp
  db_subnet_group_name = module.vpc.db_subnet_group_name
  db_password = var.db_password
  db_username = var.db_username
}