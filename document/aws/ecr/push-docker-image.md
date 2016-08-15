# ECRレポジトリへのDockerマシンイメージの登録手順

*ECR(Amazon EC2 Container Registry)* で作成したコンテナレポジトリに対してDcokerコンテナイメージを保存する手順を記載する。レポジトリは、[ECRレポジトリの作成手順](create-repository.md) で作成済みであることを前提とする。


## dockerマシンイメージのビルド

 1. 本レポジトリをcloneし、dockerディレクトリまで移動

 ```sh
git clone git@github.com:maehachi08/docker.git
cd docker/build/JavaServletHelloWorld/
ls -l Dockerfile
```

 1. docker buildを実行

 ```sh
docker build -t maehachi08/java-servlet-hello-world ./
```

## ECRへログイン

 1. `docker login`コマンドの取得

 Docker Hubなどと同様にECRへの接続にはログインを行う必要がある。

 ただし、Docker Hubの様にUsernameとPasswordの入力ではなく、ECR独自のログイン方法が提供されており、自身のECRレポジトリへの接続に使用する `docker login` コマンドを出力する。

 ```sh
aws ecr get-login --region us-east-1
```

 上記コマンド実行例を以下に示す(パスワード文字列はマスク)。

 ```sh
[root@localhost ~]# aws ecr get-login --region us-east-1
docker login -u AWS -p <長いパスワード文字列>  -e none https://00000000000000000000.dkr.ecr.us-east-1.amazonaws.com
```

 1. ECRログイン

 上記作業で取得した`docker login`コマンドを実行する。

 ```sh
docker login -u AWS -p <長いパスワード文字列>  -e none https://00000000000000000000.dkr.ecr.us-east-1.amazonaws.com
```


 `docker login`コマンド実行例を以下に示す。

 ```sh
[root@localhost ~]# docker login -u AWS -p <長いパスワード文字列>  -e none https://00000000000000000000.dkr.ecr.us-east-1.amazonaws.com
WARNING: login credentials saved in /root/.docker/config.json
Login Succeeded
```

 **ECRログインを以下のようにワンライナーでも実行可能**

 ```sh
aws ecr get-login --region us-east-1 | sh
```

## dockerマシンイメージにECRのタグ付与

`docker build`した際にタグ名を付与(maehachi08/java-hello-world)していますが、あくまでローカル環境で管理するためのタグ名です。
ECRレポジトリに紐付けるためのタグを付与したdockerマシンイメージを定義する必要がある。

```sh
docker tag maehachi08/java-hello-world:latest 00000000000000000000.dkr.ecr.us-east-1.amazonaws.com/ecr-handson-httpd:latest
```

以下のように、**IMAGE IDは同じでREPOSITORYが異なるdockerマシンイメージが作成** されている。

```sh
[root@localhost ~]# docker images
REPOSITORY                                                       TAG                 IMAGE ID            CREATED             SIZE
00000000000000000000.dkr.ecr.us-east-1.amazonaws.com/ecr-handson-httpd   latest              dc9c5bba7be2        18 hours ago        569.7 MB
maehachi08/java-hello-world                                      latest              dc9c5bba7be2        18 hours ago        569.7 MB
docker.io/centos                                                 latest              970633036444        4 days ago          196.7 MB
```

## dockerマシンイメージをECRに登録

dockerマシンイメージをECRレポジトリへ登録(push)する。

```sh
docker push 00000000000000000000.dkr.ecr.us-east-1.amazonaws.com/maehachi08/java-hello-world:latest
```

実行例は以下のとおり。

```sh
[root@localhost docker]# docker push 00000000000000000000.dkr.ecr.us-east-1.amazonaws.com/maehachi08/java-hello-world:latest
The push refers to a repository [00000000000000000000.dkr.ecr.us-east-1.amazonaws.com/maehachi08/java-hello-world]
Repository does not exist: 00000000000000000000.dkr.ecr.us-east-1.amazonaws.com/maehachi08/java-hello-world
[root@localhost docker]# docker push 00000000000000000000.dkr.ecr.us-east-1.amazonaws.com/ecr-handson-httpd:latest
The push refers to a repository [00000000000000000000.dkr.ecr.us-east-1.amazonaws.com/ecr-handson-httpd]
72a1995e9596: Pushed
f79525080667: Pushed
2477ef83c786: Pushed
12a0aa2e00f4: Pushed
3b3a7dbab8f1: Pushed
06a70d7ae18c: Pushed
2f4822db960b: Pushed
0ccaacfcf54c: Pushed
69f1fc7c6ab1: Pushed
f59b7e59ceaa: Pushed
```

## dockerマシンイメージ登録確認

`docker push`コマンドでECRレポジトリにdockerマシンイメージが作成されたことを確認する。

```sh
aws ecr list-images --repository-name ecr-handson-httpd --output text
```

実行例は以下のとおり。

```sh
[root@localhost ~]# aws ecr list-images --repository-name ecr-handson-httpd --output text
IMAGEIDS        sha256:7bfc2e15b579ab7fef5883f66105dc6ff2262265a5a783d70e7882563acf4857 latest
```

