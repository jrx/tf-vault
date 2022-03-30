module "loadbalancer" {
  source = "./modules/load_balancer"

  allowed_inbound_cidrs = null
  common_tags           = {}
  lb_certificate_arn    = null
  lb_health_check_path  = "/v1/sys/health?activecode=200&sealedcode=200&uninitcode=200&perfstandbyok=true"
  lb_subnets            = data.terraform_remote_state.vpc.outputs.aws_private_subnets
  lb_type               = "network"
  resource_name_prefix  = var.cluster_name
  ssl_policy            = "ELBSecurityPolicy-TLS-1-2-2017-01"
  vault_sg_id           = aws_security_group.default.id
  vpc_id                = data.terraform_remote_state.vpc.outputs.aws_vpc_id
}

resource "aws_lb_target_group_attachment" "test" {
  count            = var.num_vault
  target_group_arn = module.loadbalancer.vault_target_group_arn
  target_id        = element(aws_instance.vault.*.id, count.index)
  port             = 8200
}