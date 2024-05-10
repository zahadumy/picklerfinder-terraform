#################################################################################################
# This file describes the IAM resources: ECS task role, ECS execution role
#################################################################################################

resource "aws_iam_role" "ecsTaskExecutionRole" {
    name                  = "ecsTaskExecutionRole"
    assume_role_policy    = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions               = ["sts:AssumeRole"]

    principals {
      type                = "Service"
      identifiers         = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
    role                  = aws_iam_role.ecsTaskExecutionRole.name
    policy_arn            = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecsTaskRole" {
    name                  = "ecsTaskRole"
    assume_role_policy    = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "get_booking_db_password_secret" {
  statement {
    actions   = ["secretsmanager:DescribeSecret", "secretsmanager:GetSecretValue"]
    resources = [aws_secretsmanager_secret.booking_db_password.arn]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "get_booking_db_password_secret" {
  name        = "get-booking-db-password-secret-policy"
  policy      = data.aws_iam_policy_document.get_booking_db_password_secret.json
}

# required for the ECS task to read booking_db_password
resource "aws_iam_role_policy_attachment" "allow_ecsTaskRole_get_db_password_secret" {
  role       = aws_iam_role.ecsTaskRole.name
  policy_arn = aws_iam_policy.get_booking_db_password_secret.arn
}
