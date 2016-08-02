# dockerビルドとコンテナ起動

```sh
docker build -t maehachi08/java-hello-world ./
docker run --privileged -d -p 80:80 --name test maehachi08/java-hello-world:latest /sbin/init
```


