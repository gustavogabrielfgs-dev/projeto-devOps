
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

resource "docker_container" "web" {
  name  = "meu-container-web"
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = 8081
  }

  volumes {
    host_path      = "${path.cwd}/site"
    container_path = "/usr/share/nginx/html"
    read_only      = true
  }
}

resource "docker_image" "postgres" {
  name         = "postgres:16"
  keep_locally = false
}

resource "docker_volume" "db_data" {
  name = "projeto-devops-db-data"
}

resource "docker_container" "db" {
  name  = "meu-container-db"
  image = docker_image.postgres.image_id

  env = [
    "POSTGRES_PASSWORD=${var.postgres_password}"
  ]

  ports {
    internal = 5432
    external = 5432
  }

  volumes {
    volume_name    = docker_volume.db_data.name
    container_path = "/var/lib/postgresql/data"
  }
}