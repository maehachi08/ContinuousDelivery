# Amazon EC2 Container Service (ECS)

 コンテナ管理サービスです。Dockerエンジンが動作するEC2インスタンスにてDockerコンテナをスケーラブルに配置・管理することが可能です。

## ECSを取り巻くエンティティ

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


## 初期構築フロー

```
　■ ECSコンテナインスタンスの構築
　　① ECS-optimized AMIを選択する
　　  - Dockerエンジン、およびecs-agentコンテナがインストール済み
　　  - http://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/ecs-optimized_AMI.html
　　
　　② ECSコンテナインスタンス用のIAMロールを作成する
　　  - 作成するIAMロール名は「ecsInstanceRole」が通例(公式docより)
　　  - AmazonEC2ContainerServiceforEC2Role を内包する
　　  - 他にも必要(S3とか)
　　
　　③ セキュリティグループを作成する
　　  - インバインドで開放するポートの洗い出し
　　  - 80/443くらい?
　　
　　④ ECSコンテナインスタンスに適用するプロファイルを作成する
　　  - 前述の「ecsInstanceRole」ロール
　　
　　⑤ ECSコンテナインスタンス用のユーザデータを作成する
　　  - ECSクラスタ設定(/etc/ecs/ecs.config)
　　  - wgetコマンドのインストール(CodeDeployに使わないなら不要かも)
　　  - aws-cli,rubyのインストール(CodeDeployに使わないなら不要かも)
　　  - jqのインストール(CodeDeployに使わないなら不要かも)
```

