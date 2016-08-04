# Amazon EC2 Container Service (ECS)

ECSはEC2インスタンス上にDockerコンテナをクラスタ構成で稼働させることができるフルマネージドサービスです。コンテナエンジン

## ECSを取り巻くエンティティ
  - サービスとタスクは排他定義?
  - サービスは

### サービス

複数個のDcokerコンテナの集合を指す。

ここで表現する複数個とは、異なるプロセスを起動しているDockerコンテナである。
例えば、apacheコンテナとtomcatコンテナの2つのDcokerコンテナで構成する**「Front Service」** のようなものである。


### タスク
  - refs [Task Definition Parameters](http://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/task_definition_parameters.html)

複数のコンテナ定義を持つ。
  - コンテナ定義はコンテナに使用するDcokerマシンイメージやコンテナリソースについて定義する

## 参考サイト
  - [Amazon ECS(EC2 Container Service)についての簡単なメモ](http://qiita.com/mokemokechicken/items/d45144dcd1979c10e336)
  - [Amazon EC2 Container Service (ECS)を試してみた](http://dev.classmethod.jp/cloud/ecs-ataglance/) 
    - [AWS チュートリアル](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_GetStarted.html) を実施
  - [Amazon EC2 Container Service(ECS)の概念整理](http://qiita.com/NewGyu/items/9597ed2eda763bd504d7)
  - [EC2 Container Serviceを使ってみる](http://qiita.com/con_mame/items/1df441d86c703a0e6fa6)
  - [Amazon ECR + ECS CLI ハンズオン](http://qiita.com/zakky/items/be1e1a20cf7718ffae73)
  - [Amazon ECS に途中で挫折しないために](http://orih.io/2015/12/a-few-things-i-wanted-to-know-before-playing-with-amazon-ecs/)
  - [Amazon EC2 Container Serviceで構築されたシステムでDockerコンテナを入れ替える](http://dev.classmethod.jp/cloud/aws/switch-docker-container-using-ecs/)
  - [GA&東京に来たAmazon EC2 Container Service(ECS)を触ってみた](http://dev.classmethod.jp/cloud/ecs-ga-ataglance/)

