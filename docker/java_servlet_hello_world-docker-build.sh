#!/bin/bash
# 
# Name:
#   java_servlet_hello_world-docker-build.sh
# 
# Description:
#  Java Servlet Hello Worldアプリケーションが動作するdockerコンテナイメージをビルドする
#

# dockerコンテナイメージをビルド
docker build -t maehachi08/java-hello-world /tmp/docker

# ECRログイン
aws ecr get-login --region us-east-1 | sh
export AWS_DEFAULT_REGION='us-east-1'

# ECR用のタグ付け
docker tag maehachi08/java-hello-world:latest 375144106126.dkr.ecr.us-east-1.amazonaws.com/java_tomcat-hello_world:latest

# ECRへpush
docker push 375144106126.dkr.ecr.us-east-1.amazonaws.com/java_tomcat-hello_world:latest
