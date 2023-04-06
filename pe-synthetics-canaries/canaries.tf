data "aws_s3_bucket" "cw_canaries" {
  depends_on = [
    aws_s3_bucket.cw_canarys
  ]
  bucket = "cw-canaries-${data.aws_caller_identity.current.account_id}"
}
resource "aws_synthetics_canary" "some" {
    depends_on = [
    aws_iam_role.cw-canary-role
  ]
  name                 = "pe-ms-cip"
  artifact_s3_location = "s3://${data.aws_s3_bucket.cw_canaries.id}/"
  execution_role_arn   = "${aws_iam_role.cw-canary-role.arn}"
  handler              = "pageLoadBlueprint.handler"
  zip_file             = "pe_ms_cipv2.zip"
  runtime_version      = "syn-nodejs-puppeteer-3.9"
  #source_location_arn = "arn:aws:lambda:eu-west-1:929226109038:layer:cwsyn-some-canary-407d2c5f-fd69-4e72-9280-cde2d25514f4:1"
  start_canary         = "true"
  schedule {
    expression = "rate(1 minute)"
  }
}