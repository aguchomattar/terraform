output "dns_public_servidor_1" {
  description = "DNS publica del servidor"
  value = [for servidor in aws_instance.servidor : "http://${servidor.public_dns}:${var.puerto_servidor}"]
}


output "dns_load_balancer" {
  description = "DNS publica del load balancer"
  value       = "http://${aws_lb.alb.dns_name}:${var.puerto_lb}"
}

