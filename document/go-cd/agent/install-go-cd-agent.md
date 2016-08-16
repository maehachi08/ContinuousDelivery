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
