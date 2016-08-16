#  GoCD Agentのインストール

## インストール
  - [Installing GoCD agent on Linux](https://docs.go.cd/16.3.0/installation/install/agent/linux.html)

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

### GoCD Agentインストール

```sh
sudo yum install -y go-agent
```

## 設定

### GoCD Server IPアドレス設定
  - GoCD はSever/Client型のツールであり、Client(Agant)にてGoCD ServerのIPアドレスを設定する
  - GoCD Agentはデフォルトで `127.0.0.1` をGoCD Serverとして設定している
  - 設定は `/etc/default/go-agent` に記載している

 ```sh
vim /etc/default/go-agen
```

 以下のようにIPアドレスを設定します。

 ```
GO_SERVER=<GoCD Server IP>
```

## GoCD AgentノードをServer側で追加
  - [Adding a Go agent to your cloud](https://docs.go.cd/16.3.0/configuration/managing_a_build_cloud.html#adding-a-go-agent-to-your-cloud)

go-agentを適切な設定で起動させた場合、GoCD Server側にてAgentホスト名を認識するはずです。認識したGoCD Agentホストを`Enable`に設定することでパイプライン処理を行わせるAgentとして使用可能な状態とします。

  1. `http://<GoCD Server>:8153/go/agents` へアクセス
  1. `Agents`に対象Agentホスト名が表示されていること
  1. 対象Agentホストの左端にあるチェックボックスにチェックする
  1. **Enable** をクリックします

