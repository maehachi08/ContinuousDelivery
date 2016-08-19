# GoCD ServerからのSlack通知機能を検証

## `gocd-slack-build-notifier`
  - https://github.com/ashwanthkumar/gocd-slack-build-notifier

### インストール

 ```sh
cd /var/lib/go-server/plugins/external/
wget https://github.com/ashwanthkumar/gocd-slack-build-notifier/releases/download/v1.4.0-RC7/gocd-slack-notifier-1.4.0-RC7.jar
service go-server restart
```

### 設定
  - [テンプレート的なファイル](https://github.com/ashwanthkumar/gocd-slack-build-notifier/blob/master/src/main/resources/reference.conf)
  - `gocd-slack-build-notifier`はGoCD Server上に設定ファイルを配置することで有効化する
  - `/var/go/go_notify.conf`
  - 更新には `go-server` の再起動は **不要**
    - ファイルの更新を検知して再読み込みしてくれている
    - `2016-08-19 02:03:26,405  INFO [Timer-0] GoNotificationPlugin:52 - Reloading configuration file since some modifications were found`

 ```
# gocd-slack-build-notifier plugin configuration
gocd.slack {
  # GoCD Serverへの接続情報
  login = "kmaehata"
  password = "kmaehata"
  server-host = "http://127.0.0.1:8153/"
  api-server-host = "http://127.0.0.1:8153/"
  
  # SlackのWebHookURL
  webhookUrl = "https://hooks.slack.com/services/*********"

  # optional fields
  channel = "#gocd"
  slackDisplayName = "gocd-slack-bot"
  slackUserIconURL = "http://example.com/slack-bot.png"
  displayMaterialChanges = true

  # 通知対象
  pipelines = [{
    name = "JavaServletHelloWorld"
    #stage = "BuildDockerStage"
    stage = ".*"
    #state = "building"
    state = "building|passed|cancelled"
    channel = "#gocd"
    # Slackのメンションアカウント
    owners = ["maehachi08"]
    webhookUrl = "https://hooks.slack.com/services/T095LLGV7/*******"
  },
  {
    name = ".*"
    stage = ".*"
    state = "failed"
  }]

  #proxy {
  #  hostname = "localhost"
  #  port = "5555"
  #  type = "socks" # acceptable values are http / socks
  #}
}
```

