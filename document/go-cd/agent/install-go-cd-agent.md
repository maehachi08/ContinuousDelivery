#  GoCD Agentのインストール

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

## GoCD Agentインストール

```sh
sudo yum install -y go-agent
```

