terraform {
  experiments = [variable_validation]
}

variable "name" {
  type        = string
  description = "Name that will be used in resources names and tags."
  default     = "terraform-aws-rds-aurora-cluster"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC."
}

variable "vpc_subnets" {
  type        = list(string)
  description = "A list of VPC subnet IDs."
}

variable "vpc_cidr_block" {
  type        = string
  description = " The VPC CIDR IP range for security group ingress rule for access to AWS RDS cluster."

  validation {
    condition     = can(regex("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/(0|[1-9]|1[0-9]|2[0-9]|3[0-2]))$", var.vpc_cidr_block))
    error_message = "CIDR parameter must be in the form x.x.x.x/0-32."
  }
}

variable "engine" {
  type        = string
  description = "The name of the database engine to be used for this DB cluster. Valid Values: `aurora`, `aurora-mysql`, `aurora-postgresql`."
  default     = "aurora"

  validation {
    condition     = contains(["aurora", "aurora-mysql", "aurora-postgresql"], var.engine)
    error_message = "Must be a valid Aurora RDS engine."
  }
}

variable "storage_encrypted" {
  type        = bool
  description = "Specifies whether the DB cluster is encrypted."
  default     = false
}

variable "instance_class" {
  type        = string
  description = "The Amazon RDS database instance class."
  default     = "db.t3.small"

  validation {
    condition     = contains(["db.t3.small", "db.t3.medium", "db.t3.large", "db.t3.xlarge", "db.t3.2xlarge", "db.m5.large", "db.m5.xlarge", "db.m5.2xlarge", "db.m5.4xlarge", "db.m5.12xlarge", "db.m5.24xlarge"], var.instance_class)
    error_message = "Must be a valid RDS instance class."
  }
}

variable "master_username" {
  type        = string
  description = "Username for the master DB user."
  default     = "username"

  validation {
    condition     = can(regex("^([a-zA-Z0-9]*)$", var.master_username)) && length(var.master_username) >= 8 && length(var.master_username) <= 16
    error_message = "Must contain only alphanumeric characters (minimum 8; maximum 16)."
  }
}

variable "master_password" {
  type        = string
  description = "Password for the master DB user."
  default     = "password"

  validation {
    condition     = can(regex("^([a-z0-9A-Z`~!#$%^&*()_+,\\-])*$", var.master_password)) && length(var.master_password) >= 8 && length(var.master_password) <= 41
    error_message = "Must be letters (upper or lower), numbers, and these special characters '_'`~!#$%^&*()_+,-."
  }
}

variable "database_name" {
  type        = string
  description = "Name for an automatically created database on cluster creation."
  default     = "database"

  validation {
    condition     = can(regex("^([a-zA-Z0-9]*)$", var.database_name))
    error_message = "Must contain only alphanumeric characters."
  }
}

variable "snapshot_identifier" {
  type        = string
  description = "Specifies whether or not to create this cluster from a snapshot."
  default     = null
}
