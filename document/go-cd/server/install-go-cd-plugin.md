#  GoCD Pluginのインストール

## docker タスクプラグインをインストールする
  - jobのタスクタイプにdockerを選択可能にする

  1. プラグインのjarファイルをダウンロード
 
 ```sh
cd /var/lib/go-server/plugins/external
wget https://github.com/manojlds/gocd-docker/releases/download/0.1.27/docker-task-assembly-0.1.27.jar
```
 1. goユーザをdockerグループに所属させる
   今回、GoCD agent環境でdockerマシンイメージのビルド作業を行うのですが、goユーザからdockerを操作するためにはdockerグループへ追加しないと以下エラーとなります。

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


  1. go-serverの再起動
  
 ```sh
service go-server stop
service go-server start
```

