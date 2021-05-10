output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}

output "ecs_sg_id" {
  value = aws_security_group.ecs_sg.id
}

output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}