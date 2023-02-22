resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_rds_cluster" "db_cluster_1" {
  cluster_identifier = "db-demo"

  engine                              = "aurora-mysql"
  engine_mode                         = "provisioned"
  engine_version                      = "8.0.mysql_aurora.3.02.0"
  database_name                       = "userdbdemo2"
  storage_encrypted                   = true
  skip_final_snapshot                 = true
  apply_immediately                   = true
  master_username                     = "admindb"
  deletion_protection                 = false
  master_password                     = random_password.password.result
  iam_database_authentication_enabled = true
  vpc_security_group_ids              = [aws_security_group.sg-default.id, ]
  #backup_retention_period    = 0
  db_subnet_group_name            = aws_db_subnet_group.subnetg-demo-1.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.default.name
  serverlessv2_scaling_configuration {
    max_capacity = 8.0
    min_capacity = 4.0
  }
}

resource "aws_rds_cluster_instance" "db_instance_1" {
  identifier                   = "${aws_rds_cluster.db_cluster_1.cluster_identifier}-1"
  cluster_identifier           = aws_rds_cluster.db_cluster_1.id
  instance_class               = "db.serverless"
  engine                       = aws_rds_cluster.db_cluster_1.engine
  engine_version               = aws_rds_cluster.db_cluster_1.engine_version
  db_parameter_group_name      = aws_db_parameter_group.default.name
  auto_minor_version_upgrade   = true
  availability_zone            = "eu-west-1a"
  performance_insights_enabled = true

  #monitoring_interval        = 5
}

## RDS CLUSTER##
resource "aws_db_subnet_group" "subnetg-demo-1" {
  name       = "${var.product}-${var.environment_prefix}-${var.project}-subg"
  subnet_ids = toset(data.aws_subnets.private.ids)
  tags = {
    Name = "subnetg-mysql-1"
  }
}
### PARAMETER GROUP ###
resource "aws_rds_cluster_parameter_group" "default" {
  name        = "${var.environment_prefix}-mysql-pg-cl"
  family      = "aurora-mysql8.0"
  description = "RDS default cluster parameter group"

  #parameter {
  #  name  = "log_statement"
  #  value = "all"
  #}
  #parameter {
  #  name  = "log_min_duration_statement"
  #  value = "1"
  #}
}

resource "aws_db_parameter_group" "default" {
  name   = "${var.environment_prefix}-mysql-pg-ins"
  family = "aurora-mysql8.0"
  parameter {
    name  = "max_connections"
    value = "LEAST({DBInstanceClassMemory/9531392},5000)"
  }
}

## SECRET ##
resource "aws_secretsmanager_secret" "db-pass" {
  name = "${var.product}-${var.environment_prefix}-${var.project}-secret"
  #kms_key_id              = data.aws_kms_alias.secret-m.name
  recovery_window_in_days = 0
}

# initial version
resource "aws_secretsmanager_secret_version" "db-pass-val" {
  secret_id = aws_secretsmanager_secret.db-pass.id
  # encode in the required format
  secret_string = jsonencode(
    {
      username = aws_rds_cluster.db_cluster_1.master_username
      password = aws_rds_cluster.db_cluster_1.master_password
      engine   = "aurora-mysql"
      host     = aws_rds_cluster.db_cluster_1.endpoint
    }
  )
}