# ECRレポジトリの作成手順

*ECR(Amazon EC2 Container Registry)* は、Dcokerコンテナイメージを保存・管理しデプロイすることが可能なフルマネージドサービスである。

ECRではレポジトリを作成し、レポジトリへ任意のDockerコンテナイメージをpushする。

ECRレポジトリの作成方法は大きく2つある。

 1. マネージメントコンソールから作成
   - refs http://aws.typepad.com/aws_japan/2015/12/ec2-container-registry-now-generally-available.html

 2. aws CLIから作成
   - http://qiita.com/zakky/items/be1e1a20cf7718ffae73

## ECRレポジトリを作成

 ```sh
aws ecr create-repository --repository-name java-servlet-hello-world
```

 ```sh
# aws ecr create-repository --repository-name java-servlet-hello-world
{
    "repository": {
        "registryId": "375144106126",
        "repositoryName": "java-servlet-hello-world",
        "repositoryArn": "arn:aws:ecr:us-east-1:375144106126:repository/java-servlet-hello-world",
        "repositoryUri": "375144106126.dkr.ecr.us-east-1.amazonaws.com/java-servlet-hello-world"
    }
}
```

## ECRレポジトリ情報の確認

 ```sh
# aws ecr describe-repositories --repository-names java-servlet-hello-world
{
    "repositories": [
        {
            "registryId": "375144106126",
            "repositoryName": "java-servlet-hello-world",
            "repositoryArn": "arn:aws:ecr:us-east-1:375144106126:repository/java-servlet-hello-world",
            "repositoryUri": "375144106126.dkr.ecr.us-east-1.amazonaws.com/java-servlet-hello-world"
        }
    ]
}
```

 レジストリIDを取得したい場合は以下のようにjqコマンドを使用する。

 ```sh
# aws ecr describe-repositories --repository-names java-servlet-hello-world | jq -r '.repositories[].registryId'
375144106126
```

