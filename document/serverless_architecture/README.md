# サーバレスアーキテクチャ(serverless architecture)
  - [サーバーレスアーキテクチャという技術分野についての簡単な調査](http://qiita.com/zerobase/items/3bc0d15980b472af841d)

 サーバレスアーキテクチャとは、サービスやアプリケーションが動作する環境についてメンテナンスすべきサーバを配置しない構成のこと。既にAmazon API GatewayやAWS Lambdaなどユーザがサーバレスでサービスを提供するためのマネージドサービスが出てきており、更に[Serverless Framework](https://serverless.com/) のような、*Amazon API GatewayやAWS Lambdaなどの利用を前提としたサーバレスなアプリケーションサービスを構築するためのフレームワーク* も登場しています。

## 現状でのサーバレスアーキテクチャのベストプラクティス
  - Amazon API Gateway + AWS Lambda

## サーバレスアーキテクチャで実現したいこと
  - [ECS-optimized AMI](http://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/launch_container_instance.html) の更新(AMI IDの変更)を検知する
  - カスタムAMIのビルド
    - 構築用シェルスクリプトをS3などからダウンロード
    - packerバイナリや実行環境を固めたものをS3などからダウンロード
    - packerビルド

