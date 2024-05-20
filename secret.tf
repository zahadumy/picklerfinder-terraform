resource "aws_secretsmanager_secret" "booking_db_details" {
  name                    = "booking_db_details_secret"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "booking_db_details" {
  secret_id     = aws_secretsmanager_secret.booking_db_details.id
  secret_string = jsonencode({
    db_endpoint = aws_db_instance.booking-db.endpoint,
    username    = local.db_username,
    password    = local.db_pass
  })
}

resource "random_string" "username" {
  length  = 16
  special = false
}

resource "random_password" "password" {
  length           = 41
  special          = true
  override_special = "!#$%&'()*+,-.:;<=>?[\\]^_`{|}~"
}

locals {
  db_username = random_string.username.result
  db_pass = random_password.password.result
}
