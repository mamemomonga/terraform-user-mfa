# AWSコンソール / AWS-CLIの設定について
## AWSコンソールにサインインするための手順

事前にスマートフォンなどに「Google Authenticator([iOS](https://apps.apple.com/jp/app/google-authenticator/id388497605) / [Android](https://play.google.com/store/apps/details?id=com.google.android.apps.authenticator2&hl=ja&gl=US))」などの多段認証ツールを導入してください。

[Bitwarden](https://go.bitwarden.com/jp/password-management-for-business-teams-organizations/) Premiumでも利用可能ですが、ここではGoogle Authenticatorを例に説明します。

1. ご連絡させていただいた情報でサインインしてください
2. サインイン後にパスワードの変更を求められますので、任意のパスワードに変更してください。
3. 右上のユーザ名のあるプルダウンから、「セキュリティー認証情報」を選択してください。
4. 多要素認証（MFA）の「MFAデバイスの割り当て」を押して下さい。
5. 「仮想MFAデバイス」→「QRコードの表示」を押して下さい。
6. Google Authenticatorを起動し、＋を押してQRコードをスキャンしてください。
7. MFAコードが登録されますので、2回続けてMFAコードを入力します。
8. 登録が完了したら、右上のユーザ名のあるプルダウンから、「サインアウト」を行います。
9. 再度サインインを行って、サインインできることを確認してください。

## アクセスキーペアの取得方法

1. AWSコンソールにサインインしてください。
2. 右上のユーザ名のあるプルダウンから、「セキュリティー認証情報」を選択してください。
3. 「アクセスキーの作成」を押して下さい。
4. アクセスキーIDとシークレットアクセスキーをメモしてください。

## AWSCLIのインストールと初期設定

[こちらのサイト](https://aws.amazon.com/jp/cli/)を参考にして、awscliを導入してください。

初期設定

プロファイル付きで設定を行います。以下を参考に設定してください。
プロファイル名は任意に決めて下さい。おすすめはアカウントエイリアス名です。
ここではexampleとしてあります。

	$ aws configure --profile=example
	AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
	AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
	Default region name [None]: ap-northeast-1
	Default output format [None]:

プロファイル付きで設定した場合、環境変数を設定することで、そのプロファイルが利用できるようになります。

	$ export AWS_DEFAULT_PROFILE=example

以下のコマンドが実行できれば、設定できています。

	$ aws sts get-caller-identity
	{
	    "UserId": "AKIAIOSFODNN7EXAMPLE",
	    "Account": "123456789012",
	    "Arn": "arn:aws:iam::123456789012:user/userid"
	}

## アクセスキーを用いたMFA認証の実行

アクセスキーを使用した場合でも、MFAの認証が必要になります。 現在のアクセスキーを利用してMFA認証を行い、それが有効なセッションのアクセスキーを発行されるので、それを利用するという仕組みになります。 手作業で行うととても煩雑ですが、 [go-aws-mfa](https://github.com/jdevelop/go-aws-mfa)などのツールを使うことで比較的簡単に利用できるようになります。

### バイナリのビルド

以下はDockerを使ったIntel man向けビルド例です。Golangの導入は不要ですが、Dockerの導入が必要です。

	$ git clone https://github.com/jdevelop/go-aws-mfa.git
	$ cd go-aws-mfa
	$ docker run -d --name awsmfa golang:1.19.1-alpine3.16 sh -c 'while true; do sleep 10; done'
	$ docker exec awsmfa mkdir -p /app
	$ docker cp . awsmfa:/app/src
	$ docker exec -w /app/src -e GOOS=darwin -e GOARCH=amd64 awsmfa go build -o ../aws-mfa .
	$ docker cp awsmfa:/app/aws-mfa .
	$ docker rm -f awsmfa

`-e GOOS=darwin -e GOARCH=amd64` の部分を `-e GOOS=windoiws -e GOARCH=amd64` や `-e GOOS=linux -e GOARCH=arm64` などにするとそれぞれのOS(GOOS)やアーキテクチャ(GOARCH_に向けたバイナリをビルドできます。OSとアーキテクチャのリストはこのコマンドで参照できます(「GOOS/GOARCH]の形になっています)。 -jsonを付けるとJSONで出力されます。

	$ docker run --rm golang:1.19.1-alpine3.16 go tool dist list

ビルドが完了するとカレントフォルダに aws-mfa というバイナリができますので、それをパスの通った任意の場所にコピーしてください。

docker run --rm golang:1.19.1-alpine3.16 go tool dist list

### 利用例 

「MFA後のプロファイル」には「MFA前のプロファイル_mfa」など、_mfaをつけたものにするとわかりやすいです。

	$ aws-mfa -s MFA前のプロファイル -d MFA後のプロファイル

これで

	$ export AWS_DEFAULT_PROFILE=MFA後のプロファイル
	
とすると、MFA有効のawscliが利用できるようになります。

	$ aws s3 ls

などを実行して Access Denied がでなければ成功です。
