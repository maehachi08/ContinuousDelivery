#  GoCD Server用EC2インスタンスの作成
  - GoCD Serverのデフォルトリッスンポートである `TCP/8153` を開放する
  - SSH key pairは作成済みの `HelloWorld` を指定する

## セキュリティグループ作成
  - `aws ec2 create-security-group` コマンド結果からセキュリティグループIDを取得し、`aws ec2 authorize-security-group-ingress` コマンドで使用する。


 ```sh
sg_id=`aws ec2 create-security-group \
--group-name gocd-server \
--description "for go cd server" \
--vpc-id vpc-0f8dec68 | jq -r '.GroupId'`

aws ec2 authorize-security-group-ingress \
--group-id ${sg_id} \
--protocol tcp \
--port 22 \
--cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
--group-id ${sg_id} \
--protocol tcp \
--port 8153 \
--cidr 0.0.0.0/0
```

## EC2インスタンス作成
  - 作成したSGを割り当てる
  - `CentOS 6.4 x86_64 - with updates - G2 support - ami-7199b818` を使用
    - 起動後に `yum update` を実施し最新カーネルにあげる

 ```sh
aws ec2 run-instances --image-id ami-7199b818 \
--instance-type t2.micro \
--count 1 \
--key-name HelloWorld \
--security-group-ids ${sg_id} \
--subnet subnet-eacbc0d7 \
--associate-public-ip-address
```

