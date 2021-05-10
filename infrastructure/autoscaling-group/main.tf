data "template_file" "user_data" {
  template = file("./ec2_user_data.tpl")
  vars = {
    cluster_name = module.ecs.ecs_cluster_name
  }
}

module "networking" {
  source = "../networking"
  app_name = var.app_name
  tags   = var.tags
}

module "ecs" {
  source = "../ecs"
  app_name = var.app_name
  tags   = var.tags
}

module "iam" {
  source = "../iam"
  app_name = var.app_name
  tags   = var.tags
}

module "security_groups" {
  source = "../security-groups"
  app_name = var.app_name
  tags   = var.tags
}

resource "aws_iam_instance_profile" "ecs_agent" {
  name = "${var.app_name}-ecs-agent"
  role = module.iam.ecs_agent_role_name
}

resource "aws_launch_configuration" "ecs_launch_configuration" {
  name                        = "${var.app_name}-ecs-launch-configuration"
  instance_type               = "t2.micro"
  image_id                    = "ami-043e33039f1a50a56" # Ubuntu 20.04
  iam_instance_profile        = aws_iam_instance_profile.ecs_agent.id
  associate_public_ip_address = true
  security_groups             = [module.security_groups.ecs_sg_id]
  user_data                   = data.template_file.user_data.rendered
  key_name                    = var.key_name
}

resource "aws_autoscaling_group" "ecs_autoscaling_group" {
  name = "${var.app_name}-ecs-autoscaling-group"
  vpc_zone_identifier = [
    module.networking.public_subnet_primary_id,
    module.networking.public_subnet_secondary_id
  ]
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 2
  launch_configuration      = aws_launch_configuration.ecs_launch_configuration.name
  health_check_grace_period = 300
  health_check_type         = "EC2"
}