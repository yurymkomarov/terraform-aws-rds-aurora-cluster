locals {
  master_username = var.master_username
  master_password = var.master_password == "password" ? random_password.master_password.result : var.master_password
  database_name   = var.database_name == "database" ? random_pet.database_name.id : var.database_name
  database_port   = var.engine == "aurora-postgresql" ? 5432 : 3306

  credentials = {
    username = local.master_username
    password = local.master_password
    database = local.database_name
  }
}

resource "random_id" "this" {
  byte_length = 1

  keepers = {
    storage_encrypted   = var.storage_encrypted
    master_username     = var.master_username
    master_password     = var.master_password
    database_name       = var.database_name
    snapshot_identifier = var.snapshot_identifier
    vpc_subnets         = join("", var.vpc_subnets)
  }
}

resource "random_pet" "database_name" {
  separator = ""
}

resource "random_password" "master_password" {
  length           = 32
  override_special = "`~!#$%^&*()_+,\\-"
}

resource "aws_db_subnet_group" "this" {
  description = "DB subnet group for ${var.name}"
  name        = "${var.name}-${random_id.this.hex}"
  subnet_ids  = var.vpc_subnets

  tags = {
    Name      = var.name
    Module    = path.module
    Workspace = terraform.workspace
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_rds_cluster" "this" {
  backup_retention_period   = 30
  database_name             = local.database_name
  db_subnet_group_name      = aws_db_subnet_group.this.id
  engine                    = var.engine
  final_snapshot_identifier = "${var.name}-${random_id.this.hex}"
  cluster_identifier        = "${var.name}-${random_id.this.hex}"
  master_username           = local.master_username
  master_password           = local.master_password
  port                      = local.database_port
  storage_encrypted         = var.storage_encrypted
  snapshot_identifier       = var.snapshot_identifier
  vpc_security_group_ids    = [aws_security_group.this.id]

  tags = {
    Name      = var.name
    Module    = path.module
    Workspace = terraform.workspace
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_rds_cluster_instance" "this" {
  count = length(var.vpc_subnets)

  availability_zone    = data.aws_availability_zones.this.names[count.index]
  cluster_identifier   = aws_rds_cluster.this.id
  identifier           = "${var.name}-${random_id.this.hex}-${count.index}"
  instance_class       = var.instance_class
  db_subnet_group_name = aws_db_subnet_group.this.id
  engine               = var.engine
  ca_cert_identifier   = "rds-ca-2019"

  tags = {
    Name      = var.name
    Module    = path.module
    Workspace = terraform.workspace
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "this" {
  name        = "${var.name}-${random_id.this.hex}"
  description = "Security group for ${var.name}"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = local.database_port
    to_port     = local.database_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = var.name
    Module    = path.module
    Workspace = terraform.workspace
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_secretsmanager_secret" "this" {
  name = "${var.name}-${random_id.this.hex}"

  tags = {
    Name      = var.name
    Module    = path.module
    Workspace = terraform.workspace
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = jsonencode(local.credentials)

  lifecycle {
    create_before_destroy = true
  }
}
