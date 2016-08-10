# ECRレポジトリの作成手順

*ECR(Amazon EC2 Container Registry)* は、Dcokerコンテナイメージを保存・管理しデプロイすることが可能なフルマネージドサービスである。

ECRではレポジトリを作成し、レポジトリへ任意のDockerコンテナイメージをpushする。

ECRレポジトリの作成方法は大きく2つある。

 1. マネージメントコンソールから作成
   - refs http://aws.typepad.com/aws_japan/2015/12/ec2-container-registry-now-generally-available.html

 2. aws CLIから作成
   - http://qiita.com/zakky/items/be1e1a20cf7718ffae73

## ECRレポジトリ作成(aws CLI版)

### aws CLI インストール

```sh
yum install -y python python-devel python-setuptools --enablerepo=epel
easy_install pip
pip install awscli
```

awsコマンドのバージョンは以下のとおり。

```sh
[root@localhost ~]# aws --version
aws-cli/1.10.51 Python/2.7.5 Linux/3.10.0-123.4.4.el7.x86_64 botocore/1.4.41
```

### アクセスキーとシークレットキーを発行する

### 環境変数をセットする
 - キー情報はマスク済み
 - リージョンをECRが使用可能なバージニア(北米)リージョンに設定

```sh
export AWS_DEFAULT_REGION='us-east-1'
export AWS_ACCESS_KEY_ID=XXXXXXXXXXXXXXXXXXXXXX
export AWS_SECRET_ACCESS_KEY=XXXXXXXXXXXXXXXXXXXXXXXXX
```

プロファイル情報を確認し、上記設定が反映されていることを確認する。

```sh
[root@localhost ~]# aws configure list
      Name                    Value             Type    Location
      ----                    -----             ----    --------
   profile                <not set>             None    None
access_key     ****************XXXX              env
secret_key     ****************XXXX              env
    region                us-east-1              env    AWS_DEFAULT_REGION
```

### ECRレポジトリを作成

```sh
ECR_REPOSITORY=ecr-handson-httpd
aws ecr create-repository --repository-name java_tomcat-hello_world
```

```sh
[root@ip-172-30-3-178 ~]# aws ecr create-repository --repository-name java_tomcat-hello_world
{
    "repository": {
        "registryId": "375144106126",
        "repositoryName": "java_tomcat-hello_world",
        "repositoryArn": "arn:aws:ecr:us-east-1:375144106126:repository/java_tomcat-hello_world",
        "repositoryUri": "375144106126.dkr.ecr.us-east-1.amazonaws.com/java_tomcat-hello_world"
    }
}
```


