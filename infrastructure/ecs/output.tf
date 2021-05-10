output "repository_url" {
  value = aws_ecr_repository.ecr_repository.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.ecs_cluster.name
}