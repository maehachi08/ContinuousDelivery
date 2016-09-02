# ECSクラスタ作成

## タスク定義
  - Dockerコンテナに関する設定
  - `containerDefinitions` の `portMappings` で **hostPortを0に設定することで動的ポートマッピング**
    - http://docs.aws.amazon.com/ja_jp/AmazonECS/latest/APIReference/API_PortMapping.html

 1. TaskDefinitionsをJSON形式のファイルで定義しておきます

 ```sh
cat << EOT > container-definitions.json
{
  "containerDefinitions": [
    {
      "name": "JavaTomcatDefinition",
      "image": "375144106126.dkr.ecr.us-east-1.amazonaws.com/java_tomcat-hello_world",
      "cpu": 1,
      "portMappings": [{
        "containerPort": 80,
        "hostPort": 0,
        "protocol": "tcp"
      }],
      "command": [ "/usr/bin/supervisord" ],
      "memory": 128,
      "essential": true
    }
  ],
  "family": "JavaTomcatDefinition"
}
EOT
```

 1. 作成したJSONファイルを使ってタスクを定義します。

 ```sh
aws ecs register-task-definition --cli-input-json file://container-definitions.json
```

## クラスタ作成

```sh
aws ecs create-cluster --cluster-name JavaTomcatCluster
```

実行結果は以下のとおり。

```sh
[root@localhost aws]# aws ecs create-cluster --cluster-name JavaTomcatCluster
{
    "cluster": {
        "status": "ACTIVE",
        "clusterName": "JavaTomcatCluster",
        "registeredContainerInstancesCount": 0,
        "pendingTasksCount": 0,
        "runningTasksCount": 0,
        "activeServicesCount": 0,
        "clusterArn": "arn:aws:ecs:us-east-1:375144106126:cluster/JavaTomcatCluster"
    }
}
```

## クラスタにタスク登録

```sh
aws ecs run-task --cluster JavaTomcatCluster --task-definition JavaTomcatDefinition --count 2
```

実行結果は以下のとおり。

```sh
[root@localhost aws]# aws ecs run-task --cluster JavaTomcatCluster --task-definition JavaTomcatDefinition --count 2
{
    "failures": [
        {
            "reason": "RESOURCE:PORTS",
            "arn": "arn:aws:ecs:us-east-1:375144106126:container-instance/d7da1f42-e69f-48a6-bb27-41515b1cbbff"
        }
    ],
    "tasks": [
        {
            "taskArn": "arn:aws:ecs:us-east-1:375144106126:task/e25c6316-7543-49a4-8e7d-05a83c8e0e60",
            "overrides": {
                "containerOverrides": [
                    {
                        "name": "JavaTomcatDefinition"
                    }
                ]
            },
            "lastStatus": "PENDING",
            "containerInstanceArn": "arn:aws:ecs:us-east-1:375144106126:container-instance/d7da1f42-e69f-48a6-bb27-41515b1cbbff",
            "createdAt": 1470214969.513,
            "clusterArn": "arn:aws:ecs:us-east-1:375144106126:cluster/JavaTomcatCluster",
            "desiredStatus": "RUNNING",
            "taskDefinitionArn": "arn:aws:ecs:us-east-1:375144106126:task-definition/JavaTomcatDefinition:3",
            "containers": [
                {
                    "containerArn": "arn:aws:ecs:us-east-1:375144106126:container/89c0ec7d-103c-49d7-b1dc-0d6570d8c2f8",
                    "taskArn": "arn:aws:ecs:us-east-1:375144106126:task/e25c6316-7543-49a4-8e7d-05a83c8e0e60",
                    "lastStatus": "PENDING",
                    "name": "JavaTomcatDefinition"
                }
            ]
        }
    ]
}
```

## コンテナインスタンス上でdockerコンテナの動作確認

`54.197.107.199`にec2-userでログインし`sudo su -`して以下確認を実施。


 1. dockerマシンイメージに `375144106126.dkr.ecr.us-east-1.amazonaws.com/ecr-handson-httpd` があること

 ```sh
[root@ip-172-30-3-199 ~]# docker images
REPOSITORY                                                       TAG                 IMAGE ID            CREATED             SIZE
375144106126.dkr.ecr.us-east-1.amazonaws.com/ecr-handson-httpd   latest              bdbe933dd381        25 hours ago        569.7 MB
amazon/amazon-ecs-agent                                          latest              66fbd081397b        3 weeks ago         10.64 MB
```

 1. dockerコンテナとしての確認
   - `375144106126.dkr.ecr.us-east-1.amazonaws.com/ecr-handson-httpd` をIMAGEとして使用
   - `/usr/bin/supervisord` を実行している

 ```sh
[root@ip-172-30-3-199 ~]# docker ps -a
CONTAINER ID        IMAGE                                                                   COMMAND                  CREATED             STATUS              PORTS                NAMES
0f2e90dc8c6b        375144106126.dkr.ecr.us-east-1.amazonaws.com/ecr-handson-httpd:latest   "/usr/bin/supervisord"   20 minutes ago      Up 20 minutes       0.0.0.0:80->80/tcp   ecs-JavaTomcatDefinition-3-JavaTomcatDefinition-80acdebaaf91bdc88401
0d825d1f4b88        amazon/amazon-ecs-agent:latest                                          "/agent"                 21 minutes ago      Up 21 minutes                            ecs-agent
```

 1. 該当するコンテナのプロセスとしてapache(httpd)とtomcatが起動していること

 ```sh
[root@ip-172-30-3-199 ~]# docker top 0f2e90dc8c6b
UID                 PID                 PPID                C                   STIME               TTY                 TIME                CMD
root                3108                3088                0                   09:03               ?                   00:00:00            /usr/bin/python /usr/bin/supervisord
root                3171                3108                0                   09:03               ?                   00:00:00            /usr/sbin/httpd -c ErrorLog /dev/stdout -DFOREGROUND
root                3172                3108                0                   09:03               ?                   00:00:03            /usr/lib/jvm/jre/bin/java -classpath /usr/share/tomcat/bin/bootstrap.jar:/usr/share/tomcat/bin/tomcat-juli.jar:/usr/share/java/commons-daemon.jar -Dcatalina.base=/usr/share/tomcat -Dcatalina.home=/usr/share/tomcat -Djava.endorsed.dirs= -Djava.io.tmpdir=/var/cache/tomcat/temp -Djava.util.logging.config.file=/usr/share/tomcat/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager org.apache.catalina.startup.Bootstrap start
48                  3189                3171                0                   09:03               ?                   00:00:00            /usr/sbin/httpd -c ErrorLog /dev/stdout -DFOREGROUND
48                  3190                3171                0                   09:03               ?                   00:00:00            /usr/sbin/httpd -c ErrorLog /dev/stdout -DFOREGROUND
48                  3191                3171                0                   09:03               ?                   00:00:00            /usr/sbin/httpd -c ErrorLog /dev/stdout -DFOREGROUND
48                  3192                3171                0                   09:03               ?                   00:00:00            /usr/sbin/httpd -c ErrorLog /dev/stdout -DFOREGROUND
48                  3193                3171                0                   09:03               ?                   00:00:00            /usr/sbin/httpd -c ErrorLog /dev/stdout -DFOREGROUND
48                  3240                3171                0                   09:03               ?                   00:00:00            /usr/sbin/httpd -c ErrorLog /dev/stdout -DFOREGROUND
48                  3306                3171                0                   09:04               ?                   00:00:00            /usr/sbin/httpd -c ErrorLog /dev/stdout -DFOREGROUND
```

## httpアクセスで`HelloWorld` が返ってくること
  - ブラウザでも下記URLで確認済み

```sh
[root@localhost aws]# curl http://54.197.107.199/hello/servlet/hello
<html>
HelloWorld
</html>
```

