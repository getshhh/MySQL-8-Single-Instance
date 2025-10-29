terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
  
  required_version = ">= 1.0"
}

provider "docker" {}

resource "docker_image" "mysql" {
  name         = "mysql:8.0"
  keep_locally = true
}

resource "docker_container" "mysql" {
  name  = "mysql_single_instance"
  image = docker_image.mysql.image_id

  ports {
    internal = 3306
    external = 3306
  }

  env = [
    "MYSQL_ROOT_PASSWORD=${var.mysql_root_password}",
    "MYSQL_DATABASE=${var.database_name}",
    "MYSQL_USER=${var.db_username}",
    "MYSQL_PASSWORD=${var.db_password}",
  ]

  command = [
    "--default-authentication-plugin=mysql_native_password",
    "--character-set-server=utf8mb4",
    "--collation-server=utf8mb4_unicode_ci",
    "--max-allowed-packet=67108864"
  ]

  volumes {
    host_path      = var.mysql_data_volume
    container_path = "/var/lib/mysql"
  }

  restart_policy = "unless-stopped"

  healthcheck {
    test     = ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "root", "-p${var.mysql_root_password}"]
    interval = "10s"
    timeout  = "5s"
    retries  = 10
  }
}


resource "time_sleep" "wait_for_mysql" {
  depends_on      = [docker_container.mysql]
  create_duration = "30s"
}

resource "docker_image" "generator" {
  name         = "mysql_generator:latest"
  keep_locally = true

  build {
    context    = "${path.module}/.."
    dockerfile = "Dockerfile"
  }

  depends_on = [docker_container.mysql]
}


resource "docker_container" "generator" {
  name  = "mysql_data_generator"
  image = docker_image.generator.id

  env = [
    "MYSQL_HOST=localhost",
    "MYSQL_USER=${var.db_username}",
    "MYSQL_PASSWORD=${var.db_password}",
    "MYSQL_DATABASE=${var.database_name}",
    "MYSQL_PORT=3306",
  ]

  network_mode = "host"

  depends_on = [
    docker_container.mysql,
    time_sleep.wait_for_mysql
  ]

  restart_policy = "no"
}
