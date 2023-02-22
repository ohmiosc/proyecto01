resource "aws_secretsmanager_secret" "secret-bankinvoice" {
  name        = "vtex/pre/vtex-pre-fn-bankinvoice/credentials"
  description = "Secret fn bankinvoice / terraform"
}

resource "aws_secretsmanager_secret_version" "sv-bank" {
  secret_id     = aws_secretsmanager_secret.secret-bankinvoice.id
  secret_string = <<EOF
  {
      "DB_SERVER": "pre.sql-database.pe.local",
      "DB_DATABASE": "db_pagoefectivo_bankinvoice",
      "DB_PORT": "50789"
  }
EOF
}