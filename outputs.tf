output "dns_public_servidor_1" {
  description = "DNS publica del servidor"
  value       = "http://${aws_instance.servidor_1.public_dns}:${var.puerto_servidor}"
}

output "dns_public_servidor_2" {
  description = "DNS publica del servidor"
  value       = "http://${aws_instance.servidor_2.public_dns}:${var.puerto_servidor}"
}

output "dns_load_balancer" {
  description = "DNS publica del load balancer"
  value       = "http://${aws_lb.alb.dns_name}:${var.puerto_lb}"
}

