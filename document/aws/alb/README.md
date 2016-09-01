# ALB(Application Load Balancer)
  - [【新発表】AWS アプリケーションロードバランサー](https://aws.amazon.com/jp/blogs/news/new-aws-application-load-balancer/)
  - [Application Load Balancer の詳細](https://aws.amazon.com/jp/elasticloadbalancing/applicationloadbalancer/)


## ALBとは

 L7のロードバランス機能を提供するフルマネージドサービスです。

## ALBとECS

### ECSのTaskDefinitionで動的ポートマッピングをサポート
  - 動的ポートマッピング(Dynamic Port Mapping)
  - ECSで作成するDockerコンテナのポートマッピングに関してホスト側のポートを動的に割り当ててくれる
  - 空きポートを勝手に割り当ててくれるのでAutoScalingや起動するタスク数を変えたい場合に便利
  - JSONで定義する場合、 `containerDefinitions` の `portMappings` で **hostPortを0**に設定する

 ```json
"portMappings": [
  {
    "containerPort": 80,
    "hostPort": 0,
    "protocol": "tcp"
  }
],
```

### ALBはECSの動的ポートマッピングに対応
  - ECS ClusterのService定義においてLoad Balancer設定がある
  - Service定義で作成済みALBを指定する
  - `ecs-service-scheduler` が `Elastic Load Balancing API(elasticloadbalancing.amazonaws.com)` に対してALBのターゲットグループ内のインスタンス情報の更新リクエストを送っているようです(CloudTrailのAPIアクティビティ監視から確認)

