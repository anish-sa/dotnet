module "naming" {
  source = "git@github.com:adexltd/terraform-naming-convention-module?ref=v5.0.0"

  app_name       = "adex"
  project_prefix = "tfmodule"
  app_name_short = "eb"
  environment    = var.environment
}
