#  GoCD Agentのインストール

## yum repoを定義

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

## Java実行環境インストール

```sh
sudo yum install -y java-1.7.0-openjdk
```

## GoCD Agentインストール

```sh
sudo yum install -y go-agent
```

## gitコマンドインストール

 GitHubレポジトリをポーリング対象とする場合、エージェントにgitコマンドをインストールする必要がある。

 ```sh
yum install -y git
```

## dockerサービスを起動

 GoCD で `docker build` を実行するためには、もちろんAgent側でDockerサービスが起動している必要がある。

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

## dockerグループに所属させる

 GoCDの一般ユーザ `go` を dockerグループに所属させる必要がある。

 ```
23:00:35.037 [go] Start to execute task: Plugin with ID: docker-task.
23:00:35.107 stat pipelines/JavaServletHelloWorld/work: no such file or directory
23:00:35.120 dial unix /var/run/docker.sock: permission denied. Are you trying to connect to a TLS-enabled daemon without TLS?
23:00:35.120 Error: failed to remove images: [docker-task-javaservlethelloworld-build-docker-build:18]
23:00:35.135 Error: Interaction with plugin with id 'docker-task' implementing 'task' extension failed while requesting for 'execute'. Reason: [null]
23:00:35.167 [go] Current job status: failed.
```

 ```sh
sudo usermod -aG docker go
```

