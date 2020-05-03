output "rds_cluster" {
  value = aws_rds_cluster.this
}

output "rds_cluster_instance" {
  value = aws_rds_cluster_instance.this
}

output "secretsmanager_secret" {
  value = aws_secretsmanager_secret.this
}

output "security_group" {
  value = aws_security_group.this
}
