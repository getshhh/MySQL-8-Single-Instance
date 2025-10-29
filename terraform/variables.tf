variable "mysql_root_password" {
  description = "MySQL root password"
  type        = string
  default     = "rootpassword"
  sensitive   = true
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "testuser"
}

variable "db_password" {
  description = "Database user password"
  type        = string
  default     = "testpassword"
  sensitive   = true
}

variable "database_name" {
  description = "Database name"
  type        = string
  default     = "test_database"
}

variable "mysql_data_volume" {
  description = "Path to MySQL data volume"
  type        = string
  default     = "./mysql_data"
}
