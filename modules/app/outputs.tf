output "public_instance_ip" {
  description = "public instance ip address"
  value       = aws_instance.public_ec2.public_ip
}

output "public_instance_sg_id" {
  description = "public instance security group id"
  value       = aws_security_group.public_ec2_sg.id
}

output "alb_dns" {
  description = "load balancer dns"
  value = aws_lb.app_lb.dns_name
}
