# Authorization Plugin
    - https://docs.docker.com/engine/extend/plugins_authorization/

  Docker 1.10 でDockerがAuthorization Plugin機構をサポートしました。Dockerが持つTLS認証機構にて証明書のsubject common nameをユーザ名として利用し、TLS認証時にAuthenticationMethod にユーザ名をセットして認証可否を行えるものです。

## プラグイン

  dockerでは認証機構のフレームワークを提供し、プラグイン自体はサードパーティが開発するものがいくつか存在します。

  1. https://github.com/twistlock/authz
    - Twistlock社のプラグイン
    - TLSで使用する証明書のsubject nameをユーザ名にdocker apiのactionに対する認可を与えることができる
  1. https://github.com/projectatomic/docker-novolume-plugin
  1. https://github.com/projectatomic/rhel-push-plugin

## twistlock/authz を試してみる
  1. 証明書作成
  1. dockerをTLS認証で起動する
  1. authz-brokerプラグインのインストール
  1. dockerを--authorization-pluginを有効にして起動する
  1. dockerクライアントから証明書を用いてdocker操作

### 証明書作成
  - refs http://docs.docker.jp/engine/articles/https.html

### docker daemonをTLS認証で起動する
  - http://docs.docker.jp/engine/articles/https.html
  - https://docs.docker.com/v1.10/engine/reference/commandline/daemon/

### authz-brokerプラグインのインストール

### dockerを--authorization-pluginを有効にして起動する

### dockerクライアントから証明書を用いてdocker操作


