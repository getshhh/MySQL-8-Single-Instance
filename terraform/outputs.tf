output "mysql_host" {
  description = "MySQL host"
  value       = "localhost"
}

output "mysql_port" {
  description = "MySQL port"
  value       = 3306
}

output "mysql_database" {
  description = "Database name"
  value       = var.database_name
}

output "mysql_username" {
  description = "Database username"
  value       = var.db_username
}

output "mysql_password" {
  description = "Database password"
  value       = var.db_password
  sensitive   = true
}

output "mysql_connection_string" {
  description = "MySQL connection string"
  value       = "mysql://${var.db_username}:${var.db_password}@localhost:3306/${var.database_name}"
  sensitive   = true
}

output "connection_command" {
  description = "Command to connect to MySQL"
  value       = "mysql -h localhost -u ${var.db_username} -p${var.db_password} ${var.database_name}"
  sensitive   = true
}

