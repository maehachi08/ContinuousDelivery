# ALBへSSL証明書を組み込む

## SSL証明書の作成

 ```sh
# 期限が365日の証明書
openssl genrsa -out server.key
openssl req -x509 -nodes -new -keyout server.key -out server.crt -days 365

# 期限が30日の証明書
openssl genrsa -out server_30.key
openssl req -x509 -nodes -new -keyout server_30.key -out server_30.crt -days 30
```

## IAM へSSL証明書をアップロード
  - **aws cli のみ(マネージメントコンソールからはできない)**

 ```sh
# 期限が365日の証明書
aws iam upload-server-certificate --server-certificate-name HelloWorldSSL --certificate-body file://server.crt --private-key file://server.key

# 期限が30日の証明書
aws iam upload-server-certificate --server-certificate-name HelloWorldSSL_30 --certificate-body file://server_30.crt --private-key file://server_30.key
```

### アップロードしたSSL証明書について確認

 ```sh
[root@ip-172-30-3-156 cert]# aws iam list-server-certificates
{
    "ServerCertificateMetadataList": [
        {
            "ServerCertificateId": "ASCAJNIFXBJ4LSGDWCC5O",
            "ServerCertificateName": "HelloWorldSSL",
            "Expiration": "2017-09-01T08:46:53Z",
            "Path": "/",
            "Arn": "arn:aws:iam::123456789:server-certificate/HelloWorldSSL",
            "UploadDate": "2016-09-01T08:47:37Z"
        },
        {
            "ServerCertificateId": "ASCAJVCLFST4ST74UHIAI",
            "ServerCertificateName": "HelloWorldSSL_30",
            "Expiration": "2016-10-01T08:51:16Z",
            "Path": "/",
            "Arn": "arn:aws:iam::123456789:server-certificate/HelloWorldSSL_30",
            "UploadDate": "2016-09-01T08:51:49Z"
        }
    ]
}
```



## HTTPS(443)リスナーを30日期限のSSL証明書を使用して作成
  - http://docs.aws.amazon.com/cli/latest/reference/elbv2/create-listener.html

 ```sh
aws elbv2 create-listener \
  --load-balancer-arn arn:aws:elasticloadbalancing:us-east-1:6123456789:loadbalancer/app/HelloWorld-LB-01/e07a08b9d79708e1 \
  --protocol HTTPS --port 443 \
  --certificates CertificateArn=arn:aws:iam::6123456789:server-certificate/HelloWorldSSL_30 \
  --default-actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:us-east-1:6123456789:targetgroup/HelloWorld-LB-TARGET-01/d4bbcc2cacf13a43
```

### opensslコマンドでSSL通信確認

 ```sh
[root@ip-172-30-3-156 cert]# openssl s_client -connect helloworld-lb-01-123456789.us-east-1.elb.amazonaws.com:443
CONNECTED(00000003)
depth=0 C = XX, L = Default City, O = Default Company Ltd
verify error:num=18:self signed certificate
verify return:1
depth=0 C = XX, L = Default City, O = Default Company Ltd
verify return:1
---
Certificate chain
 0 s:/C=XX/L=Default City/O=Default Company Ltd
   i:/C=XX/L=Default City/O=Default Company Ltd
---
Server certificate
-----BEGIN CERTIFICATE-----
  .
  .
  .
-----END CERTIFICATE-----
subject=/C=XX/L=Default City/O=Default Company Ltd
issuer=/C=XX/L=Default City/O=Default Company Ltd
---
No client certificate CA names sent
Server Temp Key: ECDH, prime256v1, 256 bits
---
SSL handshake has read 1529 bytes and written 375 bytes
---
New, TLSv1/SSLv3, Cipher is ECDHE-RSA-AES128-GCM-SHA256
Server public key is 2048 bit
Secure Renegotiation IS supported
Compression: NONE
Expansion: NONE
SSL-Session:
    Protocol  : TLSv1.2
    Cipher    : ECDHE-RSA-AES128-GCM-SHA256
    Session-ID: 7B8577207871FB3D0E70267A9D08F295D0D9FF66331CD11A82A5448DF6511732
    Session-ID-ctx:
    Master-Key: 19A1751DDFB9AD91DE1BCC2CC970F267A7FAABB22A11EF69137DF99439EB37961BEACEB5873B3DF9DB1802251C3EAFF5
    Key-Arg   : None
    Krb5 Principal: None
    PSK identity: None
    PSK identity hint: None
    TLS session ticket lifetime hint: 300 (seconds)
    TLS session ticket:
    0000 - 3f ac 89 b2 96 22 8a 29-bc 90 fb bb b1 b2 ee f5   ?....".)........
    0010 - 64 46 84 86 43 38 11 b8-2b 9d f9 eb 81 be 69 bd   dF..C8..+.....i.
    0020 - 29 4c 49 14 c6 bd 92 d9-29 fc 52 50 d9 2b 63 e2   )LI.....).RP.+c.
    0030 - d5 6f bf 77 52 10 27 ff-94 96 18 52 84 8e 1b 85   .o.wR.'....R....
    0040 - d1 53 b5 14 77 b8 99 be-78 29 43 ac ea 8b 8d 4b   .S..w...x)C....K
    0050 - 0f 63 63 55 57 64 c4 e6-00 71 c0 e4 8c 46 2b ea   .ccUWd...q...F+.
    0060 - 02 4c 27 09 55 78 db 15-65 03 d5 ed 38 f6 d2 2b   .L'.Ux..e...8..+
    0070 - 2c db 7a fb fa 63 59 77-2b 98 91 74 93 f9 09 5d   ,.z..cYw+..t...]
    0080 - 34 d7 c6 98 fc 31 88 b9-82 b4 29 18 44 44 6b 59   4....1....).DDkY
    0090 - 97 38 7c 6f 80 58 f4 51-e4 19 a2 89 6d 9c 6c c4   .8|o.X.Q....m.l.
    00a0 - 07 b1 bf c0 67 fe 8e d7-c4 1a 96 3e 16 52 83 b1   ....g......>.R..

    Start Time: 1472722023
    Timeout   : 300 (sec)
    Verify return code: 18 (self signed certificate)
---
```

## HTTPS(443)リスナーを365日期限のSSL証明書を使用して更新

 ```sh
aws elbv2 modify-listener \
  --listener-arn arn:aws:elasticloadbalancing:us-east-1:123456789:listener/app/HelloWorld-LB-01/e07a08b9d79708e1/d6b2f6ed4632ce6b \
  --certificates CertificateArn=arn:aws:iam::123456789:server-certificate/HelloWorldSSL
```

### リスナーを確認する

 ```sh
[root@ip-172-30-3-156 cert]# aws elbv2 describe-listeners --listener-arns arn:aws:elasticloadbalancing:us-east-1:123456789:listener/app/HelloWorld-LB-01/e07a08b9d79708e1/74c78f7919bc0961
{
    "Listeners": [
        {
            "Protocol": "HTTPS",
            "DefaultActions": [
                {
                    "TargetGroupArn": "arn:aws:elasticloadbalancing:us-east-1:123456789:targetgroup/HelloWorld-LB-TARGET-01/d4bbcc2cacf13a43",
                    "Type": "forward"
                }
            ],
            "SslPolicy": "ELBSecurityPolicy-2015-05",
            "Certificates": [
                {
                    "CertificateArn": "arn:aws:iam::123456789:server-certificate/HelloWorldSSL"
                }
            ],
            "LoadBalancerArn": "arn:aws:elasticloadbalancing:us-east-1:123456789:loadbalancer/app/HelloWorld-LB-01/e07a08b9d79708e1",
            "Port": 443,
            "ListenerArn": "arn:aws:elasticloadbalancing:us-east-1:123456789:listener/app/HelloWorld-LB-01/e07a08b9d79708e1/74c78f7919bc0961"
        }
    ]
}
```
