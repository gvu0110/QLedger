module "networking" {
  source = "../networking"
  app_name = var.app_name
  tags   = var.tags
}

module "security-groups" {
  source = "../security-groups"
  app_name = var.app_name
  tags   = var.tags
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "${var.app_name}-rds-subnet-group"
  subnet_ids = [
    module.networking.private_subnet_primary_id,
    module.networking.private_subnet_secondary_id
  ]

  tags = merge({
    Name = "${var.app_name}-rds-subnet-group"
  }, var.tags)
}

resource "aws_db_instance" "rds" {
  engine         = "postgres"
  engine_version = "11.10"

  instance_class        = "db.t2.micro"
  storage_type          = "gp2"
  allocated_storage     = 5
  max_allocated_storage = 20
  storage_encrypted     = false

  name       = "${var.app_name}db"
  identifier = "${var.app_name}-rds"
  username   = "root"
  password   = "root1234"
  port       = 5432

  multi_az               = true
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.id
  vpc_security_group_ids = [module.security-groups.rds_sg_id]

  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  enabled_cloudwatch_logs_exports     = []
  iam_database_authentication_enabled = false
  performance_insights_enabled        = false
  auto_minor_version_upgrade          = false

  tags = merge({
    Name = "${var.app_name}-rds"
  }, var.tags)
}