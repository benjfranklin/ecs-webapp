resource "aws_ecr_repository" "repository" {
  name                 = "checkout"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

}

resource "null_resource" "docker_login" {
  provisioner "local-exec" {
    command     = "aws ecr get-login-password --region ${var.region} --no-verify-ssl | docker login --username AWS --password-stdin ${aws_ecr_repository.repository.repository_url}"
  }
}

resource "null_resource" "docker_build_push" {
  provisioner "local-exec" {
    command     = "./build.sh ./src ${var.image_name} ${aws_ecr_repository.repository.repository_url} ${var.image_tag}"
    interpreter = ["bash", "-c"]
  }

  depends_on = [null_resource.docker_login]
}

output "ecr_repository_url" {
  value = aws_ecr_repository.repository.repository_url
}

output "docker_image" {
  value = aws_ecr_repository.repository.repository_url
}

