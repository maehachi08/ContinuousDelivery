# パイプラインを定義する

## パイプライングループの新規作成
  1. `http://<GoCD Server>:8153/go/admin/pipelines` へアクセスする
  1. `Add New Pipeline Group` をクリックする
    1. `Pipeline Group Name*` に適当な名前を入力する
    1. `SAVE`をクリックする

## パイプラインの新規作成

先ほど作成したパイプライングループの `Create a new pipeline within this group` をクリックし、パイプラインの初期設定を実施する。

### Basic Settings
  1. `Pipeline Name*` に適当な名前を入力し、`NEXT` をクリックする

### Materials(デプロイ対象のレポジトリ情報)
  1. `Material Type*` に **Git** を選択する
  1. `URL*` に レポジトリURLを入力する
    - (GitHubの場合、URLは `git://` ではなく`http://` から始まるものでよい)
  1. `CHECK CONNECTION` をクリックし、**直下にConnection OK.と表示されること** を確認する
  1. `NEXT` をクリックする

### Stage/Job

#### Stage
  1. `Stage Name*` に適当な名前を入力する
  1. `Trigger Type:` に `On Success` を選択する

#### Initial Job and Task
  1. `Job Name*` に適当なJob名を入力する
  1. `Task Type*` に適当なタイプを選択する(コマンド実行はMore...)
  1. `Command` に実行したいコマンドを入力する
    - シェルスクリプトなら/bin/bash
    - lsコマンドならオプション無しでコマンドだけ入力する
  1. `Arguments` にコマンドオプションや引数を入力する
  1. `Working Directory` はGoCDエージェント上の実行ディレクトリを指定する
    - 相対パスとした場合はGoCD Agentのワークディレクトリを基点とする
    - ワークディレクトリは `/var/lib/go-agent/pipelines/<パイプライン名>` となる

以上の設定が完了したら、`FINISH` をクリックする。


## ビルド環境を作成

GoCDでは、**どのパイプラインをどのAgentで実行するのか** を定義する必要があります。

  1. `http://<GoCD Server>:8153/go/environments` へアクセスする
  1. `ADD A NEW ENVIRONMENT` をクリックする
  1. `Environment Name:` で適当なビルド環境名を入力し、`NEXT` をクリックする
  1. `Pipelines to add:` でこのビルド環境で実行したいパイプラインを選択する
    - 既に他ビルド環境にて選択済みのパイプラインは`Unavailable pipelines` の欄にあり選択不可
  1. `Agents to add:` でパイプラインを実行するAgentを選択する
  1. `Environment Variables (Name = Value)` でパイプライン処理で必要となる環境変数があれば定義する
    - AWS AccessKeyなど画面上でマスクしたい場合は`Secure Variables`の欄に定義する

以上の設定が完了したら、`FINISH` をクリックする。

## ビルドの実行
  1. `http://<GoCD Server>:8153/go/pipelines` へアクセスする
    - `http://<GoCD Server>:8153/go/environments` から設定することも可能(この場合リビジョン指定するなど少し手間なので今回はpipeline設定から進む)
  1. 先ほど作成したビルド環境のカードの中に `Paused by anonymous (Under construction)` という表示がある
  1. 一時停止ボタンクリックし、一時停止を解除(Unpause)する

以上の操作後、暫く待つと自動的にスケジュールされてパイプラインが実行される。


## ビルド実行ログの確認
  - Taskで `ls -l ./` コマンドを登録した場合
  - `tail -f /var/log/go-agent/go-agent.log`

 ```
2016-08-15 01:36:11,227 [loopThread] INFO  thoughtworks.go.work.DefaultGoPublisher:93 - Agent [ip-172-30-3-34, 127.0.0.1, 3b4f152c-d62a-4cd5-ac0d-151e2bd3c7ad] is reporting status [Preparing] to Go Server for Build [JavaServletHelloWorld2/3/docker-build-stage/1/docker-build-job/212]
2016-08-15 01:36:11,244 [pool-165-thread-1] INFO  thoughtworks.go.util.HttpService:135 - Got back 200 from server
2016-08-15 01:36:12,591 [loopThread] INFO  thoughtworks.go.work.DefaultGoPublisher:93 - Agent [ip-172-30-3-34, 127.0.0.1, 3b4f152c-d62a-4cd5-ac0d-151e2bd3c7ad] is reporting status [Building] to Go Server for Build [JavaServletHelloWorld2/3/docker-build-stage/1/docker-build-job/212]
2016-08-15 01:36:12,604 [loopThread] INFO  go.util.command.CommandLine:442 - Running command: ls -l ./
2016-08-15 01:36:12,606 [Thread-8009] INFO  go.util.command.CommandLine:62 - total 12
2016-08-15 01:36:12,606 [Thread-8009] INFO  go.util.command.CommandLine:62 - -rw-rw-r-- 1 go go   86 Aug 15 01:35 appspec.yml
2016-08-15 01:36:12,607 [Thread-8009] INFO  go.util.command.CommandLine:62 - -rw-rw-r-- 1 go go   46 Aug 15 01:35 README.md
2016-08-15 01:36:12,607 [Thread-8009] INFO  go.util.command.CommandLine:62 - drwxrwxr-x 4 go go 4096 Aug 15 01:35 WEB-INF
2016-08-15 01:36:12,707 [loopThread] INFO  thoughtworks.go.work.DefaultGoPublisher:99 - Agent [ip-172-30-3-34, 127.0.0.1, 3b4f152c-d62a-4cd5-ac0d-151e2bd3c7ad] is reporting build result [Passed] to Go Server for Build [JavaServletHelloWorld2/3/docker-build-stage/1/docker-build-job/212]
2016-08-15 01:36:12,727 [loopThread] INFO  thoughtworks.go.work.DefaultGoPublisher:93 - Agent [ip-172-30-3-34, 127.0.0.1, 3b4f152c-d62a-4cd5-ac0d-151e2bd3c7ad] is reporting status [Completing] to Go Server for Build [JavaServletHelloWorld2/3/docker-build-stage/1/docker-build-job/212]
2016-08-15 01:36:12,738 [loopThread] INFO  thoughtworks.go.work.DefaultGoPublisher:105 - Agent [ip-172-30-3-34, 127.0.0.1, 3b4f152c-d62a-4cd5-ac0d-151e2bd3c7ad] is reporting build result [Passed] to Go Server for Build [JavaServletHelloWorld2/3/docker-build-stage/1/docker-build-job/212]
2016-08-15 01:36:12,791 [loopThread] INFO  thoughtworks.go.work.DefaultGoPublisher:88 - Stopping Transmission for Build [JavaServletHelloWorld2/3/docker-build-stage/1/docker-build-job/212]
2016-08-15 01:36:12,800 [loopThread] INFO  thoughtworks.go.util.HttpService:135 - Got back 200 from server
```

