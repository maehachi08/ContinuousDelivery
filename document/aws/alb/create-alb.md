# ALB(ターゲットグループ) の作成手順
  - `aws elbv2` コマンドを使用する
    - http://docs.aws.amazon.com/cli/latest/reference/elbv2/index.html

## ALB作成

### ALB作成に必要な情報を整理する

  1. ロードバランサー名
  1. リージョン、およびVPC
    - ALBはVPC単位で動作する
    - `aws elbv2 create-load-balancer`では不要だがサブネットを決める際に重要
  1. サブネット
    - 分散が前提なので2つ以上
  1. セキュリティグループ
    - HTTP通信用のロードバランサーであればTCP/80が開放されているセキュリティグループ

### ALB作成

 ```sh
ELB_NAME="HelloWorld-LB-01"
SUBNET_ID1="subnet-9a686db0"
SUBNET_ID2="subnet-eacbc0d7"
SG_ID="sg-c029c6ba"

ELB_ARN=`aws elbv2 create-load-balancer --name ${ELB_NAME} \
 --subnets ${SUBNET_ID1} ${SUBNET_ID2} --security-groups ${SG_ID} \
 --query LoadBalancers[].LoadBalancerArn --output text `

aws elbv2 describe-load-balancers --load-balancer-arns ${ELB_ARN}
```

 `aws elbv2 describe-load-balancers` コマンド結果は以下のとおり。

 ```json
{
    "LoadBalancers": [
        {
            "VpcId": "vpc-0f8dec68",
            "LoadBalancerArn": "arn:aws:elasticloadbalancing:us-east-1:375144106126:loadbalancer/app/HelloWorld-LB-01/a034310016248e53",
            "State": {
                "Code": "provisioning"
            },
            "DNSName": "HelloWorld-LB-01-780673163.us-east-1.elb.amazonaws.com",
            "SecurityGroups": [
                "sg-c029c6ba"
            ],
            "LoadBalancerName": "HelloWorld-LB-01",
            "CreatedTime": "2016-08-30T02:35:55.620Z",
            "Scheme": "internet-facing",
            "Type": "application",
            "CanonicalHostedZoneId": "Z35SXDOTRQ7X7K",
            "AvailabilityZones": [
                {
                    "SubnetId": "subnet-9a686db0",
                    "ZoneName": "us-east-1d"
                },
                {
                    "SubnetId": "subnet-eacbc0d7",
                    "ZoneName": "us-east-1e"
                }
            ]
        }
    ]
}
```

### ターゲットグループ作成
  - ALBのロードバランス先のインスタンスとポートを定義する
  - 振り分け先のヘルスチェック設定(任意)
  - プロトコルは `HTTP` か `HTTPS` を選択

 ```sh
TARGET_ARN=`aws elbv2 create-target-group --name HelloWorld-LB-TARGET-01 \
  --protocol HTTP --port 80 --vpc-id vpc-0f8dec68 \
  --query TargetGroups[].TargetGroupArn --output text`

aws elbv2 describe-target-groups --target-group-arn ${TARGET_ARN}
aws elbv2 describe-target-group-attributes --target-group-arn ${TARGET_ARN}
```

#### ターゲットグループに振り分け対象のEC2インスタンスを登録
  - `aws elbv2 create-target-group` コマンドで指定したVPC内のインスタンスを指定
  - `--targets Id=${INSTANCE1_ID}` : 80番ポートで登録される
  - `--targets Id=${INSTANCE1_ID},Port=${INSTANCE1_PORT}` : ${INSTANCE1_PORT}で登録される

 ```sh
INSTANCE1_ID="i-da2bb822"
aws elbv2 register-targets --target-group-arn=${TARGET_ARN} \
  --targets Id=${INSTANCE1_ID}
```

### リスナー作成

 ```sh
aws elbv2 create-listener --load-balancer-arn ${ELB_ARN} \
  --protocol HTTP --port 80 \
  --default-actions Type=forward,TargetGroupArn=${TARGET_ARN}
```

 ```json
{
    "Listeners": [
        {
            "Protocol": "HTTP",
            "DefaultActions": [
                {
                    "TargetGroupArn": "arn:aws:elasticloadbalancing:us-east-1:375144106126:targetgroup/HelloWorld-LB-TARGET-01/18ee6abefe461c19",
                    "Type": "forward"
                }
            ],
            "LoadBalancerArn": "arn:aws:elasticloadbalancing:us-east-1:375144106126:loadbalancer/app/HelloWorld-LB-01/a034310016248e53",
            "Port": 80,
            "ListenerArn": "arn:aws:elasticloadbalancing:us-east-1:375144106126:listener/app/HelloWorld-LB-01/a034310016248e53/a3b15afe6f9d8f12"
        }
    ]
}
```
  


