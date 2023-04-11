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
  default_tags {
    tags = var.tags
  }
}

locals {
  sg = {
    ingress = "ingress"
    egress  = "egress"
  }
  protocol = {
    tcp       = "tcp"
    ssh_port  = 22
    http_port = 80
    HTTP      = "HTTP"
  }
  all_ips     = "0.0.0.0/0"
  main_subnet = element(var.public_subnets_data, 0)
}

resource "aws_key_pair" "ssh_key" {
  key_name   = var.ssh_key.name
  public_key = file(var.ssh_key.file_path)
  tags = {
    name = "ssh key"
  }
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

resource "aws_security_group_rule" "pub_enable_egress_ssh" {
  security_group_id = aws_security_group.public_ec2_sg.id
  description       = "enable internal egress ssh for public instance"
  type              = local.sg.egress
  protocol          = local.protocol.tcp
  from_port         = local.protocol.ssh_port
  to_port           = local.protocol.ssh_port
  cidr_blocks       = var.private_subnets_data[*].cidr
}

resource "aws_security_group_rule" "pub_enable_egress_http" {
  security_group_id = aws_security_group.public_ec2_sg.id
  description       = "enable internal egress http for public instance"
  type              = local.sg.egress
  protocol          = local.protocol.tcp
  from_port         = local.protocol.http_port
  to_port           = local.protocol.http_port
  cidr_blocks       = var.private_subnets_data[*].cidr
}

resource "aws_instance" "public_ec2" {
  ami                         = var.instance_spec.ami
  instance_type               = var.instance_spec.type
  key_name                    = aws_key_pair.ssh_key.key_name
  associate_public_ip_address = true
  subnet_id                   = local.main_subnet.id
  security_groups             = [aws_security_group.public_ec2_sg.id]
  tags = {
    name = "public instance"
  }
}


resource "aws_security_group" "private_ec2_sg" {
  vpc_id = var.vpc_id
}
// sg rule for private instance
resource "aws_security_group_rule" "prv_enable_ingress_ssh" {
  security_group_id = aws_security_group.private_ec2_sg.id
  description       = "enable internal ingress ssh connection for private instance"
  type              = local.sg.ingress
  protocol          = local.protocol.tcp
  from_port         = local.protocol.ssh_port
  to_port           = local.protocol.ssh_port
  cidr_blocks       = [local.main_subnet.cidr]
}

resource "aws_security_group_rule" "prv_enable_egress_http" {
  security_group_id = aws_security_group.private_ec2_sg.id
  description       = "enable egress http for private instance"
  type              = local.sg.egress
  protocol          = local.protocol.tcp
  from_port         = local.protocol.http_port
  to_port           = local.protocol.http_port
  cidr_blocks       = [local.all_ips]
}


resource "aws_security_group_rule" "prv_enable_ingress_http" {
  security_group_id = aws_security_group.private_ec2_sg.id
  description       = "enable ingress http for private instance"
  type              = local.sg.ingress
  protocol          = local.protocol.tcp
  from_port         = local.protocol.http_port
  to_port           = local.protocol.http_port
  cidr_blocks       = var.public_subnets_data[*].cidr
}


resource "aws_instance" "private_ec2s" {
  count           = length(var.private_subnets_data)
  ami             = var.instance_spec.ami
  instance_type   = var.instance_spec.type
  key_name        = aws_key_pair.ssh_key.key_name
  subnet_id       = element(var.private_subnets_data, count.index).id
  security_groups = [aws_security_group.private_ec2_sg.id]
  user_data       = templatefile("${path.module}/script.sh", { host : "${count.index + 1}" })
  tags = {
    name = "private instance ${count.index + 1}"
  }
}

resource "aws_lb_target_group" "app_lb_target_grp" {
  target_type = "instance"
  name        = "${var.name_prefix}-lb-target-group"
  protocol    = local.protocol.HTTP
  port        = local.protocol.http_port
  vpc_id      = var.vpc_id
  health_check {
    enabled = true
    path    = "/"
  }
}

resource "aws_lb_target_group_attachment" "app_lb_target_grp_attachments" {
  count            = length(aws_instance.private_ec2s)
  target_group_arn = aws_lb_target_group.app_lb_target_grp.arn
  target_id        = element(aws_instance.private_ec2s, count.index).id
  port             = local.protocol.http_port
}


resource "aws_security_group" "alb_security_group" {
  vpc_id = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = local.protocol.tcp
    cidr_blocks = [local.all_ips]
    description = "enable ingress ssh connection"
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = local.protocol.tcp
    cidr_blocks = var.private_subnets_data[*].cidr
    description = "enable egress ssh connection"
  }
}

resource "aws_lb" "app_lb" {
  name            = "${var.name_prefix}-app-lb"
  internal        = false
  ip_address_type = "ipv4"
  subnets         = var.public_subnets_data[*].id
  security_groups = [aws_security_group.alb_security_group.id]
}

resource "aws_lb_listener" "app_lb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  protocol          = local.protocol.HTTP
  port              = local.protocol.http_port
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_lb_target_grp.arn
  }
}
