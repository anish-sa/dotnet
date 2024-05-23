resource "aws_key_pair" "ssh_key" {
  key_name   = "anish_dotnet_en_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDsbwyYuG8LPv5UorIfpTdHWiO/qo3aOymvr9ALfYGMyXQ/52ySMgENEyVToamRxXh8xyRNuVKhe2rLZkSkS9ulg3SmtuDrFE1XYLy1ou1PQJqSBeI1RwzDa8vBapn3lwufkU5K4pByaYgoXWHoLN9F3SxJ9vMyjgKyB6w8ZOlbILgGQDOfOYnzz/8DlEYbdAB24ZSKPMTK6Zjw8HSQycy/4i12boHSSn99s5sThwP6NFZ8VpFkbAfJBqQ5VgstGkDVhaTIUQMhqUghNKuK5JIn9gKF2jmxSzqGmw8aXfTNY4csrx0lKJtAd2MobDRZL2qeP/gApyNUFRcW+mQRHFMn"
}

module "elastic_beanstalk_application" {
  source = "git@github.com:adexltd/terraform-aws-elastic-beanstalk-module.git//modules/app?ref=DEVOPS-63-feat-elastic-beanstalk"
  name   = "${local.name_prefix}-eb-dotnet"

  eb_application_version_enabled = var.eb_application_version_enabled
  eb_application_version_name    = var.eb_application_version_name
  eb_source_bucket_name          = var.eb_source_bucket_name
  eb_source_bucket_key           = var.eb_source_bucket_key
}

module "elastic_beanstalk_environment" {
  source = "git@github.com:adexltd/terraform-aws-elastic-beanstalk-module.git//modules/environment?ref=DEVOPS-63-feat-elastic-beanstalk"
  name   = "${local.name_prefix}-eb-env-dotnet"

  description                = var.description
  region                     = var.region
  availability_zone_selector = var.availability_zone_selector

  wait_for_ready_timeout             = var.wait_for_ready_timeout
  elastic_beanstalk_application_name = module.elastic_beanstalk_application.elastic_beanstalk_application_name
  environment_type                   = var.environment_type
  loadbalancer_type                  = var.loadbalancer_type
  loadbalancer_is_shared             = var.loadbalancer_is_shared
  shared_loadbalancer_arn            = module.alb.alb_arn
  healthcheck_url                    = "/"

  tier          = var.tier
  version_label = var.version_label

  instance_type    = var.instance_type
  root_volume_size = var.root_volume_size
  root_volume_type = var.root_volume_type

  autoscale_min             = var.autoscale_min
  autoscale_max             = var.autoscale_max
  autoscale_measure_name    = var.autoscale_measure_name
  autoscale_statistic       = var.autoscale_statistic
  autoscale_unit            = var.autoscale_unit
  autoscale_lower_bound     = var.autoscale_lower_bound
  autoscale_lower_increment = var.autoscale_lower_increment
  autoscale_upper_bound     = var.autoscale_upper_bound
  autoscale_upper_increment = var.autoscale_upper_increment

  vpc_id               = module.vpc.vpc_id
  loadbalancer_subnets = module.subnets.public_subnet_ids
  application_subnets  = module.subnets.public_subnet_ids

  rolling_update_enabled  = var.rolling_update_enabled
  rolling_update_type     = var.rolling_update_type
  updating_min_in_service = var.updating_min_in_service
  updating_max_batch      = var.updating_max_batch

  # https://docs.aws.amazon.com/elasticbeanstalk/latest/platforms/platforms-supported.html
  # https://docs.aws.amazon.com/elasticbeanstalk/latest/platforms/platforms-supported.html#platforms-supported.docker
  solution_stack_name = var.solution_stack_name

  # additional_settings = var.additional_settings
  additional_settings = [
  {
    namespace = "aws:elasticbeanstalk:managedactions"
    name      = "ManagedActionsEnabled"
    value     = "false"
  },
  # {
  #   namespace = "aws:elb:loadbalancer"
  #   name = "SecurityGroups"
  #   value = module.alb.security_group_id
  # }
]
  env_vars            = var.env_vars

  extended_ec2_policy_document = data.aws_iam_policy_document.minimal_s3_permissions.json
  prefer_legacy_ssm_policy     = false
  prefer_legacy_service_policy = false
  scheduled_actions            = var.scheduled_actions

  depends_on = [module.alb]

  associate_public_ip_address = true
  keypair = aws_key_pair.ssh_key.key_name



}

data "aws_iam_policy_document" "minimal_s3_permissions" {
  #checkov:skip=CKV_AWS_356:Skiping this for example data block

  statement {
    sid = "AllowS3OperationsOnElasticBeanstalkBuckets"
    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation"
    ]
    resources = ["*"]
  }
}
