#  GoCD Pluginのインストール

## docker タスクプラグインをインストールする
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

