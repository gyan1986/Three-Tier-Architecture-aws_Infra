resource "aws_db_subnet_group" "public" {
  name       = "rds_subnet_group"
  subnet_ids = [aws_subnet.private01.id, aws_subnet.private02.id]
  tags = {
    Name = "My Private DB subnet group"
  }
}

resource "aws_db_instance" "rds01" {
  depends_on             = [aws_db_subnet_group.public]
  instance_class         = "db.t2.micro"
  allocated_storage      = 10
  availability_zone      = "ap-south-1a"
  engine                 = "mysql"
  engine_version         = "5.7"
  db_name                = "mydb"
  username               = "admin"
  password               = random_password.rds_password.result
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.public.name
  port                   = 3306
  vpc_security_group_ids = [aws_security_group.db.id]
}

resource "random_password" "rds_password" {
  length           = 16
  special          = true
  override_special = "_@$"
}

resource "aws_secretsmanager_secret" "rds" {
  name_prefix = "rds01_"
}

resource "aws_secretsmanager_secret_version" "rds" {
  secret_id = aws_secretsmanager_secret.rds.id
  secret_string = jsonencode({
    username = "admin",
    password = random_password.rds_password.result,
    endpoint = replace(aws_db_instance.rds01.endpoint, ":${aws_db_instance.rds01.port}", "")
  })
}

data "aws_secretsmanager_secret_version" "rds" {
  secret_id = aws_secretsmanager_secret.rds.id
  depends_on = [
    aws_db_instance.rds01,
    aws_secretsmanager_secret.rds,
    aws_secretsmanager_secret_version.rds
  ]
}