# CodeDeploy でDockerマシンイメージをビルドするEC2インスタンスを作成

## CodeDeployから操作するEC2インスタンスの要件
  1. dockerサービスが起動していること
    - 今回、docker buildで使用するための要件
  1. codedeploy-agentがインストールされていること
    - CodeDeployでデプロイされたことを検知し、`appspec.yml` に書かれた処理を実行するエージェントプロセス
  1. `AWSCodeDeployRole` ポリシーをアタッチした `CodeDeployServiceRole` ロールを作成
    - EC2インスタンスに `CodeDeployServiceRole` ロール を適用する
    - CodeDeployからEC2インスタンスを操作するために必要

## EC2インスタンス作成

### `CodeDeployServiceRole ` ロールの作成
 - [Create a Service Role for AWS CodeDeploy](http://docs.aws.amazon.com/ja_jp/codedeploy/latest/userguide/how-to-create-service-role.html)

  1. `CodeDeployServiceRole.json` を作成

 ```sh
vim CodeDeployServiceRole.json
```

  以下のjsonデータを記述します。

 ```sh
{
    "Role": {
        "AssumeRolePolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": "sts:AssumeRole",
                    "Principal": {
                        "Service": [
                            "codedeploy.us-west-2.amazonaws.com",
                            "codedeploy.us-east-1.amazonaws.com",
                            "codedeploy.ap-south-1.amazonaws.com",
                            "codedeploy.eu-central-1.amazonaws.com",
                            "codedeploy.sa-east-1.amazonaws.com",
                            "codedeploy.ap-northeast-1.amazonaws.com",
                            "codedeploy.us-west-1.amazonaws.com",
                            "codedeploy.eu-west-1.amazonaws.com",
                            "codedeploy.ap-southeast-1.amazonaws.com",
                            "codedeploy.ap-northeast-2.amazonaws.com",
                            "codedeploy.ap-southeast-2.amazonaws.com"
                        ]
                    },
                    "Effect": "Allow",
                    "Sid": ""
                }
            ]
        },
        "RoleId": "AROAIO53X23H7ETSW37QO",
        "CreateDate": "2016-08-04T04:46:11Z",
        "RoleName": "CodeDeployServiceRole",
        "Path": "/",
        "Arn": "arn:aws:iam::375144106126:role/CodeDeployServiceRole"
    }
}
```

  1. `CodeDeployServiceRole` の作成

 ```sh
aws iam create-role --role-name s3access --assume-role-policy-document file://CodeDeployServiceRole.json
```

  1. `CodeDeployServiceRole` ロールの確認

 ```sh
aws iam get-role --role-name CodeDeployServiceRole
```

  実行結果は以下のとおりです。

 ```sh
[root@localhost code-pipeline]# aws iam get-role --role-name CodeDeployServiceRole
{
    "Role": {
        "AssumeRolePolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": "sts:AssumeRole",
                    "Principal": {
                        "Service": [
                            "codedeploy.ap-northeast-1.amazonaws.com",
                            "codedeploy.eu-west-1.amazonaws.com",
                            "codedeploy.ap-southeast-1.amazonaws.com",
                            "codedeploy.eu-central-1.amazonaws.com",
                            "codedeploy.ap-northeast-2.amazonaws.com",
                            "codedeploy.ap-south-1.amazonaws.com",
                            "codedeploy.sa-east-1.amazonaws.com",
                            "codedeploy.us-west-2.amazonaws.com",
                            "codedeploy.us-east-1.amazonaws.com",
                            "codedeploy.ap-southeast-2.amazonaws.com",
                            "codedeploy.us-west-1.amazonaws.com"
                        ]
                    },
                    "Effect": "Allow",
                    "Sid": ""
                }
            ]
        },
        "RoleId": "AROAIO53X23H7ETSW37QO",
        "CreateDate": "2016-08-04T04:46:11Z",
        "RoleName": "CodeDeployServiceRole",
        "Path": "/",
        "Arn": "arn:aws:iam::375144106126:role/CodeDeployServiceRole"
    }
}
```

### EC2インスタンス
 - 今回はECSで使用するバージニア北米リージョンの `ami-55870742` を使用したインスタンスを利用
 - `CodeDeployServiceRole` を適用する

### `codedeploy-agent` インストール
 - [Install or Reinstall the AWS CodeDeploy Agent](http://docs.aws.amazon.com/ja_jp/codedeploy/latest/userguide/how-to-run-agent-install.html)
 - [CodeDeploy AgentをAmazon Linuxに手動でインストールする](http://qiita.com/okochang/items/f867b5bc63b8daabb1ea)
 - [CodeDeploy Agentから知るCodeDeployの処理の流れ](http://dev.classmethod.jp/cloud/aws/codedeploy-deploy-process/)

  1. awsコマンドをインストールする

 ```sh
sudo yum install -y aws-cli
```

  1. codedeploy-agentをインストールする

 ```sh
aws s3 cp s3://aws-codedeploy-us-east-1/latest/install . --region us-east-1
sudo chmod +x ./install
sudo ./install auto
```

  1. codedeploy-agentが起動していることを確認する

 ```sh
sudo yum info codedeploy-agent
sudo service codedeploy-agent status
```

  1. codedeploy-agentの動作ログを確認する

 ```sh
tail -f /var/log/aws/codedeploy-agent/codedeploy-agent.log
```

