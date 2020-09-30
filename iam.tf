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
  name               = "vault-kms-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

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
    ]
  }
}

resource "aws_iam_policy" "vault-policy" {
  name   = "vault-policy"
  policy = data.aws_iam_policy_document.vault-kms-unseal.json
}

resource "aws_iam_policy_attachment" "vault-attach" {
  name       = "vault-attach"
  roles      = ["${aws_iam_role.vault_kms_unseal_role.id}"]
  policy_arn = aws_iam_policy.vault-policy.arn
}

resource "aws_iam_instance_profile" "vault_profile" {
  name = "vault_profile"
  role = aws_iam_role.vault_kms_unseal_role.name
}