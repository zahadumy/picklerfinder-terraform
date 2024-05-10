resource "aws_db_instance" "booking-db" {
  allocated_storage = 10
  identifier        = "booking-db"
  db_name           = "booking"
  engine            = "mysql"
  engine_version    = "8.0.36"
  instance_class    = "db.t3.micro"
  username          = local.db_username
  password          = local.db_pass

  db_subnet_group_name = aws_db_subnet_group.db-private-subnet.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot  = true
  publicly_accessible  = false

  multi_az = true
}

resource "aws_db_subnet_group" "db-private-subnet" {
  name       = "db-private-subnet"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
}
