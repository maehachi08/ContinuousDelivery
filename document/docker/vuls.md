# Vuls


## Vulsインストール

### ec2-userのSSH鍵を生成

 ```sh
ssh-keygen -t rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```


### GOLANGのインストール

 CentOSやAmazonLinuxではRPMパッケージも公開されていますが、上記手順に従い、今回バイナリを落としてきます。

 ```sh
sudo yum -y install sqlite git gcc
wget https://storage.googleapis.com/golang/go1.6.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.6.linux-amd64.tar.gz
mkdir $HOME/go

vim /etc/profile.d/goenv.sh
source  /etc/profile.d/goenv.sh
```

 `/etc/profile.d/goenv.sh` の内容は以下の通りです。

 ```sh
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
```

 golangの動作確認を兼ねて、バージョンを確認します。

 ```sh
[ec2-user@ip-10-171-158-160 ~]$ go version
go version go1.6 linux/amd64
```



### go-cve-dictionary のインストールと脆弱性データベース情報の取得
  - https://github.com/kotakanbe/go-cve-dictionary
  - 脆弱性データベース情報の取得などを行ってくれる

 1. インストール

 ```sh
sudo mkdir /var/log/vuls
sudo chown ec2-user /var/log/vuls
sudo chmod 700 /var/log/vuls
go get github.com/kotakanbe/go-cve-dictionary
```

 1. 脆弱性データベースの取得

 ```sh
for i in {2002..2016}; do go-cve-dictionary fetchnvd -years $i; done
```

  実行ログは以下の通りで、2002年から2016年までのCVEデータを取得してくれているのが分かる。

 ```sh
[ec2-user@ip-10-171-158-160 ~]$ for i in {2002..2016}; do go-cve-dictionary fetchnvd -years $i; done
[Sep 13 05:42:56]  INFO Fetching... https://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-2002.xml.gz
 0 / 1 [-------------------------------------------------------------------------------------------]   0.00%[Sep 13 05:42:59]  INFO Fetched 6721 CVEs
[Sep 13 05:42:59]  INFO Opening DB. datafile: /home/ec2-user/cve.sqlite3
[Sep 13 05:42:59]  INFO Migrating DB
[Sep 13 05:42:59]  INFO Inserting CVEs...
 6721 / 6721 [=================================================================================] 100.00% 14s
[Sep 13 05:43:13]  INFO Refreshed 6721 Nvds.
 0 / 1 [-------------------------------------------------------------------------------------------]   0.00%[Sep 13 05:43:13]  INFO Fetching... https://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-2003.xml.gz
[Sep 13 05:43:15]  INFO Fetched 1519 CVEs
[Sep 13 05:43:15]  INFO Opening DB. datafile: /home/ec2-user/cve.sqlite3
[Sep 13 05:43:15]  INFO Migrating DB
[Sep 13 05:43:15]  INFO Inserting CVEs...
 1519 / 1519 [==================================================================================] 100.00% 4s
[Sep 13 05:43:20]  INFO Refreshed 1519 Nvds.
[Sep 13 05:43:20]  INFO Fetching... https://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-2004.xml.gz
 0 / 1 [-------------------------------------------------------------------------------------------]   0.00%[Sep 13 05:43:22]  INFO Fetched 2671 CVEs
[Sep 13 05:43:22]  INFO Opening DB. datafile: /home/ec2-user/cve.sqlite3
[Sep 13 05:43:22]  INFO Migrating DB
[Sep 13 05:43:22]  INFO Inserting CVEs...
 2671 / 2671 [==================================================================================] 100.00% 9s
[Sep 13 05:43:31]  INFO Refreshed 2671 Nvds.
 0 / 1 [-------------------------------------------------------------------------------------------]   0.00%[Sep 13 05:43:31]  INFO Fetching... https://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-2005.xml.gz
[Sep 13 05:43:34]  INFO Fetched 4685 CVEs
[Sep 13 05:43:34]  INFO Opening DB. datafile: /home/ec2-user/cve.sqlite3
[Sep 13 05:43:34]  INFO Migrating DB
[Sep 13 05:43:34]  INFO Inserting CVEs...
 4685 / 4685 [=================================================================================] 100.00% 14s
[Sep 13 05:43:48]  INFO Refreshed 4685 Nvds.
 0 / 1 [-------------------------------------------------------------------------------------------]   0.00%[Sep 13 05:43:48]  INFO Fetching... https://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-2006.xml.gz
[Sep 13 05:43:52]  INFO Fetched 7047 CVEs
[Sep 13 05:43:52]  INFO Opening DB. datafile: /home/ec2-user/cve.sqlite3
[Sep 13 05:43:52]  INFO Migrating DB
[Sep 13 05:43:52]  INFO Inserting CVEs...
 7047 / 7047 [=================================================================================] 100.00% 20s
[Sep 13 05:44:13]  INFO Refreshed 7047 Nvds.
 0 / 1 [-------------------------------------------------------------------------------------------]   0.00%[Sep 13 05:44:13]  INFO Fetching... https://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-2007.xml.gz
[Sep 13 05:44:16]  INFO Fetched 6510 CVEs
[Sep 13 05:44:16]  INFO Opening DB. datafile: /home/ec2-user/cve.sqlite3
[Sep 13 05:44:16]  INFO Migrating DB
[Sep 13 05:44:16]  INFO Inserting CVEs...
 6510 / 6510 [=================================================================================] 100.00% 19s
[Sep 13 05:44:36]  INFO Refreshed 6510 Nvds.
 0 / 1 [-------------------------------------------------------------------------------------------]   0.00%[Sep 13 05:44:36]  INFO Fetching... https://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-2008.xml.gz
[Sep 13 05:44:40]  INFO Fetched 7034 CVEs
[Sep 13 05:44:40]  INFO Opening DB. datafile: /home/ec2-user/cve.sqlite3
[Sep 13 05:44:40]  INFO Migrating DB
[Sep 13 05:44:40]  INFO Inserting CVEs...
 7034 / 7034 [=================================================================================] 100.00% 25s
[Sep 13 05:45:06]  INFO Refreshed 7034 Nvds.
 0 / 1 [-------------------------------------------------------------------------------------------]   0.00%[Sep 13 05:45:06]  INFO Fetching... https://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-2009.xml.gz
[Sep 13 05:45:10]  INFO Fetched 4888 CVEs
[Sep 13 05:45:10]  INFO Opening DB. datafile: /home/ec2-user/cve.sqlite3
[Sep 13 05:45:10]  INFO Migrating DB
[Sep 13 05:45:10]  INFO Inserting CVEs...
 4888 / 4888 [=================================================================================] 100.00% 31s
[Sep 13 05:45:42]  INFO Refreshed 4888 Nvds.
[Sep 13 05:45:42]  INFO Fetching... https://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-2010.xml.gz
 0 / 1 [-------------------------------------------------------------------------------------------]   0.00%[Sep 13 05:45:47]  INFO Fetched 4951 CVEs
[Sep 13 05:45:47]  INFO Opening DB. datafile: /home/ec2-user/cve.sqlite3
[Sep 13 05:45:47]  INFO Migrating DB
[Sep 13 05:45:47]  INFO Inserting CVEs...
 4951 / 4951 [=================================================================================] 100.00% 50s
[Sep 13 05:46:37]  INFO Refreshed 4951 Nvds.
 0 / 1 [-------------------------------------------------------------------------------------------]   0.00%[Sep 13 05:46:37]  INFO Fetching... https://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-2011.xml.gz
[Sep 13 05:46:47]  INFO Fetched 4441 CVEs
[Sep 13 05:46:47]  INFO Opening DB. datafile: /home/ec2-user/cve.sqlite3
[Sep 13 05:46:47]  INFO Migrating DB
[Sep 13 05:46:47]  INFO Inserting CVEs...
 4441 / 4441 [===============================================================================] 100.00% 2m46s
[Sep 13 05:49:35]  INFO Refreshed 4441 Nvds.
 0 / 1 [-------------------------------------------------------------------------------------------]   0.00%[Sep 13 05:49:35]  INFO Fetching... https://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-2012.xml.gz
[Sep 13 05:49:40]  INFO Fetched 5199 CVEs
[Sep 13 05:49:40]  INFO Opening DB. datafile: /home/ec2-user/cve.sqlite3
[Sep 13 05:49:40]  INFO Migrating DB
[Sep 13 05:49:40]  INFO Inserting CVEs...
 5199 / 5199 [=================================================================================] 100.00% 48s
[Sep 13 05:50:29]  INFO Refreshed 5199 Nvds.
[Sep 13 05:50:29]  INFO Fetching... https://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-2013.xml.gz
 0 / 1 [-------------------------------------------------------------------------------------------]   0.00%[Sep 13 05:50:34]  INFO Fetched 5710 CVEs
[Sep 13 05:50:34]  INFO Opening DB. datafile: /home/ec2-user/cve.sqlite3
[Sep 13 05:50:34]  INFO Migrating DB
[Sep 13 05:50:34]  INFO Inserting CVEs...
 5710 / 5710 [=================================================================================] 100.00% 46s
[Sep 13 05:51:21]  INFO Refreshed 5710 Nvds.
[Sep 13 05:51:21]  INFO Fetching... https://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-2014.xml.gz
 0 / 1 [-------------------------------------------------------------------------------------------]   0.00%[Sep 13 05:51:26]  INFO Fetched 7469 CVEs
[Sep 13 05:51:26]  INFO Opening DB. datafile: /home/ec2-user/cve.sqlite3
[Sep 13 05:51:26]  INFO Migrating DB
[Sep 13 05:51:26]  INFO Inserting CVEs...
 7469 / 7469 [=================================================================================] 100.00% 41s
[Sep 13 05:52:07]  INFO Refreshed 7469 Nvds.
 0 / 1 [-------------------------------------------------------------------------------------------]   0.00%[Sep 13 05:52:07]  INFO Fetching... https://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-2015.xml.gz
[Sep 13 05:52:11]  INFO Fetched 6320 CVEs
[Sep 13 05:52:11]  INFO Opening DB. datafile: /home/ec2-user/cve.sqlite3
[Sep 13 05:52:11]  INFO Migrating DB
[Sep 13 05:52:11]  INFO Inserting CVEs...
 6320 / 6320 [=================================================================================] 100.00% 23s
[Sep 13 05:52:35]  INFO Refreshed 6320 Nvds.
 0 / 1 [-------------------------------------------------------------------------------------------]   0.00%[Sep 13 05:52:35]  INFO Fetching... https://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-2016.xml.gz
[Sep 13 05:52:37]  INFO Fetched 3655 CVEs
[Sep 13 05:52:37]  INFO Opening DB. datafile: /home/ec2-user/cve.sqlite3
[Sep 13 05:52:37]  INFO Migrating DB
[Sep 13 05:52:37]  INFO Inserting CVEs...
 3655 / 3655 [=================================================================================] 100.00% 15s
[Sep 13 05:52:53]  INFO Refreshed 3655 Nvds.
```


### Vulsのインストール

 ```sh
go get github.com/future-architect/vuls
vim config.toml
```

 `config.toml`の内容は以下の通り。

 ```
[servers.127-0-0-1]
host    =       "127.0.0.1"
port    =       "22"
user    =       "ec2-user"
keyPath =       "/home/ec2-user/.ssh/id_rsa"
```

#### 設定ファイルチェック

 ```sh
vuls configtest
```


 ```sh
[ec2-user@ip-10-171-158-160 ~]$ vuls configtest
[Sep 13 06:13:50]  INFO [localhost] Validating Config...
[Sep 13 06:13:50]  INFO [localhost] Detecting Server/Contianer OS...
[Sep 13 06:13:50]  INFO [localhost] Detecting OS of servers...
[Sep 13 06:13:50]  INFO [localhost] (1/1) Detected: 127-0-0-1: amazon 2016.03
[Sep 13 06:13:50]  INFO [localhost] Detecting OS of containers...
[Sep 13 06:13:50]  INFO [localhost] Checking sudo configuration...
[Sep 13 06:13:50]  INFO [127-0-0-1] sudo ... OK
[Sep 13 06:13:50]  INFO [localhost] SSH-able servers are below...
127-0-0-1
```

#### スキャンに必要なパッケージの準備

 `vuls prepare` でディストリビューション毎に必要なパッケージをインストールする。

 ```
Subcommands for prepare:
        prepare          Install required packages to scan.
                                CentOS: yum-plugin-security, yum-plugin-changelog
                                Amazon: None
                                RHEL:   TODO
                                Ubuntu: None
```

 ```
vuls prepare
```

 ```sh
[ec2-user@ip-10-171-158-160 ~]$ vuls prepare
INFO[0000] Start Preparing (config: /home/ec2-user/config.toml)
[Sep 13 06:16:28]  INFO [localhost] Detecting OS...
[Sep 13 06:16:28]  INFO [localhost] Detecting OS of servers...
[Sep 13 06:16:28]  INFO [localhost] (1/1) Detected: 127-0-0-1: amazon 2016.03
[Sep 13 06:16:28]  INFO [localhost] Detecting OS of containers...
[Sep 13 06:16:28]  INFO [localhost] Installing...
[Sep 13 06:16:28]  INFO [127-0-0-1] Nothing to do
[Sep 13 06:16:28]  INFO [localhost] Success
```

## 脆弱性スキャン

 ```sh
vuls scan -cve-dictionary-dbpath=$PWD/cve.sqlite3
```

 ```sh
[ec2-user@ip-10-171-158-160 ~]$ vuls scan -cve-dictionary-dbpath=$PWD/cve.sqlite3
INFO[0000] Start scanning
INFO[0000] config: /home/ec2-user/config.toml
INFO[0000] cve-dictionary: /home/ec2-user/cve.sqlite3
[Sep 13 06:17:14]  INFO [localhost] Validating Config...
[Sep 13 06:17:14]  INFO [localhost] Detecting Server/Contianer OS...
[Sep 13 06:17:14]  INFO [localhost] Detecting OS of servers...
[Sep 13 06:17:15]  INFO [localhost] (1/1) Detected: 127-0-0-1: amazon 2016.03
[Sep 13 06:17:15]  INFO [localhost] Detecting OS of containers...
[Sep 13 06:17:15]  INFO [localhost] Checking sudo configuration...
[Sep 13 06:17:15]  INFO [127-0-0-1] sudo ... OK
[Sep 13 06:17:15]  INFO [localhost] Detecting Platforms...
[Sep 13 06:17:15]  INFO [localhost] (1/1) 127-0-0-1 is running on aws
[Sep 13 06:17:15]  INFO [localhost] Scanning vulnerabilities...
[Sep 13 06:17:15]  INFO [localhost] Check required packages for scanning...
[Sep 13 06:17:15]  INFO [localhost] Scanning vulnerable OS packages...
[Sep 13 06:17:17]  INFO [127-0-0-1] Fetching CVE details...
[Sep 13 06:17:17]  INFO [127-0-0-1] Done
[Sep 13 06:17:17]  INFO [localhost] Scanning vulnerable software specified in the CPE...
[Sep 13 06:17:17]  INFO [localhost] Reporting...
127-0-0-1 (amazon2016.03)
=========================
CVE-2016-1000110        ?
CVE-2016-6828           ?



CVE-2016-1000110
-------------
Score                   ?
NVD                     https://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2016-1000110
CVE Details             http://www.cvedetails.com/cve/CVE-2016-1000110
RHEL-CVE                https://access.redhat.com/security/cve/CVE-2016-1000110
ALAS-2016-741           https://alas.aws.amazon.com/ALAS-2016-741.html

CVE-2016-6828
-------------
Score           ?
NVD             https://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2016-6828
CVE Details     http://www.cvedetails.com/cve/CVE-2016-6828
RHEL-CVE        https://access.redhat.com/security/cve/CVE-2016-6828
ALAS-2016-740   https://alas.aws.amazon.com/ALAS-2016-740.html
```

### yum update で最新にしてみたらどうなるのか
  - `yum update` 後には引っかかっていた2件は表示されなくなった

 ```sh
sudo yum update -y
vuls scan -cve-dictionary-dbpath=$PWD/cve.sqlite3
```

 ```sh
[ec2-user@ip-10-171-158-160 ~]$ vuls scan -cve-dictionary-dbpath=$PWD/cve.sqlite3
INFO[0000] Start scanning
INFO[0000] config: /home/ec2-user/config.toml
INFO[0000] cve-dictionary: /home/ec2-user/cve.sqlite3
[Sep 13 06:20:05]  INFO [localhost] Validating Config...
[Sep 13 06:20:05]  INFO [localhost] Detecting Server/Contianer OS...
[Sep 13 06:20:05]  INFO [localhost] Detecting OS of servers...
[Sep 13 06:20:05]  INFO [localhost] (1/1) Detected: 127-0-0-1: amazon 2016.03
[Sep 13 06:20:05]  INFO [localhost] Detecting OS of containers...
[Sep 13 06:20:05]  INFO [localhost] Checking sudo configuration...
[Sep 13 06:20:05]  INFO [127-0-0-1] sudo ... OK
[Sep 13 06:20:05]  INFO [localhost] Detecting Platforms...
[Sep 13 06:20:05]  INFO [localhost] (1/1) 127-0-0-1 is running on aws
[Sep 13 06:20:05]  INFO [localhost] Scanning vulnerabilities...
[Sep 13 06:20:05]  INFO [localhost] Check required packages for scanning...
[Sep 13 06:20:05]  INFO [localhost] Scanning vulnerable OS packages...
[Sep 13 06:20:07]  INFO [127-0-0-1] Fetching CVE details...
[Sep 13 06:20:07]  INFO [127-0-0-1] Done
[Sep 13 06:20:07]  INFO [localhost] Scanning vulnerable software specified in the CPE...
[Sep 13 06:20:07]  INFO [localhost] Reporting...

127-0-0-1 (amazon2016.03)
=========================
No unsecure packages.
```


## Dockerコンテナに対する脆弱性スキャン

### ローカルホストのDockerコンテナ全台を対象にする

 `config.toml` に **containers = ["${running}"]** を追記
 
 ```
[servers.127-0-0-1]
host    =       "127.0.0.1"
port    =       "22"
user    =       "ec2-user"
keyPath =       "/home/ec2-user/.ssh/id_rsa"
containers = ["${running}"]
```


### Clair + Postgres コンテナを起動


 ```sh
mkdir -p ~/work/clair/clair_config
curl -L https://raw.githubusercontent.com/coreos/clair/master/docker-compose.yml -o ~/work/clair/docker-compose.yml
curl -L https://raw.githubusercontent.com/coreos/clair/v1.2.2/config.example.yaml -o ~/work/clair/clair_config/config.yaml

# database接続先の情報であるsource: の箇所にpostgressqlサーバの接続情報を記載する
$EDITOR work/clair/clair_config/config.yaml
source: postgresql://postgres:password@postgres:5432?sslmode=disable

# docker-composeが入っていない場合はインストール
# 今回はpipで導入
sudo easy_install pip
sudo /usr/local/bin/pip install docker-compose

docker-compose up -d
```

 実行ログは以下の通り。

 ```sh
[ec2-user@ip-10-171-158-160 clair]$ docker-compose up -d
Creating network "clair_default" with the default driver
Pulling postgres (postgres:latest)...
latest: Pulling from library/postgres
8ad8b3f87b37: Pull complete
c5f4a4b21ab6: Pull complete
ba05db8b0a52: Pull complete
47b491cd21ab: Pull complete
d70407e3e64d: Pull complete
295c246dd69f: Pull complete
89bc4bb8bcfd: Pull complete
106ff44c5f06: Pull complete
867cd91e76bb: Pull complete
a227948d6d8c: Pull complete
fc2ec20bdaf0: Pull complete
Digest: sha256:1115f095242a490cb79561124a79125e25b0595d5ae47d44fab5b4c1cd10735f
Status: Downloaded newer image for postgres:latest
Pulling clair (quay.io/coreos/clair:v1.2.2)...
v1.2.2: Pulling from coreos/clair
51f5c6a04d83: Pull complete
a3ed95caeb02: Pull complete
7004cfc6e122: Pull complete
5f37c8a7cfbd: Pull complete
e0297283ad9f: Pull complete
a7164db3234c: Pull complete
6bb08da223d8: Pull complete
c718b2eba451: Pull complete
1c2863f6f8a7: Pull complete
887883f4be35: Pull complete
9d423451ca41: Pull complete
Digest: sha256:0806ce5ebd093ae1332092de67f62871f9e3193fc7e32d1d64fd49ec646b0c67
Status: Downloaded newer image for quay.io/coreos/clair:v1.2.2
Creating clair_postgres
Creating clair_clair
```

 ```sh
[ec2-user@ip-10-171-158-160 clair]$ docker ps -a
CONTAINER ID        IMAGE                            COMMAND                  CREATED             STATUS                      PORTS               NAMES
1825f8f5db1e        quay.io/coreos/clair:v1.2.2      "clair -config /confi"   56 seconds ago      Exited (1) 54 seconds ago                       clair_clair
58f9e2f86715        postgres:latest                  "/docker-entrypoint.s"   56 seconds ago      Up 55 seconds               5432/tcp            clair_postgres
82b7caae0ec1        amazon/amazon-ecs-agent:latest   "/agent"                 About an hour ago   Up About an hour                                ecs-agent
```

### コンテナに対してスキャンに必要なパッケージの導入
  - ecs-agentコンテナだけOS判別できずエラー

 ```sh
[ec2-user@ip-10-171-158-160 ~]$ vuls prepare
INFO[0000] Start Preparing (config: /home/ec2-user/config.toml)
[Sep 13 06:34:14]  INFO [localhost] Detecting OS...
[Sep 13 06:34:14]  INFO [localhost] Detecting OS of servers...
[Sep 13 06:34:15]  INFO [localhost] (1/1) Detected: 127-0-0-1: amazon 2016.03
[Sep 13 06:34:15]  INFO [localhost] Detecting OS of containers...
[Sep 13 06:34:15]  INFO [localhost] Detected: clair_postgres@127-0-0-1: debian 8.5
[Sep 13 06:34:15] ERROR [localhost] Failed: 127-0-0-1 err: [Unknown OS Type]
[Sep 13 06:34:15]  INFO [localhost] Installing...
[Sep 13 06:34:15]  INFO [127-0-0-1_clair_postgres] apt-get update...
[Sep 13 06:34:15]  INFO [127-0-0-1] Nothing to do
[Sep 13 06:34:25]  INFO [127-0-0-1_clair_postgres] Installed: aptitude
[Sep 13 06:34:25]  INFO [localhost] Success
```


### Dockerコンテナ含めて脆弱性スキャンの実行

 ```sh
vuls scan -cve-dictionary-dbpath=$PWD/cve.sqlite3
```

 ```sh
[ec2-user@ip-10-171-158-160 ~]$ vuls scan -cve-dictionary-dbpath=$PWD/cve.sqlite3
INFO[0000] Start scanning
INFO[0000] config: /home/ec2-user/config.toml
INFO[0000] cve-dictionary: /home/ec2-user/cve.sqlite3
[Sep 13 06:41:03]  INFO [localhost] Validating Config...
[Sep 13 06:41:03]  INFO [localhost] Detecting Server/Contianer OS...
[Sep 13 06:41:03]  INFO [localhost] Detecting OS of servers...
[Sep 13 06:41:03]  INFO [localhost] (1/1) Detected: 127-0-0-1: amazon 2016.03
[Sep 13 06:41:03]  INFO [localhost] Detecting OS of containers...
[Sep 13 06:41:03]  INFO [localhost] Detected: clair_postgres@127-0-0-1: debian 8.5
[Sep 13 06:41:03] ERROR [localhost] Failed: 127-0-0-1 err: [Unknown OS Type]
[Sep 13 06:41:03]  INFO [localhost] Checking sudo configuration...
[Sep 13 06:41:04]  INFO [127-0-0-1_clair_postgres] sudo ... OK
[Sep 13 06:41:04]  INFO [127-0-0-1] sudo ... OK
[Sep 13 06:41:04]  INFO [localhost] Detecting Platforms...
[Sep 13 06:41:04]  WARN [localhost] Failed to detect platforms. err: [ec2-user@127.0.0.1:22: Failed to curl or wget to AWS instance metadata on 127-0-0-1. container: clair_postgres]
[Sep 13 06:41:04]  INFO [localhost] (1/2) 127-0-0-1 is running on aws
[Sep 13 06:41:04]  INFO [localhost] (2/2) clair_postgres on 127-0-0-1 is running on
[Sep 13 06:41:04]  INFO [localhost] Scanning vulnerabilities...
[Sep 13 06:41:04]  INFO [localhost] Check required packages for scanning...
[Sep 13 06:41:04]  INFO [localhost] Open boltDB: /home/ec2-user/cache.db
[Sep 13 06:41:04]  INFO [localhost] Scanning vulnerable OS packages...
[Sep 13 06:41:04]  INFO [127-0-0-1_clair_postgres] apt-get update...
[Sep 13 06:41:06]  INFO [127-0-0-1] Fetching CVE details...
[Sep 13 06:41:06]  INFO [127-0-0-1] Done
[Sep 13 06:41:22]  INFO [127-0-0-1_clair_postgres] Fetching CVE details...
[Sep 13 06:41:22]  INFO [127-0-0-1_clair_postgres] Done
[Sep 13 06:41:22]  INFO [localhost] Scanning vulnerable software specified in the CPE...
[Sep 13 06:41:22]  INFO [localhost] Reporting...

127-0-0-1 (amazon2016.03)
=========================
No unsecure packages.


clair_postgres / 58f9e2f86715 (debian8.5) on 127-0-0-1
======================================================
No unsecure packages.
```
