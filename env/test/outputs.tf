output "dns_name" {
  description = "app lb dns"
  value = module.app.alb_dns
}

output "bastion_ip" {
  description = "bastion ip"
  value = module.app.public_instance_ip
}