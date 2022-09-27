# AWSプロバイダ
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.32.0"
    }
  }
  required_version = ">= 1.1.6"
}

# AWS 東京
provider "aws" {
  region  = "ap-northeast-1"
  profile = local.aws_profile
}

# Adminグループの作成
resource "aws_iam_group" "admin" {
	name = "admin"
	path = "/users/"
}

# AdminグループにAdministratorAccessポリシーをアタッチ
resource "aws_iam_group_policy_attachment" "administratorAccess" {
	group = aws_iam_group.admin.name
	policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# AdminグループにUserMFAポリシーをアタッチ
resource "aws_iam_group_policy_attachment" "userMFA" {
	group      = aws_iam_group.admin.name
	policy_arn = aws_iam_policy.usermfa.arn
}
