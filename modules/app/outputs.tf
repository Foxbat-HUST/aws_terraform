output "public_instance_ip" {
  description = "public instance ip address"
  value       = aws_instance.public_ec2.public_ip
}

output "public_instance_sg_id" {
  description = "public instance security group id"
  value       = aws_security_group.public_ec2_sg.id
}
