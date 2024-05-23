module "vpc" {
  #checkov:skip=CKV_TF_1:Skiping terraform commit hash
  #checkov:skip=CKV_TF_2:Version is defined below
  source  = "cloudposse/vpc/aws"
  version = "2.1.0"

  ipv4_primary_cidr_block = "172.16.0.0/16"

}

module "subnets" {
  #checkov:skip=CKV_TF_1:Skiping terraform commit hash
  #checkov:skip=CKV_TF_2:Version is defined below
  source  = "cloudposse/dynamic-subnets/aws"
  # version = "2.4.2"

  availability_zones   = var.availability_zones
  vpc_id               = module.vpc.vpc_id
  igw_id               = [module.vpc.igw_id]
  ipv4_enabled         = true
  ipv4_cidr_block      = [module.vpc.vpc_cidr_block]
  nat_gateway_enabled  = true
  nat_instance_enabled = false

}

module "alb" {
  #checkov:skip=CKV_TF_1:Skiping terraform commit hash
  #checkov:skip=CKV_TF_2:Version is defined below
  source  = "cloudposse/alb/aws"
  version = "1.10.0"

  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.subnets.public_subnet_ids
  access_logs_enabled = false

  # This additional attribute is required since both the `alb` module and `elastic_beanstalk_environment` module
  # create Security Groups with the names derived from the context (this would conflict without this additional attribute)
  attributes = ["shared"]
}