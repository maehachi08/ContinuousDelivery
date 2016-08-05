# CodeDeployServiceRole ロールの作成
  - [Create a Service Role (CLI)](http://docs.aws.amazon.com/ja_jp/codedeploy/latest/userguide/how-to-create-service-role.html#how-to-create-service-role-cli)


## jsonファイルの作成

 ```sh
vim CodeDeployServiceRole-Trust.json
```

 ```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "codedeploy.us-east-1.amazonaws.com", 
          "codedeploy.us-west-1.amazonaws.com",
          "codedeploy.us-west-2.amazonaws.com",
          "codedeploy.ap-northeast-1.amazonaws.com",
          "codedeploy.ap-northeast-2.amazonaws.com",
          "codedeploy.ap-south-1.amazonaws.com",
          "codedeploy.ap-southeast-1.amazonaws.com",
          "codedeploy.ap-southeast-2.amazonaws.com",
          "codedeploy.eu-central-1.amazonaws.com",
          "codedeploy.eu-west-1.amazonaws.com",
          "codedeploy.sa-east-1.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

## CodeDeployServiceRole 作成

 ```sh
aws iam create-role --role-name CodeDeployServiceRole --assume-role-policy-document file://CodeDeployServiceRole-Trust.json
```

 実行結果は以下のとおり。

 ```sh
[root@localhost aws]# aws iam create-role --role-name CodeDeployServiceRole --assume-role-policy-document file://CodeDeployServiceRole-Trust.json
{
    "Role": {
        "AssumeRolePolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": "sts:AssumeRole",
                    "Principal": {
                        "Service": [
                            "codedeploy.us-east-1.amazonaws.com",
                            "codedeploy.us-west-1.amazonaws.com",
                            "codedeploy.us-west-2.amazonaws.com",
                            "codedeploy.ap-northeast-1.amazonaws.com",
                            "codedeploy.ap-northeast-2.amazonaws.com",
                            "codedeploy.ap-south-1.amazonaws.com",
                            "codedeploy.ap-southeast-1.amazonaws.com",
                            "codedeploy.ap-southeast-2.amazonaws.com",
                            "codedeploy.eu-central-1.amazonaws.com",
                            "codedeploy.eu-west-1.amazonaws.com",
                            "codedeploy.sa-east-1.amazonaws.com"
                        ]
                    },
                    "Effect": "Allow",
                    "Sid": ""
                }
            ]
        },
        "RoleId": "AROAI65D2T7WKZCQ3GXPM",
        "CreateDate": "2016-08-05T06:33:47.837Z",
        "RoleName": "CodeDeployServiceRole",
        "Path": "/",
        "Arn": "arn:aws:iam::375144106126:role/CodeDeployServiceRole"
    }
}
```

## AWSCodeDeployRole ロールのアタッチ

 ```sh
aws iam attach-role-policy --role-name CodeDeployServiceRole --policy-arn arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole
```

## AWSCodeDeployRole 定義確認

 ```sh
aws iam get-role --role-name CodeDeployServiceRole
```

 実行結果は以下のとおり。

 ```sh
[root@localhost aws]# aws iam get-role --role-name CodeDeployServiceRole
{
    "Role": {
        "AssumeRolePolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": "sts:AssumeRole",
                    "Principal": {
                        "Service": [
                            "codedeploy.us-west-1.amazonaws.com",
                            "codedeploy.ap-southeast-1.amazonaws.com",
                            "codedeploy.eu-west-1.amazonaws.com",
                            "codedeploy.ap-northeast-1.amazonaws.com",
                            "codedeploy.ap-south-1.amazonaws.com",
                            "codedeploy.sa-east-1.amazonaws.com",
                            "codedeploy.eu-central-1.amazonaws.com",
                            "codedeploy.us-west-2.amazonaws.com",
                            "codedeploy.us-east-1.amazonaws.com",
                            "codedeploy.ap-southeast-2.amazonaws.com",
                            "codedeploy.ap-northeast-2.amazonaws.com"
                        ]
                    },
                    "Effect": "Allow",
                    "Sid": ""
                }
            ]
        },
        "RoleId": "AROAI65D2T7WKZCQ3GXPM",
        "CreateDate": "2016-08-05T06:33:47Z",
        "RoleName": "CodeDeployServiceRole",
        "Path": "/",
        "Arn": "arn:aws:iam::375144106126:role/CodeDeployServiceRole"
    }
}
```


