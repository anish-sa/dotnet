locals {
  name        = module.naming.resources.vpc.name
  name_prefix = module.naming.resources.prefix.name

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Name = local.name
  }

  elb_settings_final = [{
    namespace = "aws:elasticbeanstalk:command"
    name = "Timeout"
    value = 1500
  },{
    namespace = "aws:elasticbeanstalk:hostmanager"
    name = "LogPublicationControl"
    value = true
  },{
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name = "StreamLogs"
    value = true
  }]
}
