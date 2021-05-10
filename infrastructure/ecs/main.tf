data "template_file" "task_definition" {
  template = file("./task-definition.json.tpl")
  vars = {
    name  = "${var.app_name}-task"
    image = "157117204602.dkr.ecr.ca-central-1.amazonaws.com/qledger-ecr-repository:b97777c7"
  }
}

module "networking" {
  source = "../networking"
  app_name = var.app_name
  tags   = var.tags
}

module "rds" {
  source = "../rds"
  app_name = var.app_name
  tags   = var.tags
}

//module "iam" {
//  source = "./iam"
//  app_name = var.app_name
//  tags   = var.tags
//}

#######################
# Create ECR repository
#######################
resource "aws_ecr_repository" "ecr_repository" {
  name = "${var.app_name}-ecr-repository"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge({
    Name = "${var.app_name}-ecr-repository"
  }, var.tags)
}

####################
# Create ECS cluster
####################
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.app_name}-ecs-cluster"

  tags = merge({
    Name = "${var.app_name}-ecs-cluster"
  }, var.tags)
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                = "${var.app_name}-task"
  container_definitions = data.template_file.task_definition.rendered
}

//resource "aws_elb" "elb" {
//  name = "${var.appname}-elb"
//  subnets = [
//    module.networking.public_subnet_primary_id,
//    module.networking.public_subnet_secondary_id
//  ]
//  connection_draining = true
//  cross_zone_load_balancing = true
//  security_groups = [aws_security_group.ecs_sg.id]
//
//  listener {
//    instance_port = "${var.host_port}"
//    instance_protocol = "http"
//    lb_port = "${var.lb_port}"
//    lb_protocol = "http"
//  }
//
//  health_check {
//    healthy_threshold = 2
//    unhealthy_threshold = 10
//    target = "HTTP:${var.host_port}/"
//    interval = 5
//    timeout = 4
//  }
//}

resource "aws_ecs_service" "ecs_service" {
  name            = "${var.app_name}-ecs-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = 2
  //  iam_role = aws_iam_role.ecs_elb_role.arn
  //  depends_on = [aws_iam_policy_attachment.ecs_elb]
  //  deployment_minimum_healthy_percent = 50

  //  load_balancer {
  //    elb_name = aws_elb.elb.id
  //    container_name = "${var.appname}_${var.environ}"
  //    container_port = "7000"
  //  }
}

