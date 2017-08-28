# Docker 17.03 でどう変わったのか

  * Hasteで使用しているECS Instanceでは最近dockerバージョンを上げました
     * docker 1.11 -> 1.12
     * docker 1.12 -> 17.03(17.03には1.13の更新が含まれる)
  * docker 1.13 -> 17.03 はリリースサイクルのルールが変わりましたが、**機能面での大きな変更は少ない**
     * 実質 17.03 は 1.13.2相当?
     * むしろ、1.11 -> 1.12、そして 1.12 -> 1.13 でのアップデートが多い

ということで、各バージョンで追加された主な機能について紹介します。

## docker 1.12

[release-notes](https://docs.docker.com/release-notes/docker-engine/#1120-2016-07-28)

Docker 1.12 では dockerデーモンとクライアントのバイナリが分離されていたり、Haste環境でもdockerd向けのオプションを追加していたり、HEALTHCHECKサポートなど直接設定変更に関わっている項目が多いバージョンです。

  * dockerd(デーモン) と docker(クライアント) が分離
  * --live-restore
     * dockerd が停止してもContainerが落ちない
     * **Haste ECS Instanceに設定**
  * --userland-proxy=false
     * [Docker のコンテナ間通信のベンチマーク](http://mapk0y.hatenablog.com/entry/2015/06/20/124752)
     * LINK機能の代わりとして1.7でリリースされたPublish という方法にて、proxy ソフトウェア(docker-proxy) を経由するかどうかを設定可能になりfalse(経由しない)の場合にパフォーマンスが向上するらしい
     * **Haste ECS Instanceに設定**
  * Dockerfile での HEALTHCHECKコマンド定義がサポート
  * overlay2 graphdriver サポート
     * overlay はｉノード増大とパフォーマンス維持に対する限界があるとのこと
     * overlay2 は上記の限界に対応している(Linux カーネル 4.0 以降にのみ対応)
  * docker pluginコマンド サポート
  * Swarm 機能が統合(docker swarm)

## docker 1.13

[release-notes](https://docs.docker.com/release-notes/docker-engine/#1130-2017-01-18)

Docker 1.13 では、overlay2/overlay がデフォルトストレージドライバになったり、Swarmモード（クラスタ構築）の強化やコンテナのスナップショット機能が取り入れられており、取り込まれた機能が豊富な印象。

  * デフォルトのストレージドライバーが devicemapperから overlay2/overlay へ変更(1.13.1)
     * kernelサポートによる
  * Build時にキャッシュとして使用するImage指定が可能に
  * Dockerfile での MAINTAINER が廃止
  * Implement XFS quota for overlay2
  * docker checkpoint(experimental)
     * Containerのsnapshot機能
     * Live migration向けではない
  * docker build --squash (experimental)
     * FROMのImageとBuildするレイヤーを統合できるらしい
  * docker system prune
     * docker {container,image,volume,network} prune

## docker 17.03

2017/03/01 リリースされた 17.03.0-ce からリリースサイクルとバージョニングが変更
  * [ここは詳細](https://www.creationline.com/lab/16393)
  * ce(Community Edition) と ee(Enterprise Edition: Docker社のサポート有)
  * YYYY.MM versioning
  * two release cycle
     1. monthly release
        * Edge版と言われるセキュリティフィクスとバグフィクス
        * 次の monthly release が利用可能になるまでセキュリティフィクスとバグフィクスのみが提供
        * Edge
     2. quarterly release
        * 安定版リリース
        * Stable

### 17.03.0-ce

[release-notes](https://docs.docker.com/release-notes/docker-ce/#17030-ce-2017-03-01)

   * 1.13.1 に対するbug fix版
   * 大きな機能追加はなく、API versionも変更なし
      * `Upgrading from Docker 1.13.1 to 17.03.0 is expected to be simple and low-risk.` だそうです

### 17.03.1-ce

[release-notes](https://docs.docker.com/release-notes/docker-ce/#17031-ce-2017-03-27)

   * `docker volume rm -f` コマンド実行時に "volume in use" エラーを無視しない
   * restore() を呼ぶ前にヘルスチェックサービスを登録する
     * http://qiita.com/wizpra-koyasu/items/9300450ad417015c0a2d

