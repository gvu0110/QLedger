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

resource "aws_instance" "bastion" {
  ami = "ami-0d0eaed20348a3389" # Ubuntu 18.04
  instance_type = "t2.micro"
  subnet_id = module.networking.public_subnet_primary_id
  vpc_security_group_ids = [module.security-groups.bastion_sg_id]
  key_name = var.key_name

  tags = merge({
    Name = "bastion"
  }, var.tags)
}