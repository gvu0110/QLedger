module "networking" {
  source = "../networking"
  app_name = var.app_name
  tags   = var.tags
}

resource "aws_security_group" "ecs_sg" {
  name        = "${var.app_name}-ecs-sg"
  description = "ECS cluster security group"
  vpc_id      = module.networking.vpc_id

  ingress {
    description = "Allow all inbound SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow all inbound app-service traffic"
    from_port   = 7000
    to_port     = 7000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow all inbound intra-cluster traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    Name = "${var.app_name}-ecs-sg"
  }, var.tags)
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Bastion host security group"
  vpc_id      = module.networking.vpc_id

  ingress {
    description = "Allow all inbound SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    Name = "bastion-sg"
  }, var.tags)
}

resource "aws_security_group" "rds_sg" {
  name        = "${var.app_name}-rds-sg"
  description = "RDS security group"
  vpc_id      = module.networking.vpc_id

  ingress {
    description     = "Allow Postgres traffic from ECS cluster"
    protocol        = "tcp"
    from_port       = 5432
    to_port         = 5432
    security_groups = [aws_security_group.ecs_sg.id]
  }

  ingress {
    description     = "Allow Postgres traffic from bastion host"
    protocol        = "tcp"
    from_port       = 5432
    to_port         = 5432
    security_groups = [aws_security_group.bastion_sg.id]
  }

  tags = merge({
    Name = "${var.app_name}-rds-sg"
  }, var.tags)
}