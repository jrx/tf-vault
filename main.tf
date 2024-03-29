provider "aws" {
  region = var.aws_region
}

resource "aws_kms_key" "vault" {
  description             = "Vault unseal key"
  deletion_window_in_days = 10

  tags = {
    Name = "${var.cluster_name}-vault-key"
  }
}

resource "aws_instance" "vault" {
  ami                         = var.amis[var.aws_region]
  instance_type               = var.vault_instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.default.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.vault_profile.id
  count                       = var.num_vault

  availability_zone = data.terraform_remote_state.vpc.outputs.aws_azs[count.index % length(data.terraform_remote_state.vpc.outputs.aws_azs)]
  subnet_id         = data.terraform_remote_state.vpc.outputs.aws_public_subnets[count.index % length(data.terraform_remote_state.vpc.outputs.aws_azs)]

  tags = {
    Name  = "${var.cluster_name}-vault-${count.index}"
    Owner = var.owner
    # Keep = ""
    Vault = var.cluster_name
  }
}

resource "null_resource" "ansible" {
  count = var.num_vault

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/${var.instance_username}/ansible",
      "sudo yum -y install python3-pip",
      "sudo python3 -m pip install ansible --quiet",
    ]
  }

  provisioner "file" {
    source      = "./ansible/"
    destination = "/home/${var.instance_username}/ansible/"
  }

  provisioner "file" {
    content     = tls_locally_signed_cert.server.cert_pem
    destination = "/home/${var.instance_username}/ansible/files/vault.crt"
  }

  provisioner "file" {
    content     = tls_private_key.server.private_key_pem
    destination = "/home/${var.instance_username}/ansible/files/vault.key"
  }

  provisioner "file" {
    content     = tls_self_signed_cert.ca.cert_pem
    destination = "/home/${var.instance_username}/ansible/files/vault.ca"
  }

  provisioner "remote-exec" {
    inline = [
      "cd ansible; ansible-playbook -c local -i \"localhost,\" -e 'LB_ADDR=${module.loadbalancer.vault_lb_dns_name} ADDR=${element(aws_instance.vault.*.private_ip, count.index)} NODE_NAME=vault-s${count.index} VAULT_LICENSE=${var.vault_license} VAULT_VERSION=${var.vault_version} KMS_KEY=${aws_kms_key.vault.id} CLUSTER_NAME=${var.cluster_name} AWS_REGION=${var.aws_region} AWS_ZONE=${element(aws_instance.vault.*.availability_zone, count.index)}' vault-server.yml",
    ]
  }

  connection {
    host        = coalesce(element(aws_instance.vault.*.public_ip, count.index), element(aws_instance.vault.*.private_ip, count.index))
    type        = "ssh"
    user        = var.instance_username
    private_key = var.private_key
  }

  triggers = {
    always_run = timestamp()
  }
}