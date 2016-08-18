# GoCD Agent をDockerコンテナで起動する

## GoCD Dockerコンテナ
  - https://github.com/gocd/gocd-docker
    - GoCD関連のあらゆるDockerコンテナの起動スクリプトなどが置かれている
  - https://hub.docker.com/r/gocd/
    - GoCD関連のDockerマシンイメージレジストラのページ

## GoCD Server側の設定

### Agentとの通信に必要なポートを開放する
  - GoCD Serverは `TCP/8154` でAgentと通信を行う

 `TCP/8154` ポートを開放していないと以下エラーとなる。

 ```
java.lang.Exception: Couldn't access Go Server with base url: https://52.90.22.243:8154/go/admin/agent-launcher.jar: org.apache.http.conn.ConnectTimeoutException: Connect to 52.90.22.243:8154 [/52.90.22.243] failed: connect timed out
```

### Config XMLに `agentAutoRegisterKey` を追記する
  - refs https://docs.go.cd/16.5.0/advanced_usage/agent_auto_register.html
  - `<GoCD Server>:/etc/go/cruise-config.xml` もしくは `http://<GoCD Server>:8153/go/admin/config_xml`
  - `server` 要素に以下内容を追記
    - `agentAutoRegisterKey="388b633a88de126531afa41eff9aa69e"`

 ```sh
[root@ip-172-30-3-34 ~]# grep agentAutoRegisterKey /etc/go/cruise-config.xml
  <server artifactsdir="artifacts" agentAutoRegisterKey="388b633a88de126531afa41eff9aa69e" commandRepositoryLocation="default" serverId="022fc458-a44e-4fb5-95d7-e547c72bc481">
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

## GoCD Agent dockerコンテナをフォアグラウンド起動
  - `GO_SERVER` 環境変数でGoCD Serverを指定する
  - `AGENT_KEY` 環境変数でリモートAgentを自動登録する(Agent　Auto　Registration)
  - `Agent　Auto　Registration` が実施されていないと`http://<GoCD Server>:8153/go/agents` の **status が pending となる**

 ```sh
docker run -ti -e GO_SERVER=<GoCD Server> -e AGENT_KEY=<GoCD ServerのagentAutoRegisterKeyの値> gocd/gocd-agent
```

### 実行ログ

#### GoCD Agentコンテナ起動時の実行ログ

 ```sh
[root@ip-172-30-0-222 ~]# docker run -ti -e GO_SERVER=52.90.22.243 -e AGENT_KEY=388b633a88de126531afa41eff9aa69e gocd/gocd-agent
*** Running /etc/rc.local...
*** Booting runit daemon...
*** Runit started as PID 6
Starting Go Agent to connect to server 52.90.22.243 ...
[Thu Aug 18 03:50:18 UTC 2016] using default settings from /etc/default/go-agent
WARN: The environment variable GO_SERVER and GO_SERVER_PORT has been deprecated in favor of GO_SERVER_URL. Please set GO_SERVER_URL instead to a https url (https://example.com:8154/go)
Aug 18 03:50:18 b810dfee8d47 syslog-ng[11]: syslog-ng starting up; version='3.5.3'
logFile Environment Variable= null
Logging to go-agent-bootstrapper.log
0 [TouchLoopThread-2] INFO com.thoughtworks.go.agent.launcher.Lockfile  - Using lock file: /var/lib/go-agent/.agent-bootstrapper.running
1048 [main] INFO com.thoughtworks.go.agent.launcher.ServerBinaryDownloader  - download of agent.jar started at Thu Aug 18 03:50:20 UTC 2016
2911 [main] INFO com.thoughtworks.go.agent.launcher.ServerBinaryDownloader  - got server response at Thu Aug 18 03:50:22 UTC 2016
2955 [main] INFO com.thoughtworks.go.agent.launcher.ServerBinaryDownloader  - pipe the stream to admin/agent at Thu Aug 18 03:50:22 UTC 2016
2955 [main] INFO com.thoughtworks.go.util.PerfTimer  - Performance: Downloading new admin/agent with md5 signature: Qs4q6hbsH0CaDAZ3aJVb9A== took 1910ms
2957 [main] INFO com.thoughtworks.go.agent.common.util.JarUtil  - Attempting to load Go-Agent-Bootstrap-Class from agent.jar File:
2958 [main] INFO com.thoughtworks.go.agent.common.util.JarUtil  - manifestClassKey: Go-Agent-Bootstrap-Class: com.thoughtworks.go.agent.AgentProcessParentImpl
2961 [main] INFO com.thoughtworks.go.agent.AgentProcessParentImpl  - Agent is version: 16.7.0-3819
3183 [main] INFO com.thoughtworks.go.agent.launcher.ServerBinaryDownloader  - download of agent-plugins.zip started at Thu Aug 18 03:50:23 UTC 2016
5493 [main] INFO com.thoughtworks.go.agent.launcher.ServerBinaryDownloader  - got server response at Thu Aug 18 03:50:25 UTC 2016
5546 [main] INFO com.thoughtworks.go.agent.launcher.ServerBinaryDownloader  - pipe the stream to admin/agent-plugins.zip at Thu Aug 18 03:50:25 UTC 2016
5547 [main] INFO com.thoughtworks.go.util.PerfTimer  - Performance: Downloading new admin/agent-plugins.zip with md5 signature: 3e65339242506c3491c2aee13b355cc1 took 2364ms
5560 [main] INFO com.thoughtworks.go.agent.AgentProcessParentImpl  - Launching Agent with command: /usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java -Dcruise.console.publish.interval=10 -Xms128m -Xmx256m -Djava.security.egd=file:/dev/./urandom -Dagent.launcher.version=16.7.0-3819 -Dagent.plugins.md5=3e65339242506c3491c2aee13b355cc1 -Dagent.binary.md5=Qs4q6hbsH0CaDAZ3aJVb9A== -Dagent.launcher.md5=IWq49widZPfPYQNsCNvXGA== -jar agent.jar -serverUrl https://52.90.22.243:8154/go/ -sslVerificationMode NONE
```

#### GoCD Agentコンテナ起動時のGoCD Serverログ
  - `/var/log/go-server/go-server.log`
  - Agentの自動登録が成功していることを確認できる
    - `Auto registering agent with uuid b3026156-6e21-40af-9337-40d54759a8a1`

 ```
2016-08-17 20:50:31,610  INFO [qtp185593132-23] AgentRegistrationController:210 - [Agent Auto Registration] Auto registering agent with uuid b3026156-6e21-40af-9337-40d54759a8a1
2016-08-17 20:50:31,611  INFO [qtp185593132-23] GoConfigDao:94 - Config update for pipeline request by com.thoughtworks.go.server.domain.Username@7477db04[displayName=anonymous,username=anonymous] is in queue - com.thoughtworks.go.config.update.AgentsUpdateCommand@1f29c4c2
2016-08-17 20:50:31,611  INFO [qtp185593132-23] GoConfigDao:96 - Config update for pipeline request by com.thoughtworks.go.server.domain.Username@7477db04[displayName=anonymous,username=anonymous] is being processed
2016-08-17 20:50:31,613  WARN [qtp185593132-23] UpdateEnvironmentsCommand:44 - [Agent Auto Registration] Agent with uuid b3026156-6e21-40af-9337-40d54759a8a1 could not be assigned to environment  as it does not exist.
2016-08-17 20:50:31,618  INFO [qtp185593132-23] GoFileConfigDataSource:277 - [Configuration Changed] Saving updated configuration.
2016-08-17 20:50:31,699  INFO [qtp185593132-23] MagicalGoConfigXmlWriter:86 - [Serializing Config] Generating config partial.
2016-08-17 20:50:31,739  INFO [qtp185593132-23] CachedGoConfig:143 - About to notify com.thoughtworks.go.config.Agents config listeners
2016-08-17 20:50:31,739  INFO [qtp185593132-23] CachedGoConfig:158 - Finished notifying com.thoughtworks.go.config.Agents config listeners
2016-08-17 20:50:32,243  INFO [qtp185593132-23] GoConfigDao:94 - Config update for pipeline request by com.thoughtworks.go.server.domain.Username@f888969[displayName=agent_b3026156-6e21-40af-9337-40d54759a8a1_52.201.245.31_b810dfee8d47,username=agent_b3026156-6e21-40af-9337-40d54759a8a1_52.201.245.31_b810dfee8d47] is in queue - com.thoughtworks.go.config.update.AgentsUpdateCommand@4cf55476
2016-08-17 20:50:32,244  INFO [qtp185593132-23] GoConfigDao:96 - Config update for pipeline request by com.thoughtworks.go.server.domain.Username@f888969[displayName=agent_b3026156-6e21-40af-9337-40d54759a8a1_52.201.245.31_b810dfee8d47,username=agent_b3026156-6e21-40af-9337-40d54759a8a1_52.201.245.31_b810dfee8d47] is being processed
2016-08-17 20:50:32,250  INFO [qtp185593132-23] GoFileConfigDataSource:277 - [Configuration Changed] Saving updated configuration.
2016-08-17 20:50:32,338  INFO [qtp185593132-23] MagicalGoConfigXmlWriter:86 - [Serializing Config] Generating config partial.
2016-08-17 20:50:32,373  INFO [qtp185593132-23] CachedGoConfig:143 - About to notify com.thoughtworks.go.config.Agents config listeners
2016-08-17 20:50:32,373  INFO [qtp185593132-23] CachedGoConfig:158 - Finished notifying com.thoughtworks.go.config.Agents config listeners
2016-08-17 20:50:37,905  INFO [qtp185593132-23] BuildRepositoryRemoteImpl:133 - [Agent Cookie] Agent [Agent [b810dfee8d47, 172.17.0.2, b3026156-6e21-40af-9337-40d54759a8a1]] at location [/var/lib/go-agent] asked for a new cookie, assigned [2226fa1c-6fb1-4dee-be85-cdfac63db789]
2016-08-17 20:50:41,596  WARN [qtp185593132-30] AgentService:312 - Agent with UUID [b3026156-6e21-40af-9337-40d54759a8a1] changed IP Address from [52.201.245.31] to [172.17.0.2]
2016-08-17 20:50:41,597  INFO [qtp185593132-30] GoConfigDao:94 - Config update for pipeline request by com.thoughtworks.go.server.domain.Username@2167768c[displayName=agent_b3026156-6e21-40af-9337-40d54759a8a1_172.17.0.2_b810dfee8d47,username=agent_b3026156-6e21-40af-9337-40d54759a8a1_172.17.0.2_b810dfee8d47] is in queue - com.thoughtworks.go.config.update.AgentsUpdateCommand@f97f276
2016-08-17 20:50:41,597  INFO [qtp185593132-30] GoConfigDao:96 - Config update for pipeline request by com.thoughtworks.go.server.domain.Username@2167768c[displayName=agent_b3026156-6e21-40af-9337-40d54759a8a1_172.17.0.2_b810dfee8d47,username=agent_b3026156-6e21-40af-9337-40d54759a8a1_172.17.0.2_b810dfee8d47] is being processed
2016-08-17 20:50:41,603  INFO [qtp185593132-30] GoFileConfigDataSource:277 - [Configuration Changed] Saving updated configuration.
2016-08-17 20:50:41,650  INFO [qtp185593132-30] MagicalGoConfigXmlWriter:86 - [Serializing Config] Generating config partial.
2016-08-17 20:50:41,706  INFO [qtp185593132-30] CachedGoConfig:143 - About to notify com.thoughtworks.go.config.Agents config listeners
2016-08-17 20:50:41,707  INFO [qtp185593132-30] CachedGoConfig:158 - Finished notifying com.thoughtworks.go.config.Agents config listeners
```

## GoCD Agent dockerコンテナをバックグラウンド起動(デーモン起動)
  - `GO_SERVER` 環境変数でGoCD Serverを指定する
  - `AGENT_KEY` 環境変数でリモートAgentを自動登録する(Agent　Auto　Registration)
  - `Agent　Auto　Registration` が実施されていないと`http://<GoCD Server>:8153/go/agents` の **status が pending となる**

 ```sh
docker run -d -e GO_SERVER=<GoCD Server> -e AGENT_KEY=<GoCD ServerのagentAutoRegisterKeyの値> gocd/gocd-agent
```

### 実行ログ

#### GoCD Agentコンテナ起動時の実行ログ

 - コンテナを起動する

 ```sh
[root@ip-172-30-0-222 ~]# docker run -d -e GO_SERVER=52.90.22.243 -e AGENT_KEY=388b633a88de126531afa41eff9aa69e gocd/gocd-agent
cc0c9d4a2fe4d47d10b4be2893435915568e09880d3ae7476d26a6b150fc092f
```

 - コンテナ情報を確認する。

 ```sh
[root@ip-172-30-0-222 ~]# docker ps -f id=cc0c9d4a2fe4d47d10b4be2893435915568e09880d3ae7476d26a6b150fc092f
CONTAINER ID        IMAGE               COMMAND             CREATED              STATUS              PORTS               NAMES
cc0c9d4a2fe4        gocd/gocd-agent     "/sbin/my_init"     About a minute ago   Up About a minute                       pedantic_easley
```

 - コンテナで実行中のプロセスを表示する

 ```sh
[root@ip-172-30-0-222 ~]# docker top cc0c9d4a2fe4d47d10b4be2893435915568e09880d3ae7476d26a6b150fc092f
UID                 PID                 PPID                C                   STIME               TTY                 TIME                CMD
root                6256                6226                0                   05:07               ?                   00:00:00            /usr/bin/python3 -u /sbin/my_init
root                6296                6256                0                   05:07               ?                   00:00:00            /usr/bin/runsvdir -P /etc/service
root                6297                6296                0                   05:07               ?                   00:00:00            runsv syslog-ng
root                6298                6296                0                   05:07               ?                   00:00:00            runsv cron
root                6299                6296                0                   05:07               ?                   00:00:00            runsv syslog-forwarder
root                6300                6296                0                   05:07               ?                   00:00:00            runsv go-agent
root                6301                6297                0                   05:07               ?                   00:00:00            syslog-ng -F -p /var/run/syslog-ng.pid --no-caps
root                6302                6298                0                   05:07               ?                   00:00:00            /usr/sbin/cron -f
root                6303                6299                0                   05:07               ?                   00:00:00            tail -F -n 0 /var/log/syslog
root                6304                6300                0                   05:07               ?                   00:00:00            /bin/bash ./run
999                 6314                6304                0                   05:07               ?                   00:00:00            /bin/bash /etc/init.d/go-agent start
999                 6319                6314                2                   05:07               ?                   00:00:04            java -jar /usr/share/go-agent/agent-bootstrapper.jar -serverUrl https://52.90.22.243:8154/go/
999                 6340                6319                9                   05:07               ?                   00:00:13            /usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java -Dcruise.console.publish.interval=10 -Xms128m -Xmx256m -Djava.security.egd=file:/dev/./urandom -Dagent.launcher.version=16.7.0-3819 -Dagent.plugins.md5=3e65339242506c3491c2aee13b355cc1 -Dagent.binary.md5=Qs4q6hbsH0CaDAZ3aJVb9A== -Dagent.launcher.md5=IWq49widZPfPYQNsCNvXGA== -jar agent.jar -serverUrl https://52.90.22.243:8154/go/ -sslVerificationMode NONE
```

#### GoCD Agentコンテナ起動時のGoCD Serverログ
  - `/var/log/go-server/go-server.log`
  - Agentの自動登録が成功していることを確認できる
    - `Auto registering agent with uuid 087ac639-bbc0-40b3-bc62-23d81631f633`

 ```
2016-08-17 22:08:03,403  INFO [qtp185593132-24] AgentRegistrationController:210 - [Agent Auto Registration] Auto registering agent with uuid 087ac639-bbc0-40b3-bc62-23d81631f633
2016-08-17 22:08:03,403  INFO [qtp185593132-24] GoConfigDao:94 - Config update for pipeline request by com.thoughtworks.go.server.domain.Username@7477db04[displayName=anonymous,username=anonymous] is in queue - com.thoughtworks.go.config.update.AgentsUpdateCommand@3526b318
2016-08-17 22:08:03,403  INFO [qtp185593132-24] GoConfigDao:96 - Config update for pipeline request by com.thoughtworks.go.server.domain.Username@7477db04[displayName=anonymous,username=anonymous] is being processed
2016-08-17 22:08:03,405  WARN [qtp185593132-24] UpdateEnvironmentsCommand:44 - [Agent Auto Registration] Agent with uuid 087ac639-bbc0-40b3-bc62-23d81631f633 could not be assigned to environment  as it does not exist.
2016-08-17 22:08:03,409  INFO [qtp185593132-24] GoFileConfigDataSource:277 - [Configuration Changed] Saving updated configuration.
2016-08-17 22:08:03,517  INFO [qtp185593132-24] MagicalGoConfigXmlWriter:86 - [Serializing Config] Generating config partial.
2016-08-17 22:08:03,585  INFO [qtp185593132-24] CachedGoConfig:143 - About to notify com.thoughtworks.go.config.Agents config listeners
2016-08-17 22:08:03,585  INFO [qtp185593132-24] CachedGoConfig:158 - Finished notifying com.thoughtworks.go.config.Agents config listeners
2016-08-17 22:08:04,389  INFO [qtp185593132-24] GoConfigDao:94 - Config update for pipeline request by com.thoughtworks.go.server.domain.Username@6403de40[displayName=agent_087ac639-bbc0-40b3-bc62-23d81631f633_52.201.245.31_cc0c9d4a2fe4,username=agent_087ac639-bbc0-40b3-bc62-23d81631f633_52.201.245.31_cc0c9d4a2fe4] is in queue - com.thoughtworks.go.config.update.AgentsUpdateCommand@39f46f0c
2016-08-17 22:08:04,389  INFO [qtp185593132-24] GoConfigDao:96 - Config update for pipeline request by com.thoughtworks.go.server.domain.Username@6403de40[displayName=agent_087ac639-bbc0-40b3-bc62-23d81631f633_52.201.245.31_cc0c9d4a2fe4,username=agent_087ac639-bbc0-40b3-bc62-23d81631f633_52.201.245.31_cc0c9d4a2fe4] is being processed
2016-08-17 22:08:04,400  INFO [qtp185593132-24] GoFileConfigDataSource:277 - [Configuration Changed] Saving updated configuration.
2016-08-17 22:08:04,440  INFO [qtp185593132-24] MagicalGoConfigXmlWriter:86 - [Serializing Config] Generating config partial.
2016-08-17 22:08:04,444  INFO [qtp185593132-24] CachedGoConfig:143 - About to notify com.thoughtworks.go.config.Agents config listeners
2016-08-17 22:08:04,445  INFO [qtp185593132-24] CachedGoConfig:158 - Finished notifying com.thoughtworks.go.config.Agents config listeners
2016-08-17 22:08:09,897  INFO [qtp185593132-32] BuildRepositoryRemoteImpl:133 - [Agent Cookie] Agent [Agent [cc0c9d4a2fe4, 172.17.0.2, 087ac639-bbc0-40b3-bc62-23d81631f633]] at location [/var/lib/go-agent] asked for a new cookie, assigned [e38bc9f3-1af9-471a-96a2-d4a657b10ed9]
2016-08-17 22:08:13,459  WARN [qtp185593132-25] AgentService:312 - Agent with UUID [087ac639-bbc0-40b3-bc62-23d81631f633] changed IP Address from [52.201.245.31] to [172.17.0.2]
2016-08-17 22:08:13,460  INFO [qtp185593132-25] GoConfigDao:94 - Config update for pipeline request by com.thoughtworks.go.server.domain.Username@49ae74dd[displayName=agent_087ac639-bbc0-40b3-bc62-23d81631f633_172.17.0.2_cc0c9d4a2fe4,username=agent_087ac639-bbc0-40b3-bc62-23d81631f633_172.17.0.2_cc0c9d4a2fe4] is in queue - com.thoughtworks.go.config.update.AgentsUpdateCommand@5c7a7ef5
2016-08-17 22:08:13,460  INFO [qtp185593132-25] GoConfigDao:96 - Config update for pipeline request by com.thoughtworks.go.server.domain.Username@49ae74dd[displayName=agent_087ac639-bbc0-40b3-bc62-23d81631f633_172.17.0.2_cc0c9d4a2fe4,username=agent_087ac639-bbc0-40b3-bc62-23d81631f633_172.17.0.2_cc0c9d4a2fe4] is being processed
2016-08-17 22:08:13,466  INFO [qtp185593132-25] GoFileConfigDataSource:277 - [Configuration Changed] Saving updated configuration.
2016-08-17 22:08:13,492  INFO [qtp185593132-25] MagicalGoConfigXmlWriter:86 - [Serializing Config] Generating config partial.
2016-08-17 22:08:13,548  INFO [qtp185593132-25] CachedGoConfig:143 - About to notify com.thoughtworks.go.config.Agents config listeners
2016-08-17 22:08:13,548  INFO [qtp185593132-25] CachedGoConfig:158 - Finished notifying com.thoughtworks.go.config.Agents config listeners
```

