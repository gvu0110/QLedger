locals {
  common_tags = {
    Env    = "prod"
    Owner  = "terraform"
    Region = var.region
  }
}

data "template_file" "task_definition" {
  template = file("./task-definition.json.tpl")
  vars = {
    name  = "${var.app_name}-task"
    image = "157117204602.dkr.ecr.ca-central-1.amazonaws.com/qledger-ecr-repository:b97777c7"
  }
}

module "autoscaling-group" {
  source = "./autoscaling-group"
  app_name = var.app_name
  tags   = local.common_tags
  key_name = var.key_name
}

module "compute" {
  source = "./compute"
  app_name = var.app_name
  tags   = local.common_tags
  key_name = var.key_name
}

module "ecs" {
  source = "./ecs"
  app_name = var.app_name
  tags   = local.common_tags
}

module "iam" {
  source = "./iam"
  app_name = var.app_name
  tags   = local.common_tags
}

module "networking" {
  source = "./networking"
  app_name = var.app_name
  tags   = local.common_tags
}

module "rds" {
  source = "./rds"
  app_name = var.app_name
  tags   = local.common_tags
}

module "security_groups" {
  source = "./security-groups"
  app_name = var.app_name
  tags   = local.common_tags
}