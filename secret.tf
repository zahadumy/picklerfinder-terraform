resource "aws_secretsmanager_secret" "booking_db_password" {
  name                    = "booking_db_secret"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "booking_db_password" {
  secret_id     = aws_secretsmanager_secret.booking_db_password.id
  secret_string = jsonencode({ username = local.db_username, password = local.db_pass })
}

resource "random_password" "password" {
  length           = 41
  special          = true
  override_special = "!#$%&'()*+,-.:;<=>?[\\]^_`{|}~"
}

locals {
  db_username = "admin"
  db_pass = random_password.password.result
}
