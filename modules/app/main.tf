terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.59.0"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  sg = {
    ingress = "ingress"
    egress  = "egress"
  }
  protocol = {
    tcp      = "tcp"
    icmp     = "icmp"
    ssh_port = 22
  }
  all_ips = "0.0.0.0/0"
}

resource "aws_key_pair" "ssh_key" {
  key_name   = var.ssh_key.name
  public_key = file(var.ssh_key.file_path)
  tags       = merge(var.tags, { name = "ssh key" })
}

resource "aws_security_group" "public_ec2_sg" {
  vpc_id = var.vpc_id
}
// sg rule for public instance
resource "aws_security_group_rule" "pub_enable_ingress_ssh" {
  security_group_id = aws_security_group.public_ec2_sg.id
  description       = "enable ingress ssh connection for public instance"
  type              = local.sg.ingress
  protocol          = local.protocol.tcp
  from_port         = local.protocol.ssh_port
  to_port           = local.protocol.ssh_port
  cidr_blocks       = [local.all_ips]
}

resource "aws_security_group_rule" "pub_enable_ingress_ping" {
  security_group_id = aws_security_group.public_ec2_sg.id
  description       = "enable ingress ssh for public instance"
  type              = local.sg.ingress
  protocol          = local.protocol.icmp
  from_port         = 8
  to_port           = 0
  cidr_blocks       = [local.all_ips]
}

resource "aws_instance" "public_ec2" {
  ami                         = var.instance_spec.ami
  instance_type               = var.instance_spec.type
  key_name                    = aws_key_pair.ssh_key.key_name
  associate_public_ip_address = true
  subnet_id                   = var.public_subnet_id
  security_groups             = [aws_security_group.public_ec2_sg.id]
  tags                        = merge(var.tags, { name = "public instance" })
}

# resource "aws_instance" "private_ec2s" {
#   count         = length(var.private_subnet_ids)
#   ami           = var.instance_spec.ami
#   instance_type = var.instance_spec.type
#   key_name      = aws_key_pair.ssh_key.key_name
#   subnet_id     = element(var.private_subnet_ids, count.index)
#   tags          = merge(var.tags, { name = "private instance ${count.index + 1}" })
#   user_data     = templatefile("$path.module/script.sh", { host : "${count.index + 1}" })
# }
