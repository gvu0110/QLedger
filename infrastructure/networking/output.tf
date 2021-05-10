output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_primary_id" {
  value = aws_subnet.public-subnet-primary.id
}

output "public_subnet_secondary_id" {
  value = aws_subnet.public-subnet-secondary.id
}

output "private_subnet_primary_id" {
  value = aws_subnet.private-subnet-primary.id
}

output "private_subnet_secondary_id" {
  value = aws_subnet.private-subnet-secondary.id
}