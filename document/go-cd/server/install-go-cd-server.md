#  GoCD Serverのインストール

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

## GoCD Serverインストール

```sh
sudo yum install -y go-server
```

### インストール中のデーモン起動に失敗するが問題なし

 `sudo yum install -y go-server` を実行した際に、自身のホスト名が名前解決できない時に以下エラーが出る可能性があります。あとで対応するのでここでは無視で大丈夫です。

 ```
Error starting Go Server.
warning: %post(go-server-16.7.0-3819.noarch) scriptlet failed, exit status 255
Non-fatal POSTIN scriptlet failure in rpm package go-server-16.7.0-3819.noarch
  Verifying  : go-server-16.7.0-3819.noarch                                                                                                     1/1

Installed:
  go-server.noarch 0:16.7.0-3819

Complete!
```

#### エラーの原因

 RPMパッケージをビルドする際のspecファイルにて定義している `%post` スクリプト処理が失敗していることが原因です。インストール済みのRPMパッケージの `%post`スクリプトの処理内容はrpmコマンドで確認できます。

 ```sh
rpm -q --scripts go-server
```

## 自ホストを名前解決できるようにする

 `/etc/hosts` に追記するなりDNS参照させるなりし、GoCD Server自身のホスト名を名前解決できるようにしましょう。名前解決できない場合、GoCD Serverサービス起動に失敗し、以下エラーが表示されます。

 ```
ERROR: Failed to start Go server. Please check the logs.
java.lang.RuntimeException: ip-172-30-3-34: ip-172-30-3-34: Name or service not known
        at com.thoughtworks.go.util.ExceptionUtils.bomb(ExceptionUtils.java:36)
```

## GoCD Server起動

 ```sh
service go-server status
service go-server start
service go-server status
```

 コマンド実行結果は以下のとおりです。

 ```sh
[root@ip-172-30-3-34 ~]# service go-server status
Go Server is stopped.
[root@ip-172-30-3-34 ~]# service go-server start
[Mon Aug  8 19:22:28 PDT 2016] using default settings from /etc/default/go-server
Started Go Server on http://ip-172-30-3-34:8153/go
[root@ip-172-30-3-34 ~]# service go-server status
Go Server is running.
```

## GO CD ServerへのWebアクセス
  - `TCP/8153` ポートへアクセス
  - トップページアクセスが、`/go`  
  - `http://<GoCD Server>:8153/go`

