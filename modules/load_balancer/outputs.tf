output "vault_lb_arn" {
  description = "ARN of Vault load balancer"
  value       = aws_lb.vault_lb.arn
}

output "vault_lb_dns_name" {
  description = "DNS name of Vault load balancer"
  value       = aws_lb.vault_lb.dns_name
}

output "vault_lb_vpc_link" {
  description = "ID of the API Gateway VPC Link"
  value       = aws_api_gateway_vpc_link.vault_lb.id
}

output "vault_lb_sg_id" {
  description = "Security group ID of Vault load balancer"
  value       = var.lb_type == "application" ? aws_security_group.vault_lb[0].id : null
}

output "vault_lb_zone_id" {
  description = "Zone ID of Vault load balancer"
  value       = aws_lb.vault_lb.zone_id
}

output "vault_cluster_target_group_arn" {
  description = "Target group ARN to register Vault nodes with"
  value       = aws_lb_target_group.vault_cluster.arn
}

output "vault_api_target_group_arn" {
  description = "Target group ARN to register Vault nodes with"
  value       = aws_lb_target_group.vault_api.arn
}

output "vault_oidc_target_group_arn" {
  description = "Target group ARN to register Vault nodes with"
  value       = aws_lb_target_group.vault_oidc.arn
}