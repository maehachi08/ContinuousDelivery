# コンテナインスタンス用のロール作成
  - refs http://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/instance_IAM_role.html

Amazon EC2 Container Service (ECS) でdockerコンテナを作成・起動するためには、EC2上でdockerサービスが起動しているEC2インスタンスを作成する必要がある。dockerサービスが起動しているECS用のインスタンスを**コンテナインスタンス** と呼ぶ。

コンテナインスタンスは通常のEC2インスタンスと異なりECSから扱うため、専用のポリシーをアタッチしたロールを適用する必要がある。

コンテナインスタンスに適用する必要があるポリシーは「**AmazonEC2ContainerServiceforEC2Role**」。
AmazonEC2ContainerServiceforEC2Roleポリシーをアタッチするロールは「**ecsInstanceRole**」。


## ロール作成

 1. `--assume-role-policy-document`で指定するjsonファイルを準備

 ```sh
cat << EOT > ecsInstanceRole.json
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOT
```

 1. `ecsInstanceRole` ロールを作成

 ```sh
aws iam create-role --role-name ecsInstanceRole --assume-role-policy-document file://ecsInstanceRole.json
```

### 実行結果

 ```sh
[root@localhost aws]# aws iam create-role --role-name ecsInstanceRole --assume-role-policy-document file://ecsInstanceRole.json
{
    "Role": {
        "AssumeRolePolicyDocument": {
            "Version": "2008-10-17",
            "Statement": [
                {
                    "Action": "sts:AssumeRole",
                    "Principal": {
                        "Service": "ec2.amazonaws.com"
                    },
                    "Effect": "Allow",
                    "Sid": ""
                }
            ]
        },
        "RoleId": "AROAJEIJ7GXONP7GHK3SE",
        "CreateDate": "2016-08-03T05:58:32.623Z",
        "RoleName": "ecsInstanceRole",
        "Path": "/",
        "Arn": "arn:aws:iam::375144106126:role/ecsInstanceRole"
    }
}
```

## ポリシーをアタッチ

 1. アタッチ対象のポリシー `AmazonEC2ContainerServiceforEC2Role` の情報を確認

 ```sh
aws iam get-policy --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role
```

### 実行結果

 ```sh
[root@localhost aws]# aws iam get-policy --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role
{
    "Policy": {
        "PolicyName": "AmazonEC2ContainerServiceforEC2Role",
        "Description": "Default policy for the Amazon EC2 Role for Amazon EC2 Container Service.",
        "CreateDate": "2015-03-19T18:45:18Z",
        "AttachmentCount": 0,
        "IsAttachable": true,
        "PolicyId": "ANPAJLYJCVHC7TQHCSQDS",
        "DefaultVersionId": "v4",
        "Path": "/service-role/",
        "Arn": "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
        "UpdateDate": "2016-05-04T18:56:55Z"
    }
}
```

 1. ポリシーをアタッチ

 ```sh
aws iam attach-role-policy --role-name ecsInstanceRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role
```

## `ecsInstanceRole` ロール情報を確認

 ```sh
aws iam get-role --role-name ecsInstanceRole
```

実行結果は以下のとおり。

 ```sh
[root@localhost aws]# aws iam get-role --role-name ecsInstanceRole
{
    "Role": {
        "AssumeRolePolicyDocument": {
            "Version": "2008-10-17",
            "Statement": [
                {
                    "Action": "sts:AssumeRole",
                    "Principal": {
                        "Service": "ec2.amazonaws.com"
                    },
                    "Effect": "Allow",
                    "Sid": ""
                }
            ]
        },
        "RoleId": "AROAJEIJ7GXONP7GHK3SE",
        "CreateDate": "2016-08-03T05:58:32Z",
        "RoleName": "ecsInstanceRole",
        "Path": "/",
        "Arn": "arn:aws:iam::375144106126:role/ecsInstanceRole"
    }
}
```

