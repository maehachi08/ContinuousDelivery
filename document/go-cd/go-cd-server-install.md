#  GO CD Server Install
  - [Installing GoCD server on Linux](https://docs.go.cd/16.2.0/installation/install/server/linux.html)

### GO CD Server用EC2インスタンスを準備する

### セキュリティグループ作成
  - GO CD Serverのデフォルトリッスンポートである `8153` を開放する

```sh

sg_id=`aws ec2 create-security-group \
--group-name gocd-server \
--description "for go cd server" \
--vpc-id vpc-0f8dec68 | jq -r '.GroupId'`

aws ec2 authorize-security-group-ingress \
--group-id ${sg_id} \
--protocol tcp \
--port 22 \
--cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
--group-id ${sg_id} \
--protocol tcp \
--port 8153 \
--cidr 0.0.0.0/0
```

### EC2インスタンス作成
  - 作成したSGを割り当てる
  - `CentOS 6.4 x86_64 - with updates - G2 support - ami-7199b818` を使用

```sh
aws ec2 run-instances --image-id ami-7199b818 \
--instance-type t2.micro \
--count 1 \
--key-name HelloWorld \
--security-group-ids ${sg_id} \
--subnet subnet-eacbc0d7 \
--associate-public-ip-address
```


## GO CD Serverインストール

### yum repoを定義

```sh
echo "
[gocd]
name     = GoCD YUM Repository
baseurl  = https://download.go.cd
enabled  = 1
gpgcheck = 1
gpgkey   = https://download.go.cd/GOCD-GPG-KEY.asc
" | sudo tee /etc/yum.repos.d/gocd.repo
```

### Java実行環境インストール

```sh
sudo yum install -y java-1.7.0-openjdk
```

### GO CD Serverインストール

```sh
sudo yum install -y go-server
```

```
[root@ip-172-30-3-34 ~]# yum install -y go-server
Loaded plugins: fastestmirror, security
Setting up Install Process
Loading mirror speeds from cached hostfile
 * base: centos.mirror.nac.net
 * extras: mirror.cs.pitt.edu
 * updates: centos.chi.host-engine.com
Resolving Dependencies
--> Running transaction check
---> Package go-server.noarch 0:16.7.0-3819 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

====================================================================================================================================================
 Package                             Arch                             Version                                  Repository                      Size
====================================================================================================================================================
Installing:
 go-server                           noarch                           16.7.0-3819                              gocd                           132 M

Transaction Summary
====================================================================================================================================================
Install       1 Package(s)

Total download size: 132 M
Installed size: 132 M
Downloading Packages:
go-server-16.7.0-3819.noarch.rpm                                                                                             | 132 MB     00:04
warning: rpmts_HdrFromFdno: Header V4 RSA/SHA1 Signature, key ID 8816c449: NOKEY
Retrieving key from https://download.go.cd/GOCD-GPG-KEY.asc
Importing GPG key 0x8816C449:
 Userid: "ThoughtWorks GoCD (GoCD Code signing keys) <support@thoughtworks.com>"
 From  : https://download.go.cd/GOCD-GPG-KEY.asc
Running rpm_check_debug
Running Transaction Test
Transaction Test Succeeded
Running Transaction
  Installing : go-server-16.7.0-3819.noarch                                                                                                     1/1
[Mon Aug  8 19:11:54 PDT 2016] using default settings from /etc/default/go-server
Error starting Go Server.
warning: %post(go-server-16.7.0-3819.noarch) scriptlet failed, exit status 255
Non-fatal POSTIN scriptlet failure in rpm package go-server-16.7.0-3819.noarch
  Verifying  : go-server-16.7.0-3819.noarch                                                                                                     1/1

Installed:
  go-server.noarch 0:16.7.0-3819

Complete!
```


## GO CD SERVER初期セットアップ

### 自ホストが名前解決できずエラー
  - `/etc/hosts` に自ホストを追記

```
ERROR: Failed to start Go server. Please check the logs.
java.lang.RuntimeException: ip-172-30-3-34: ip-172-30-3-34: Name or service not known
        at com.thoughtworks.go.util.ExceptionUtils.bomb(ExceptionUtils.java:36)
```


## GO CD Server起動

```sh
service go-server status
service go-server start
service go-server status
ps auxfww | grep go-server
```

```sh
[root@ip-172-30-3-34 ~]# service go-server status
Go Server is stopped.
[root@ip-172-30-3-34 ~]# service go-server start
[Mon Aug  8 19:22:28 PDT 2016] using default settings from /etc/default/go-server
Started Go Server on http://ip-172-30-3-34:8153/go
[root@ip-172-30-3-34 ~]# service go-server status
Go Server is running.
[root@ip-172-30-3-34 ~]# ps auxfww | grep go-server
root      1625  0.0  0.0 103312   864 pts/0    S+   19:23   0:00  |                       \_ grep go-server
root      1430  0.0  0.0 100952   652 pts/1    S+   19:17   0:00                          \_ tail -f /var/log/go-server/go-server.out.log
go        1560 43.6 42.7 2206660 434888 ?      Sl   19:22   0:22 java -server -Djava.security.egd=file:/dev/./urandom -Xms512m -Xmx1024m -XX:PermSize=128m -XX:MaxPermSize=256m -Duser.language=en -Djruby.rack.request.size.threshold.bytes=30000000 -Duser.country=US -Dcruise.config.dir=/etc/go -Dcruise.config.file=/etc/go/cruise-config.xml -Dcruise.server.port=8153 -Dcruise.server.ssl.port=8154 -jar /usr/share/go-server/go.jar
```
```
[Mon Aug  8 19:22:28 PDT 2016] Starting Go Server with command: java -server -Djava.security.egd=file:/dev/./urandom -Xms512m -Xmx1024m -XX:PermSize=128m -XX:MaxPermSize=256m -Duser.language=en -Djruby.rack.request.size.threshold.bytes=30000000 -Duser.country=US -Dcruise.config.dir=/etc/go -Dcruise.config.file=/etc/go/cruise-config.xml -Dcruise.server.port=8153 -Dcruise.server.ssl.port=8154 -jar /usr/share/go-server/go.jar
[Mon Aug  8 19:22:28 PDT 2016] Starting Go Server in directory: /var/lib/go-server
```

## GO CD ServerへのWebアクセス

 以下URL でアクセス
   - http://52.90.22.243:8153/ 


### gitコマンドインストール

 GitHubレポジトリをポーリング対象とする場合、エージェントにgitコマンドをインストールする必要がある。

 ```sh
yum install -y git
```

### docker タスクプラグインをインストールする
  - jobのタスクタイプにdockerを選択可能にする

  1. プラグインのjarファイルをダウンロード
 
 ```sh
cd /var/lib/go-server/plugins/external
wget https://github.com/manojlds/gocd-docker/releases/download/0.1.27/docker-task-assembly-0.1.27.jar
```

  1. go-serverの再起動
  
 ```sh
service go-server stop
service go-server start
```

### dockerプラグインだけじゃだめ
 - エージェント側でdockerサービスを起動させる

```
2016-08-08 22:30:45,004 [loopThread] INFO  thoughtworks.go.work.DefaultGoPublisher:93 - Agent [ip-172-30-3-34, 127.0.0.1, 3b4f152c-d62a-4cd5-ac0d-151e2bd3c7ad] is reporting status [Building] to Go Server for Build [JavaServletHelloWorld/13/Build/1/docker-build/20]
2016-08-08 22:30:45,099 [loopThread] ERROR go.domain.builder.Builder:115 - Interaction with plugin with id 'docker-task' implementing 'task' extension failed while requesting for 'execute'. Reason: [null]
java.lang.RuntimeException: Interaction with plugin with id 'docker-task' implementing 'task' extension failed while requesting for 'execute'. Reason: [null]
        at com.thoughtworks.go.plugin.access.PluginRequestHelper.submitRequest(PluginRequestHelper.java:41)
```

```sh
sudo tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/6/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

sudo yum install docker-engine
sudo service docker start
```

### dockerグループに所属させる

```
23:00:35.037 [go] Start to execute task: Plugin with ID: docker-task.
23:00:35.107 stat pipelines/JavaServletHelloWorld/work: no such file or directory
23:00:35.120 dial unix /var/run/docker.sock: permission denied. Are you trying to connect to a TLS-enabled daemon without TLS?
23:00:35.120 Error: failed to remove images: [docker-task-javaservlethelloworld-build-docker-build:18]
23:00:35.135 Error: Interaction with plugin with id 'docker-task' implementing 'task' extension failed while requesting for 'execute'. Reason: [null]
23:00:35.167 [go] Current job status: failed.
```

```
sudo usermod -aG docker go
```


