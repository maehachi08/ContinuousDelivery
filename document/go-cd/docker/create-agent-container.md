# GoCD Agent をDockerコンテナで起動する

## GoCD Dockerコンテナ
  - https://github.com/gocd/gocd-docker
    - GoCD関連のあらゆるDockerコンテナの起動スクリプトなどが置かれている
  - https://hub.docker.com/r/gocd/
    - GoCD関連のDockerマシンイメージレジストラのページ

## GoCD Server側でAgentとの通信に必要なポートを開放する
  - GoCD Serverは `TCP/8154` でAgentと通信を行う

 `TCP/8154` ポートを開放していないと以下エラーとなる。

 ```
java.lang.Exception: Couldn't access Go Server with base url: https://52.90.22.243:8154/go/admin/agent-launcher.jar: org.apache.http.conn.ConnectTimeoutException: Connect to 52.90.22.243:8154 [/52.90.22.243] failed: connect timed out
```

## コンテナインスタンス作成
Dockerエンジンがインストール済みであることや、将来的にECSからデプロイすることを考慮し、ECSコンテナインスタンス向けのAMIを使用する。

  1. セキュリティグループ作成
    - TCP/22 だけ開放する

 ```sh
aws ec2 create-security-group \
--group-name go_cd-agent-container-instance \
--description "GoCD Agent container" \
--vpc-id vpc-0f8dec68

aws ec2 authorize-security-group-ingress \
--group-id sg-138a5969 \
--protocol tcp \
--port 22 \
--cidr 0.0.0.0/0
```

  1. インスタンス起動

 ```sh
aws ec2 run-instances --image-id ami-55870742 \
--instance-type t2.micro \
--count 1 \
--key-name HelloWorld \
--iam-instance-profile Name=web \
--security-group-ids sg-138a5969 \
--subnet subnet-eacbc0d7 \
--associate-public-ip-address
```

## GoCD Agent dockerマシンイメージの取得
  - refs https://hub.docker.com/r/gocd/gocd-agent/

 ```sh
docker pull gocd/gocd-agent
docker images gocd/gocd-agent
```

### 実行ログ

 ```sh
[root@ip-172-30-0-222 ~]# docker images
REPOSITORY                TAG                 IMAGE ID            CREATED             SIZE
amazon/amazon-ecs-agent   latest              66fbd081397b        6 weeks ago         10.64 MB
[root@ip-172-30-0-222 ~]# docker pull gocd/gocd-agent
Using default tag: latest
latest: Pulling from gocd/gocd-agent

6ffe5d2d6a97: Pull complete
f4e00f994fd4: Pull complete
e99f3d1fc87b: Pull complete
a3ed95caeb02: Pull complete
ededd75b6753: Pull complete
1ddde157dd31: Pull complete
8d15adc059b8: Pull complete
1accd32755ef: Pull complete
0e20c7ca790d: Pull complete
5874bcfa424f: Pull complete
11d6b05bbee9: Pull complete
b1dafbcbc343: Pull complete
d816b8e3a30d: Pull complete
88e247ebb70c: Pull complete
8097be77660d: Pull complete
26edefbb2636: Pull complete
72110276d36b: Pull complete
Digest: sha256:8bd3f510089936c8401f6a8cb1c516bff8bf13f226213046a83e329742746cff
Status: Downloaded newer image for gocd/gocd-agent:latest
[root@ip-172-30-0-222 ~]# docker images gocd/gocd-agent
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
gocd/gocd-agent     latest              7c71be5fec80        2 weeks ago         688.6 MB
```

## GoCD Agent dockerコンテナ起動

 ```sh
docker run -ti -e GO_SERVER=<GoCD Server> gocd/gocd-agent
```

### 実行ログ

 ```sh
[root@ip-172-30-0-222 ~]# docker run -ti -e GO_SERVER=52.90.22.243 gocd/gocd-agent
*** Running /etc/rc.local...
*** Booting runit daemon...
*** Runit started as PID 6
Starting Go Agent to connect to server 52.90.22.243 ...
[Thu Aug 18 02:14:47 UTC 2016] using default settings from /etc/default/go-agent
WARN: The environment variable GO_SERVER and GO_SERVER_PORT has been deprecated in favor of GO_SERVER_URL. Please set GO_SERVER_URL instead to a https url (https://example.com:8154/go)
Aug 18 02:14:47 b405bdbb98cf syslog-ng[11]: syslog-ng starting up; version='3.5.3'
logFile Environment Variable= null
Logging to go-agent-bootstrapper.log
0 [TouchLoopThread-2] INFO com.thoughtworks.go.agent.launcher.Lockfile  - Using lock file: /var/lib/go-agent/.agent-bootstrapper.running
1161 [main] INFO com.thoughtworks.go.agent.launcher.ServerBinaryDownloader  - download of agent.jar started at Thu Aug 18 02:14:49 UTC 2016
3521 [main] INFO com.thoughtworks.go.agent.launcher.ServerBinaryDownloader  - got server response at Thu Aug 18 02:14:52 UTC 2016
3589 [main] INFO com.thoughtworks.go.agent.launcher.ServerBinaryDownloader  - pipe the stream to admin/agent at Thu Aug 18 02:14:52 UTC 2016
3590 [main] INFO com.thoughtworks.go.util.PerfTimer  - Performance: Downloading new admin/agent with md5 signature: Qs4q6hbsH0CaDAZ3aJVb9A== took 2432ms
3592 [main] INFO com.thoughtworks.go.agent.common.util.JarUtil  - Attempting to load Go-Agent-Bootstrap-Class from agent.jar File:
3593 [main] INFO com.thoughtworks.go.agent.common.util.JarUtil  - manifestClassKey: Go-Agent-Bootstrap-Class: com.thoughtworks.go.agent.AgentProcessParentImpl
3602 [main] INFO com.thoughtworks.go.agent.AgentProcessParentImpl  - Agent is version: 16.7.0-3819
3867 [main] INFO com.thoughtworks.go.agent.launcher.ServerBinaryDownloader  - download of agent-plugins.zip started at Thu Aug 18 02:14:52 UTC 2016
7088 [main] INFO com.thoughtworks.go.agent.launcher.ServerBinaryDownloader  - got server response at Thu Aug 18 02:14:55 UTC 2016
7139 [main] INFO com.thoughtworks.go.agent.launcher.ServerBinaryDownloader  - pipe the stream to admin/agent-plugins.zip at Thu Aug 18 02:14:55 UTC 2016
7139 [main] INFO com.thoughtworks.go.util.PerfTimer  - Performance: Downloading new admin/agent-plugins.zip with md5 signature: 3e65339242506c3491c2aee13b355cc1 took 3272ms
7527 [main] INFO com.thoughtworks.go.agent.AgentProcessParentImpl  - Launching Agent with command: /usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java -Dcruise.console.publish.interval=10 -Xms128m -Xmx256m -Djava.security.egd=file:/dev/./urandom -Dagent.launcher.version=16.7.0-3819 -Dagent.plugins.md5=3e65339242506c3491c2aee13b355cc1 -Dagent.binary.md5=Qs4q6hbsH0CaDAZ3aJVb9A== -Dagent.launcher.md5=IWq49widZPfPYQNsCNvXGA== -jar agent.jar -serverUrl https://52.90.22.243:8154/go/ -sslVerificationMode NONE
Aug 18 02:17:01 b405bdbb98cf /USR/SBIN/CRON[72]: (root) CMD (   cd / && run-parts --report /etc/cron.hourly)
```

