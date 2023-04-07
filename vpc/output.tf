output "public_ip" {
  value       = aws_instance.ec2.public_ip
  description = "ec2 public ip"
}