# ECS Services でALBを設定する
  - [Amazon ECSのELB構成パターンまとめ(ALB対応)](http://dev.classmethod.jp/cloud/ecs-elb-recipes/)
  

  [【新発表】AWS アプリケーションロードバランサー](https://aws.amazon.com/jp/blogs/news/new-aws-application-load-balancer/) でALB(Application Load Balancer) がリリースされました。ALBは単にアプリケーションレイヤーに対応したロードバランサーというだけでなく、ECSインスタンス上で稼動するDockerコンテナへのロードバランスにも対応しています。動的ポートマッピングにも対応しています。

  [ポートマッピング](http://docs.aws.amazon.com/ja_jp/AmazonECS/latest/APIReference/API_PortMapping.html) とは、`docker run` コマンドの `-p` オプションに相当するもので、ホストOS側のポートとDockerコンテナ内部のポートを割り当て(マッピング)ることが可能です。

## ALBを割り当てたECS Serviceを定義する
  - 先にALBを作成しておく必要がある

```sh
ELB_ARN=`aws elbv2 describe-load-balancers --names HelloWorld-LB-01 --query 'LoadBalancers[].LoadBalancerArn' --output text`

TASK_ARN=`aws ecs describe-task-definition --task-definition JavaTomcatDefinition3 --query 'taskDefinition.taskDefinitionArn'`

aws ecs create-service \
  --service-name 'HelloWorld-Service-01' \
  --task-definition ${TASK_ARN} \
  --desired-count 2 \
  --load-balancers=targetGroupArn=string,loadBalancerName=string,containerName=string,containerPort=integer
```

