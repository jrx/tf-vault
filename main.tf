provider "aws" {
  region = var.aws_region
}

terraform {
  required_version = ">= 0.12"
  backend "remote" {}
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

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/${var.instance_username}/ansible",
      "sudo yum -y install epel-release",
      "sudo yum -y install ansible",
    ]
  }

  provisioner "file" {
    source      = "./ansible/"
    destination = "/home/${var.instance_username}/ansible/"
  }

  provisioner "remote-exec" {
    inline = [
      "cd ansible; ansible-playbook -c local -i \"localhost,\" -e 'ADDR=${self.private_ip} NODE_NAME=vault-s${count.index} VAULT_VERSION=${var.vault_version} KMS_KEY=${aws_kms_key.vault.id} CLUSTER_NAME=${var.cluster_name} AWS_REGION=${var.aws_region}' vault-server.yml",
    ]
  }

  connection {
    host        = coalesce(self.public_ip, self.private_ip)
    type        = "ssh"
    user        = var.instance_username
    private_key = var.private_key
  }

  tags = {
    Name  = "${var.cluster_name}-vault-${count.index}"
    Owner = var.owner
    # Keep = ""
    Vault = var.cluster_name
  }
}

