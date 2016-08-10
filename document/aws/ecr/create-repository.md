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


