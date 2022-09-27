# terraform-user-mfa

* MFA認証が必要なAdministratorAccessのグループを作成するterraformテンプレートです。
* 自分のパスワード変更など、一部機能はMFA認証なしに行えるグループを作成します。
* 利用前にソースコードに目を通し、要件にあっているか確認した上で利用してください。

# 利用の流れ

* 管理担当者のAccessKeyをプロファイル付きでawscliに設定します。
* config.tfファイルを作成します。

config.tf

	locals {
	  aws_profile = "管理担当者プロファイル"
	}

* terraformを適用します。

実行例

	$ terraform init
	$ terraform plan
	$ terraform apply

# ユーザの追加

ユーザ追加作業はAWSコンソールから行います。AWS認証情報タイプは「パスワード - AWS マネジメントコンソールへのアクセス」を選択し、アクセスキーとMFAについてはユーザ自身で設定をおこなっていただきます。アクセス権限の項目でこちらで作成した admin グループに参加することで有効になります。

# ユーザへの説明

[AWS-SignIn.md](./AWS-SignIn.md)などの情報を提示してください。

