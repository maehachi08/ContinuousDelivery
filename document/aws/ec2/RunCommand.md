# Amazon EC2 Run Command

## Amazon EC2 Run Command とは
  - EC2インスタンスにマネージメントコンソール、またはaws cli経由で任意のコマンドを実行するもの
    - [Amazon EC2 Run Command を使用したコマンドの実行](http://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/run-command.html)
    - [Amazon EC2 Run Command を使用したシェルスクリプトの実行](http://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/remote-commands-shellcript.html)
    - [Amazon EC2 Run Command を使用した Amazon SSM エージェントの更新](http://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/remote-commands-updatessmagent.html)
    - [Amazon EC2 Run Command の前提条件](http://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/remote-commands-prereq.html)
    - [SSM エージェントのインストール](http://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/install-ssm-agent.html)

## Amazon EC2 Run Commandを実行するための準備

### SSMエージェント インストール
  - Amazon EC2 Simple Systems Manager (SSM) エージェント をEC2インスタンスにインストールする
    - http://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/install-ssm-agent.html
    - バージニアリージョン(us-east-1) を想定

 ```sh
mkdir /tmp/ssm
curl https://amazon-ssm-us-east-1.s3.amazonaws.com/latest/linux_amd64/amazon-ssm-agent.rpm -o /tmp/ssm/amazon-ssm-agent.rpm
yum install -y /tmp/ssm/amazon-ssm-agent.rpm
status amazon-ssm-agent
```

 ```sh
[root@ip-172-30-3-156 ~]# status amazon-ssm-agent
amazon-ssm-agent start/running, process 6788
```

 ```sh
[root@ip-172-30-3-156 ~]# ps auxfww | grep [a]mazon-ssm-agent
root      6788  0.0  1.4 214876 14756 ?        Ssl  Sep07   0:06 /usr/bin/amazon-ssm-agent
```

### AmazonEC2RoleforSSM ポリシーのアタッチ
  - EC2インスタンス用ロールに `AmazonEC2RoleforSSM` ポリシーをアタッチする
  - [Amazon EC2 Run Command へのアクセスの委任](http://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/delegate-commands.html)
  - [東京リージョンでEC2 Run Command (Linux)を使ってみました](http://xp-cloud.jp/blog/2016/01/27/1248/)


  ECSインスタンス用のロールとして作成した `ecsInstanceRole` ロールに色々アタッチしているけれど、`AmazonEC2RoleforSSM` ポリシーがアタッチされていることを確認しました。

 ```sh
[root@ip-172-30-3-156 ~]# aws iam list-attached-role-policies --role-name ecsInstanceRole
{
    "AttachedPolicies": [
        {
            "PolicyName": "AmazonEC2FullAccess",
            "PolicyArn": "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
        },
        {
            "PolicyName": "AmazonEC2RoleforSSM",
            "PolicyArn": "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
        },
        {
            "PolicyName": "AWSOpsWorksFullAccess",
            "PolicyArn": "arn:aws:iam::aws:policy/AWSOpsWorksFullAccess"
        },
        {
            "PolicyName": "AmazonEC2ContainerRegistryFullAccess",
            "PolicyArn": "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
        },
        {
            "PolicyName": "AmazonS3FullAccess",
            "PolicyArn": "arn:aws:iam::aws:policy/AmazonS3FullAccess"
        },
        {
            "PolicyName": "AWSCodeDeployFullAccess",
            "PolicyArn": "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess"
        },
        {
            "PolicyName": "AmazonEC2ContainerServiceFullAccess",
            "PolicyArn": "arn:aws:iam::aws:policy/AmazonEC2ContainerServiceFullAccess"
        },
        {
            "PolicyName": "AWSOpsWorksInstanceRegistration",
            "PolicyArn": "arn:aws:iam::aws:policy/AWSOpsWorksInstanceRegistration"
        },
        {
            "PolicyName": "AmazonEC2ContainerServiceforEC2Role",
            "PolicyArn": "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
        },
        {
            "PolicyName": "AWSCodePipelineFullAccess",
            "PolicyArn": "arn:aws:iam::aws:policy/AWSCodePipelineFullAccess"
        }
    ]
}
```

## Amazon EC2 Run Commandを実行するための確認
  - [AWS CLI を使用した Amazon EC2 Run Command のチュートリアル](http://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/walkthrough-cli.html)

### 実行したいドキュメントの確認
  - Linuxコマンドを実行するためのドキュメントである `AWS-RunShellScript` を確認する

 ```sh
aws ssm list-documents \
  --query 'DocumentIdentifiers[?Name==`AWS-RunShellScript`]'
```

 ```sh
[root@ip-172-30-3-156 ~]# aws ssm list-documents --query 'DocumentIdentifiers[?Name==`AWS-RunShellScript`]'
[
    {
        "Owner": "Amazon",
        "Name": "AWS-RunShellScript",
        "PlatformTypes": [
            "Linux"
        ]
    }
]
```

### AWS-RunShellScript で必要なパラメータについて確認

 ```sh
aws ssm describe-document --name "AWS-RunShellScript"
```

 ```sh
[root@ip-172-30-3-156 ~]# aws ssm describe-document --name "AWS-RunShellScript"
{
    "Document": {
        "Status": "Active",
        "Sha1": "d071a804cd33ddfba965ec572c0e78483e2361b9",
        "Hash": "d071a804cd33ddfba965ec572c0e78483e2361b9",
        "Name": "AWS-RunShellScript",
        "Parameters": [
            {
                "Type": "StringList",
                "Name": "commands",
                "Description": "(Required) Specify a shell script or a command to run."
            },
            {
                "DefaultValue": "\"\"",
                "Type": "String",
                "Name": "workingDirectory",
                "Description": "(Optional) The path to the working directory on your instance."
            },
            {
                "DefaultValue": "\"3600\"",
                "Type": "String",
                "Name": "executionTimeout",
                "Description": "(Optional) The time in seconds for a command to complete before it is considered to have failed. Default is 3600 (1 hour). Maximum is 28800 (8 hours)."
            }
        ],
        "PlatformTypes": [
            "Linux"
        ],
        "HashType": "Sha1",
        "CreatedDate": 1450205444.426,
        "Owner": "Amazon",
        "Description": "Run a shell script or specify the commands to run."
    }
}
```


### マネージドインスタンスの確認
  - `SSMエージェント` が起動しているインスタンスが認識される

 ```sh
aws ssm describe-instance-information --query "InstanceInformationList[*]"
```

 ```sh
[root@ip-172-30-3-156 ~]# aws ssm describe-instance-information --query "InstanceInformationList[*]"
[
    {
        "IsLatestVersion": true,
        "ComputerName": "ip-172-30-3-156",
        "PingStatus": "Online",
        "InstanceId": "i-ac315a54",
        "IPAddress": "172.30.3.156",
        "ResourceType": "EC2Instance",
        "AgentVersion": "1.2.298.0",
        "PlatformVersion": "2016.03",
        "PlatformName": "Amazon Linux AMI",
        "PlatformType": "Linux",
        "LastPingDateTime": 1473301942.607
    }
]
```

## Amazon EC2 Run Commandを実行する

### コマンドを実行する

 ```sh
INSTANCE_IDS=i-ac315a54
aws ssm send-command --instance-ids ${INSTANCE_IDS} \
  --document-name AWS-RunShellScript \
  --comment "Test Command" \
  --parameters commands=ifconfig \
  --output text
```

 ```sh
[root@ip-172-30-3-156 ~]# aws ssm send-command --instance-ids ${INSTANCE_ID} \
>   --document-name AWS-RunShellScript \
>   --comment "Test Command" \
>   --parameters commands=ifconfig \
>   --output text
COMMAND 0c42b99d-7397-4d40-b1cd-6ff39202a60a    Test Command    AWS-RunShellScript      1473303247.24   1473302647.24       Pending
INSTANCEIDS     i-ac315a54
COMMANDS        ifconfig
```

### コマンド結果を確認する

#### 詳細を確認する

 1. JSON形式で確認するとコマンド標準出力が改行されないので少々見ずらい

 ```sh
COOMAND_ID=0c42b99d-7397-4d40-b1cd-6ff39202a60a
aws ssm list-command-invocations --command-id ${COOMAND_ID} --details
```

 ```sh
[root@ip-172-30-3-156 ~]# COOMAND_ID=0c42b99d-7397-4d40-b1cd-6ff39202a60a
[root@ip-172-30-3-156 ~]# aws ssm list-command-invocations --command-id ${COOMAND_ID} --details
{
    "CommandInvocations": [
        {
            "Comment": "Test Command",
            "Status": "Success",
            "CommandPlugins": [
                {
                    "Status": "Success",
                    "Name": "aws:runShellScript",
                    "ResponseCode": 0,
                    "Output": "docker0   Link encap:Ethernet  HWaddr 02:42:4E:54:07:9F  \n          inet addr:172.17.0.1  Bcast:0.0.0.0  Mask:255.255.0.0\n          inet6 addr: fe80::42:4eff:fe54:79f/64 Scope:Link\n          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1\n          RX packets:702383 errors:0 dropped:0 overruns:0 frame:0\n          TX packets:749479 errors:0 dropped:0 overruns:0 carrier:0\n          collisions:0 txqueuelen:0 \n          RX bytes:74060137 (70.6 MiB)  TX bytes:212673508 (202.8 MiB)\n\neth0      Link encap:Ethernet  HWaddr 06:54:BA:1A:37:0B  \n          inet addr:172.30.3.156  Bcast:172.30.3.255  Mask:255.255.255.0\n          inet6 addr: fe80::454:baff:fe1a:370b/64 Scope:Link\n          UP BROADCAST RUNNING MULTICAST  MTU:9001  Metric:1\n          RX packets:2478692 errors:0 dropped:0 overruns:0 frame:0\n          TX packets:1598865 errors:0 dropped:0 overruns:0 carrier:0\n          collisions:0 txqueuelen:1000 \n          RX bytes:1710792502 (1.5 GiB)  TX bytes:544268644 (519.0 MiB)\n\nlo        Link encap:Local Loopback  \n          inet addr:127.0.0.1  Mask:255.0.0.0\n          inet6 addr: ::1/128 Scope:Host\n          UP LOOPBACK RUNNING  MTU:65536  Metric:1\n          RX packets:3488 errors:0 dropped:0 overruns:0 frame:0\n          TX packets:3488 errors:0 dropped:0 overruns:0 carrier:0\n          collisions:0 txqueuelen:1 \n          RX bytes:701054 (684.6 KiB)  TX bytes:701054 (684.6 KiB)\n\nveth72d522e Link encap:Ethernet  HWaddr 42:8D:7B:71:EB:3C  \n          inet6 addr: fe80::408d:7bff:fe71:eb3c/64 Scope:Link\n          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1\n          RX packets:245027 errors:0 dropped:0 overruns:0 frame:0\n          TX packets:252358 errors:0 dropped:0 overruns:0 carrier:0\n          collisions:0 txqueuelen:0 \n          RX bytes:29201239 (27.8 MiB)  TX bytes:21842542 (20.8 MiB)\n\nvethe7d2798 Link encap:Ethernet  HWaddr 3A:E2:18:57:1E:3C  \n          inet6 addr: fe80::38e2:18ff:fe57:1e3c/64 Scope:Link\n          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1\n          RX packets:247270 errors:0 dropped:0 overruns:0 frame:0\n          TX packets:252509 errors:0 dropped:0 overruns:0 carrier:0\n          collisions:0 txqueuelen:0 \n          RX bytes:29470298 (28.1 MiB)  TX bytes:21888048 (20.8 MiB)\n\n",
                    "ResponseFinishDateTime": 1473302647.553,
                    "ResponseStartDateTime": 1473302647.546
                }
            ],
            "InstanceId": "i-ac315a54",
            "DocumentName": "AWS-RunShellScript",
            "CommandId": "0c42b99d-7397-4d40-b1cd-6ff39202a60a",
            "RequestedDateTime": 1473302647.237
        }
    ]
}
```

 1. text形式で確認すると多少見やすい

 ```
COOMAND_ID=0c42b99d-7397-4d40-b1cd-6ff39202a60a
aws ssm list-command-invocations --command-id ${COOMAND_ID} --details --output text
```

 ```sh
[root@ip-172-30-3-156 ~]# COOMAND_ID=0c42b99d-7397-4d40-b1cd-6ff39202a60a
[root@ip-172-30-3-156 ~]# aws ssm list-command-invocations --command-id ${COOMAND_ID} --details --output text
COMMANDINVOCATIONS      0c42b99d-7397-4d40-b1cd-6ff39202a60a    Test Command    AWS-RunShellScript      i-ac315a54  1473302647.24   Success
COMMANDPLUGINS  aws:runShellScript      docker0   Link encap:Ethernet  HWaddr 02:42:4E:54:07:9F
          inet addr:172.17.0.1  Bcast:0.0.0.0  Mask:255.255.0.0
          inet6 addr: fe80::42:4eff:fe54:79f/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:702383 errors:0 dropped:0 overruns:0 frame:0
          TX packets:749479 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:74060137 (70.6 MiB)  TX bytes:212673508 (202.8 MiB)

eth0      Link encap:Ethernet  HWaddr 06:54:BA:1A:37:0B
          inet addr:172.30.3.156  Bcast:172.30.3.255  Mask:255.255.255.0
          inet6 addr: fe80::454:baff:fe1a:370b/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:9001  Metric:1
          RX packets:2478692 errors:0 dropped:0 overruns:0 frame:0
          TX packets:1598865 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:1710792502 (1.5 GiB)  TX bytes:544268644 (519.0 MiB)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:3488 errors:0 dropped:0 overruns:0 frame:0
          TX packets:3488 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1
          RX bytes:701054 (684.6 KiB)  TX bytes:701054 (684.6 KiB)

veth72d522e Link encap:Ethernet  HWaddr 42:8D:7B:71:EB:3C
          inet6 addr: fe80::408d:7bff:fe71:eb3c/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:245027 errors:0 dropped:0 overruns:0 frame:0
          TX packets:252358 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:29201239 (27.8 MiB)  TX bytes:21842542 (20.8 MiB)

vethe7d2798 Link encap:Ethernet  HWaddr 3A:E2:18:57:1E:3C
          inet6 addr: fe80::38e2:18ff:fe57:1e3c/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:247270 errors:0 dropped:0 overruns:0 frame:0
          TX packets:252509 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:29470298 (28.1 MiB)  TX bytes:21888048 (20.8 MiB)

        0       1473302647.55   1473302647.55   Success
```

#### 実行Linuxコマンドの標準出力だけ確認する
  - `CommandInvocations` > `CommandPlugins` > `Output` に入る

 ```sh
COOMAND_ID=0c42b99d-7397-4d40-b1cd-6ff39202a60a
aws ssm list-command-invocations \
  --command-id ${COOMAND_ID} \
  --query 'CommandInvocations[].CommandPlugins[][Output]' \
  --details \
  --output text
```

 ```sh
[root@ip-172-30-3-156 ~]# COOMAND_ID=0c42b99d-7397-4d40-b1cd-6ff39202a60a
[root@ip-172-30-3-156 ~]# aws ssm list-command-invocations \
>   --command-id ${COOMAND_ID} \
>   --query 'CommandInvocations[].CommandPlugins[][Output]' \
>   --details \
>   --output text
docker0   Link encap:Ethernet  HWaddr 02:42:4E:54:07:9F
          inet addr:172.17.0.1  Bcast:0.0.0.0  Mask:255.255.0.0
          inet6 addr: fe80::42:4eff:fe54:79f/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:702383 errors:0 dropped:0 overruns:0 frame:0
          TX packets:749479 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:74060137 (70.6 MiB)  TX bytes:212673508 (202.8 MiB)

eth0      Link encap:Ethernet  HWaddr 06:54:BA:1A:37:0B
          inet addr:172.30.3.156  Bcast:172.30.3.255  Mask:255.255.255.0
          inet6 addr: fe80::454:baff:fe1a:370b/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:9001  Metric:1
          RX packets:2478692 errors:0 dropped:0 overruns:0 frame:0
          TX packets:1598865 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:1710792502 (1.5 GiB)  TX bytes:544268644 (519.0 MiB)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:3488 errors:0 dropped:0 overruns:0 frame:0
          TX packets:3488 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1
          RX bytes:701054 (684.6 KiB)  TX bytes:701054 (684.6 KiB)

veth72d522e Link encap:Ethernet  HWaddr 42:8D:7B:71:EB:3C
          inet6 addr: fe80::408d:7bff:fe71:eb3c/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:245027 errors:0 dropped:0 overruns:0 frame:0
          TX packets:252358 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:29201239 (27.8 MiB)  TX bytes:21842542 (20.8 MiB)

vethe7d2798 Link encap:Ethernet  HWaddr 3A:E2:18:57:1E:3C
          inet6 addr: fe80::38e2:18ff:fe57:1e3c/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:247270 errors:0 dropped:0 overruns:0 frame:0
          TX packets:252509 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:29470298 (28.1 MiB)  TX bytes:21888048 (20.8 MiB)
```


## 特定のタグを持つインスタンスに対してコマンド実行
  - `aws ec2 describe-instances` コマンドで特定のタグを持つインスタンスIDを抽出する
  - 1回の`aws ssm send-command` コマンドで複数ホストにコマンドを実行しても **SSM上のコマンドIDは1つ**
    - `aws ssm list-command-invocations --command-id　<コマンドID>` で全ホストの結果が入る
  - 1回の`aws ssm send-command` コマンドで指定可能なインスタンスIDは50個まで

### コマンド実行

 ```sh
INSTANCE_IDS=`aws ec2 describe-instances \
  --filter "Name=instance-state-name,Values=running" \
    "Name=tag-key,Values=name" \
    "Name=tag-value,Values=HelloWorld" \
  --query 'Reservations[].Instances[][InstanceId]' \
  --output text`

aws ssm send-command --instance-ids ${INSTANCE_IDS} \
  --document-name AWS-RunShellScript \
  --comment "Test Command" \
  --parameters commands=ifconfig \
  --output text
```

 ```sh
[root@ip-172-30-3-156 ~]# INSTANCE_IDS=`aws ec2 describe-instances \
>   --filter "Name=instance-state-name,Values=running" \
>     "Name=tag-key,Values=name" \
>     "Name=tag-value,Values=HelloWorld" \
>   --query 'Reservations[].Instances[][InstanceId]' \
>   --output text`
[root@ip-172-30-3-156 ~]#
[root@ip-172-30-3-156 ~]# aws ssm send-command --instance-ids ${INSTANCE_IDS} \
>   --document-name AWS-RunShellScript \
>   --comment "Test Command" \
>   --parameters commands=ifconfig \
>   --output text
COMMAND f03b941d-586c-4608-8a57-e8b6554697f8    Test Command    AWS-RunShellScript      1473305744.32   1473305144.32       Pending
INSTANCEIDS     i-839c47b2
INSTANCEIDS     i-ac315a54
COMMANDS        ifconfig
```

### コマンド結果の確認

 ```sh
[root@ip-172-30-3-156 ~]# COOMAND_ID=f03b941d-586c-4608-8a57-e8b6554697f8
[root@ip-172-30-3-156 ~]# aws ssm list-command-invocations --command-id ${COOMAND_ID} --query 'CommandInvocations[].CommandPlugins[][Output]' --details --output text
docker0   Link encap:Ethernet  HWaddr 02:42:E3:C3:B0:9D
          inet addr:172.17.0.1  Bcast:0.0.0.0  Mask:255.255.0.0
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)

eth0      Link encap:Ethernet  HWaddr 12:DD:BE:FB:BD:1F
          inet addr:172.30.2.97  Bcast:172.30.2.255  Mask:255.255.255.0
          inet6 addr: fe80::10dd:beff:fefb:bd1f/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:9001  Metric:1
          RX packets:4561 errors:0 dropped:0 overruns:0 frame:0
          TX packets:1699 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:4806104 (4.5 MiB)  TX bytes:333363 (325.5 KiB)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)


docker0   Link encap:Ethernet  HWaddr 02:42:4E:54:07:9F
          inet addr:172.17.0.1  Bcast:0.0.0.0  Mask:255.255.0.0
          inet6 addr: fe80::42:4eff:fe54:79f/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:704168 errors:0 dropped:0 overruns:0 frame:0
          TX packets:751303 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:74246889 (70.8 MiB)  TX bytes:212827216 (202.9 MiB)

eth0      Link encap:Ethernet  HWaddr 06:54:BA:1A:37:0B
          inet addr:172.30.3.156  Bcast:172.30.3.255  Mask:255.255.255.0
          inet6 addr: fe80::454:baff:fe1a:370b/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:9001  Metric:1
          RX packets:2490702 errors:0 dropped:0 overruns:0 frame:0
          TX packets:1611304 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:1713628585 (1.5 GiB)  TX bytes:546881271 (521.5 MiB)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:3488 errors:0 dropped:0 overruns:0 frame:0
          TX packets:3488 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1
          RX bytes:701054 (684.6 KiB)  TX bytes:701054 (684.6 KiB)

veth72d522e Link encap:Ethernet  HWaddr 42:8D:7B:71:EB:3C
          inet6 addr: fe80::408d:7bff:fe71:eb3c/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:245922 errors:0 dropped:0 overruns:0 frame:0
          TX packets:253276 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:29307465 (27.9 MiB)  TX bytes:21920072 (20.9 MiB)

vethe7d2798 Link encap:Ethernet  HWaddr 3A:E2:18:57:1E:3C
          inet6 addr: fe80::38e2:18ff:fe57:1e3c/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:248160 errors:0 dropped:0 overruns:0 frame:0
          TX packets:253415 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:29575814 (28.2 MiB)  TX bytes:21964226 (20.9 MiB)


```
