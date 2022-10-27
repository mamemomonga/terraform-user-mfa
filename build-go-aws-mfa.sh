#!/bin/bash
set -eu

case "$(uname -s)" in
	"Darwin" ) GOOS=darwin ;;
	"Linux" ) GOOS=linux ;;
	* ) echo "Unknown OS"; exit 1;;
esac

case "$(uname -m)" in
	"x86_64" ) GOARCH=amd64 ;;
	"aarch64" ) GOARCH=arm64 ;;
	"arm64" ) GOARCH=arm64 ;;
	* ) echo "Unknown Arch"; exit 1 ;;
esac

echo "OS: $GOOS / ARCH: $GOARCH"

CURDIR=$(pwd)
WORKDIR=$(mktemp -d)
echo "WorkDir: $WORKDIR"

set +x
cd $WORKDIR
git clone https://github.com/jdevelop/go-aws-mfa.git go-aws-mfa
cd go-aws-mfa
docker run -d --name awsmfa golang:1.19.1-alpine3.16 sh -c 'while true; do sleep 10; done'
docker exec awsmfa mkdir -p /app
docker cp . awsmfa:/app/src
docker exec -w /app/src -e GOOS=$GOOS -e GOARCH=$GOARCH awsmfa go build -o ../aws-mfa .
docker cp awsmfa:/app/aws-mfa .
docker rm -f awsmfa
cp aws-mfa $CURDIR/
rm -rf $WORKDIR
set -x
