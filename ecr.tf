##############################################################
# This file describes the ECR resources: ECR repo, ECR policy
##############################################################

#Creation of the ECR repo
resource "aws_ecr_repository" "booking_ecr" {
    name                            = "booking-repo"
    force_delete = true
}

#The ECR policy describes the management of images in the repo
resource "aws_ecr_lifecycle_policy" "ecr_policy" {
    repository                      = aws_ecr_repository.booking_ecr.name
    policy                          = local.ecr_policy
}

#This is the policy defining the rules for images in the repo
locals {
  ecr_policy = jsonencode({
        "rules":[
            {
                "rulePriority"      : 1,
                "description"       : "Expire images older than 14 days",
                "selection": {
                    "tagStatus"     : "any",
                    "countType"     : "sinceImagePushed",
                    "countUnit"     : "days",
                    "countNumber"   : 14
                },
                "action": {
                    "type"          : "expire"
                }
            }
        ]
    })
}
