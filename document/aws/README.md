# AWSで継続的デリバリー

## 基本パッケージ

 ```sh
sudo yum install -y git wget golang vim-enhanced unzip gzip epel-release

# Amazon Linuxに対するbash-completionの導入
wget http://www.caliban.org/files/redhat/RPMS/noarch/bash-completion-20060301-1.noarch.rpm
sudo rpm -ivh bash-completion-20060301-1.noarch.rpm
. /etc/bash_completion
```

## aws cli

### インストール

```sh
yum install -y python python-devel python-setuptools --enablerepo=epel
easy_install pip
pip install awscli

# bash-completionでaws cliを補完する
echo complete -C '/usr/local/bin/aws_completer' aws >> ~/.bash_profile
source ~/.bash_profile
```

awsコマンドのバージョンは以下のとおり。

```sh
[root@localhost ~]# aws --version
aws-cli/1.10.51 Python/2.7.5 Linux/3.10.0-123.4.4.el7.x86_64 botocore/1.4.41
```

### アクセスキーとシークレットキーを発行する

`[認証情報] > [アクセスキー]` で*アクセスキー* と*シークレットアクセスキー* を発行する


### 環境変数をセットする
 - キー情報はマスク済み
 - リージョンをECRが使用可能なバージニア(北米)リージョンに設定

```sh
export AWS_DEFAULT_REGION='us-east-1'
export AWS_ACCESS_KEY_ID=XXXXXXXXXXXXXXXXXXXXXX
export AWS_SECRET_ACCESS_KEY=XXXXXXXXXXXXXXXXXXXXXXXXX
```

プロファイル情報を確認し、上記設定が反映されていることを確認する。

```sh
# aws configure list
      Name                    Value             Type    Location
      ----                    -----             ----    --------
   profile                <not set>             None    None
access_key     ****************XXXX              env
secret_key     ****************XXXX              env
    region                us-east-1              env    AWS_DEFAULT_REGION
```

## jqコマンドのインストール
  - https://stedolan.github.io/jq/
  - jqコマンドはJSONをいい感じに整形して出力してくれるツールです。

 ```sh
wget -o /usr/local/bin/jq http://stedolan.github.io/jq/download/linux64/jq
chmod 755 /usr/local/bin/jq
```

