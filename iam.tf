data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Vault

resource "aws_iam_role" "vault_kms_unseal_role" {
  name               = "${var.cluster_name}-vault-kms-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_instance_profile" "vault_profile" {
  name = "${var.cluster_name}-vault_profile"
  role = aws_iam_role.vault_kms_unseal_role.name
}

# Auto-unseal

data "aws_iam_policy_document" "vault-kms-unseal" {
  statement {
    sid       = "VaultKMSUnseal"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
      "ec2:DescribeInstances",
      "iam:GetRole",
    ]
  }
}

resource "aws_iam_policy" "vault-policy-kms-unseal" {
  name   = "${var.cluster_name}-vault-policy-kms-unseal"
  policy = data.aws_iam_policy_document.vault-kms-unseal.json
}

resource "aws_iam_policy_attachment" "vault-attach-kms" {
  name       = "${var.cluster_name}-vault-attach-kms"
  roles      = [aws_iam_role.vault_kms_unseal_role.id]
  policy_arn = aws_iam_policy.vault-policy-kms-unseal.arn
}

# Secrets Sync

data "aws_iam_policy_document" "vault-secrets-sync" {
  statement {
    sid       = "SecretsManagerAccess"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:CreateSecret",
      "secretsmanager:PutSecretValue",
      "secretsmanager:UpdateSecret",
      "secretsmanager:UpdateSecretVersionStage",
      "secretsmanager:DeleteSecret",
      "secretsmanager:RestoreSecret",
      "secretsmanager:TagResource",
      "secretsmanager:UntagResource"
    ]
  }
}

resource "aws_iam_policy" "vault-policy-secrets-sync" {
  name   = "${var.cluster_name}-vault-policy-secrets-sync"
  policy = data.aws_iam_policy_document.vault-secrets-sync.json
}

resource "aws_iam_policy_attachment" "vault-attach-secrets-sync" {
  name       = "${var.cluster_name}-vault-attach-secrets-sync"
  roles      = [aws_iam_role.vault_kms_unseal_role.id]
  policy_arn = aws_iam_policy.vault-policy-secrets-sync.arn
}