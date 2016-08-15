#  GoCD Agent 環境準備

## git インストール

 GitHubレポジトリをポーリング対象とする場合、エージェントにgitコマンドをインストールする必要がある。

 ```sh
yum install -y git
```

## docker-engine インストール

 1. yum repo定義ファイルを作成する

 ```sh
sudo tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/6/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
```

 1. docker-engine をインストールする

 ```sh
sudo yum install docker-engine
```

sudo service docker start
```

