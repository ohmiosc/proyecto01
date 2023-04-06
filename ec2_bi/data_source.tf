data "aws_key_pair" "ec2_key" {
  key_name           = "AWS-VPC-${var.key}"
  include_public_key = true

  #  filter {
  #    name   = "key-pair-id"
  #    values = ["key-0215f3636e7ff4145"]
  #  }
}

data "aws_ami" "lastet" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["pagoefectivo-base-amazonlinux2-*"]
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

data "template_file" "test" {
  template = <<EOF
    #!/bin/bash
    stop ecs
    yum -y update && yum -y install vim telnet wget aws-cli
    yum remove -y java-17-amazon-corretto-headless java-17-amazon-corretto java-17-amazon-corretto-devel java-17-amazon-corretto-jmods
    yum install -y java-11-amazon-corretto
    sudo amazon-linux-extras install python3.8
    aws s3 cp s3://infraestructura.dev/install/pentaho/install/pdi-ce-9.3.0.0-428.zip /opt/pentaho/
    cd /opt/pentaho/
    unzip pdi-ce-9.3.0.0-428.zip
    rm -rf pdi-ce-9.3.0.0-428.zip
    aws s3 cp s3://infraestructura.dev/install/pentaho/install/pentaho /etc/init.d/
    chmod 755 /etc/init.d/pentaho
    mkdir /opt/pentaho/data-integration/logs/
    touch /opt/pentaho/data-integration/logs/log_carte.log
    systemctl enable pentaho
    systemctl start pentaho
  EOF
}
