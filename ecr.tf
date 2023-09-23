resource "aws_ecr_repository" "ecr" {
    name = "my-test-repo"
}

resource "aws_ecr_lifecycle_policy" "ecr_policy" {
    repository = aws_ecr_repository.ecr.name

    policy = <<EOF
    {
        "rules":[
            {
                "rulePriority": 1,
                "description": "Expire images older than 14 days",
                "selection": {
                    "tagStatus": "any",
                    "countType": "sinceImagePushed",
                    "countUnit": "days",
                    "countNumber": 14
                },
                "action": {
                    "type": "expire"
                }
            }
        ]
    }
    EOF
}

resource "null_resource" "docker_login" {
    provisioner "local-exec" {
        command = <<EOF
        aws ecr get-login-password --region ${var.region} --profile personal| docker login --username AWS --password-stdin ${local.account_id}.dkr.ecr.${var.region}.amazonaws.com
        EOF
    }
    triggers = {
        "run_at" = timestamp()
    }
    depends_on = [ aws_ecr_repository.ecr ]
}
resource "null_resource" "docker_build" {
    provisioner "local-exec" {
        command = <<EOF
        docker build -t ${aws_ecr_repository.ecr.name} ./app
        EOF
    }
    triggers = {
        "run_at" = timestamp()
    }
    depends_on = [ null_resource.docker_login ]
}

resource "null_resource" "docker_tag" {
    provisioner "local-exec" {
        command = <<EOF
        docker tag ${aws_ecr_repository.ecr.name}:latest ${local.account_id}.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.ecr.name}:latest
        EOF
    }
    triggers = {
        "run_at" = timestamp()
    }
    depends_on = [ null_resource.docker_build ]
}

resource "null_resource" "docker_push" {
    provisioner "local-exec" {
        command = <<EOF
        docker push ${local.account_id}.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.ecr.name}:latest
        EOF
    }
    triggers = {
        "run_at" = timestamp()
    }
    depends_on = [ null_resource.docker_tag ]
}
