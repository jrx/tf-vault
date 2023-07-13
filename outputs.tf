output "vault_public_ip" {
  value = aws_instance.vault.*.public_ip
}

output "vault_lb" {
  value = module.loadbalancer.vault_lb_dns_name
}

output "ca" {
  value     = tls_self_signed_cert.ca.cert_pem
  sensitive = true
}