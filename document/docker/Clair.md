# Clair

## インストール

### docker-compose

 ```sh
curl -L "https://github.com/docker/compose/releases/download/1.8.1/docker-compose-$(uname -s)-$(uname -m)" -o ./docker-compose
sudo mv ./docker-compose /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### Clair

 ```sh
mkdir -p ~/work/clair/clair_config
curl -L https://raw.githubusercontent.com/coreos/clair/master/docker-compose.yml -o ~/work/clair/docker-compose.yml
curl -L https://raw.githubusercontent.com/coreos/clair/v1.2.2/config.example.yaml -o ~/work/clair/clair_config/config.yaml

# database接続先の情報であるsource: の箇所にpostgressqlサーバの接続情報を記載する
vim ~/work/clair/clair_config/config.yaml
source: postgresql://postgres:password@postgres:5432?sslmode=disable
```

 ```sh
docker-compose up -d
#docker run --name clair_postgres -p 5432:5432 -e POSTGRES_PASSWORD=password -d postgres:latest
#docker run -p 6060-6061:6060-6061 --link clair_postgres:postgres -v /tmp:/tmp -v $PWD/clair_config:/config quay.io/coreos/clair -config=/config/config.yaml
```

### Go

```sh
sudo yum install -y golang
echo export GOROOT=/usr/lib/golang >> ~/.bash_profile
echo export GOPATH=/usr/local/gocode >> ~/.bash_profile
echo export PATH=$PATH:$GOROOT/bin:$GOPATH/bin >> ~/.bash_profile
source ~/.bash_profile
```

### analyze-local-images

 ```sh
go get -u github.com/coreos/clair/contrib/analyze-local-images
```
