data "aws_key_pair" "ec2_key" {
  key_name           = "AWS-VPC-031"
  include_public_key = true

  filter {
    name   = "key-pair-id"
    values = ["key-08705f2ccb0ef7430"]
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

data "aws_alb" "alb_internal" {
  name = var.use_alb
}
data "aws_lb_listener" "alb_https_arn" {
  load_balancer_arn = data.aws_alb.alb_internal.arn
  port = 443
}

data "template_file" "windows-userdata" {
  template = <<EOF
  <powershell>
  # Rename Machine
  #Rename-Computer -NewName var.windows_instance_name}" -Force;
  # Install IIS
  Install-WindowsFeature Web-Server,Web-Net-Ext45,Web-Asp-Net45,Web-ISAPI-Filter,Web-ISAPI-Ext -IncludeManagementTools
  # Copia directorio
  aws s3 sync s3://infraestructura.prod/install/nuget-server/nuget.server.packages C:\apps\nuget.server.packages
  #Start-Sleep -Seconds 5
  # Config IIS
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
  New-Item -ItemType Directory -Name 'nuget.server.orbis.pe' -Path 'C:\apps\nuget.server.orbis.pe'
  New-WebSite -Name "nuget.server.orbis.pe" -Port 80 -HostHeader "nuget.server.orbis.pe" -PhysicalPath "C:\apps\nuget.server.orbis.pe"
  Start-WebSite -Name nuget.server.orbis.pe
  # Copia directorio
  aws s3 sync s3://infraestructura.prod/install/nuget-server/nugetserver/ C:\apps\nuget.server.orbis.pe
  #Start-Sleep -Seconds 10
  # Restart machine
  shutdown -r -t 10;
  </powershell>
  EOF
}