# Docker Remote APIの公開

  dockerはデフォルトではUnixドメインソケッのみでListenするため、外部ホストからdocker操作ができないので、Docker APIを外部公開できるように設定する。

  1. Listenポート設定

 ```sh
vim /etc/sysconfig/docker
```

 ```
OPTIONS="-H tcp://0.0.0.0:2376 -H unix:///var/run/docker.sock"
```

  1. docker再起動

 ```sh
service docker restart
```

  1. Listenポートの確認

 ```sh
netstat -antp | grep docker
```

 ```sh
[root@ip-10-171-158-221 ~]# netstat -antp | grep docker
tcp        0      0 :::2376                     :::*                        LISTEN      6382/docker
```



