resource "aws_secretsmanager_secret" "secret-asyncapproved" {
  name        = "vtex/pre/vtex-pre-fn-asyncapproved/credentials"
  description = "Secret fn asyncapproved / terraform"
}

resource "aws_secretsmanager_secret_version" "sv-asyn" {
  secret_id     = aws_secretsmanager_secret.secret-asyncapproved.id
  secret_string = <<EOF
  {
      "DB_SERVER": "pre.sql-database.pe.local",
      "DB_DATABASE": "db_pagoefectivo_asyncapproved",
      "DB_PORT": "50789"
  }
EOF
}