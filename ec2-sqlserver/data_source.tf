data "aws_key_pair" "ec2_key" {
  key_name           = "AWS-VPC-018"
  include_public_key = true

  filter {
    name   = "key-pair-id"
    values = ["key-0215f3636e7ff4145"]
  }
}

data "aws_ami" "lastet" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["pagoefectivo-windows-legacy-*"]
  }
}

data "aws_vpc" "selected" {
  tags = {
    Name = "${var.vpc_name}"
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  filter {
    name   = "availability-zone-id"
    values = ["euw1-az1"]
  }
  tags = {
    "paysafe:subnet-type" = "private-edge"
  }
}
data "template_file" "windows-userdata" {
  template = <<EOF
    <powershell>
    Set-TimeZone -Id "SA Pacific Standard Time"
    
    ###############
    # create user #
    ###############
    $NewPassword = ConvertTo-SecureString "Aa12345678909876543$" -AsPlainText -Force 
    New-LocalUser "dbadmin" -Password $NewPassword -FullName "DB Admin" -Description "User Admin DBA"
    Add-LocalGroupMember -Group "Administrators" -Member "dbadmin"
    
    Rename-Computer -NewName ${var.product}-${var.environment_prefix}-db-sqlserver-ec2 -Force
    </powershell>
    <persist>true</persist>
  EOF
}
