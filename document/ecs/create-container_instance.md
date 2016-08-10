# コンテナインスタンス作成

## セキュリティグループを作成

 1. セキュリティグループを新規作成

 ```sh
aws ec2 create-security-group \
  --group-name web \
  --description "web port" \
  --vpc-id vpc-0f8dec68
```

 実行結果は以下のとおり。

 ```sh
[root@localhost aws]# aws ec2 create-security-group \
>   --group-name web \
>   --description "web port" \
>   --vpc-id vpc-0f8dec68
{
    "GroupId": "sg-c029c6ba"
}
```

 1. インバウンドの許可設定

 ```sh
aws ec2 authorize-security-group-ingress \
  --group-id sg-c029c6ba \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
  --group-id sg-c029c6ba \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0
```

 1. 作成したセキュリティグループを確認

 ```sh
aws ec2 describe-security-groups --group-id sg-c029c6ba
```

 実行結果は以下のとおり。

 ```sh
[root@localhost aws]# aws ec2 describe-security-groups --group-id sg-c029c6ba
{
    "SecurityGroups": [
        {
            "IpPermissionsEgress": [
                {
                    "IpProtocol": "-1",
                    "IpRanges": [
                        {
                            "CidrIp": "0.0.0.0/0"
                        }
                    ],
                    "UserIdGroupPairs": [],
                    "PrefixListIds": []
                }
            ],
            "Description": "web port",
            "IpPermissions": [
                {
                    "PrefixListIds": [],
                    "FromPort": 80,
                    "IpRanges": [
                        {
                            "CidrIp": "0.0.0.0/0"
                        }
                    ],
                    "ToPort": 80,
                    "IpProtocol": "tcp",
                    "UserIdGroupPairs": []
                },
                {
                    "PrefixListIds": [],
                    "FromPort": 22,
                    "IpRanges": [
                        {
                            "CidrIp": "0.0.0.0/0"
                        }
                    ],
                    "ToPort": 22,
                    "IpProtocol": "tcp",
                    "UserIdGroupPairs": []
                }
            ],
            "GroupName": "web",
            "VpcId": "vpc-0f8dec68",
            "OwnerId": "375144106126",
            "GroupId": "sg-c029c6ba"
        }
    ]
}
```

## インスタンスプロファイルの作成
  - [コンテナインスタンス用のロール作成](https://github.com/maehachi08/aws-ecs-ecr-test/blob/master/document/ecs/create-role-for-container_instance.md) で作成したロールを紐付けてコンテナインスタンスに適用する


 ```sh
aws iam create-instance-profile \
  --instance-profile-name web

aws iam add-role-to-instance-profile \
  --instance-profile-name web \
  --role-name ecsInstanceRole
```

 実行結果は以下のとおり。

 ```sh
[root@localhost aws]# aws iam create-instance-profile \
>   --instance-profile-name web
{
    "InstanceProfile": {
        "InstanceProfileId": "AIPAJCIBNFMYSE6W5PDZK",
        "Roles": [],
        "CreateDate": "2016-08-03T06:56:27.784Z",
        "InstanceProfileName": "web",
        "Path": "/",
        "Arn": "arn:aws:iam::375144106126:instance-profile/web"
    }
}

[root@localhost aws]# aws iam add-role-to-instance-profile \
>   --instance-profile-name web \
>   --role-name ecsInstanceRole
```

## コンテナインスタンス作成

 1. user dataファイルを作成

 ```sh
cat << EOT > user_data.sh
#!/bin/bash
echo ECS_CLUSTER=JavaTomcatCluster >> /etc/ecs/ecs.config

sudo wget -O /usr/local/bin/jq http://stedolan.github.io/jq/download/linux64/jq
sudo chmod 755 /usr/local/bin/jq

sudo yum install -y aws-cli ruby
aws s3 cp s3://aws-codedeploy-us-east-1/latest/install . --region us-east-1
sudo chmod +x ./install
sudo ./install auto

EOT
```

 1. コンテナインスタンスを起動
   - バージニア北米リージョンにおけるコンテナインスタンス用AMI(ami-55870742)を指定すること

 ```sh
aws ec2 run-instances --image-id ami-55870742 \
  --instance-type t2.micro \
  --count 1 \
  --key-name HelloWorld \
  --iam-instance-profile Name=web \
  --security-group-ids sg-c029c6ba \
  --user-data  file://user_data.sh \
  --subnet subnet-eacbc0d7 \
  --associate-public-ip-address
```

 実行結果は以下のとおり。

 ```sh
[root@localhost aws]# aws ec2 run-instances --image-id ami-55870742 \
>   --instance-type t2.micro \
>   --count 1 \
>   --key-name HelloWorld \
>   --iam-instance-profile Name=web \
>   --security-group-ids sg-c029c6ba \
>   --user-data  file://user_data.sh \
>   --subnet subnet-eacbc0d7 \
>   --associate-public-ip-address
{
    "OwnerId": "375144106126",
    "ReservationId": "r-9584b56c",
    "Groups": [],
    "Instances": [
        {
            "Monitoring": {
                "State": "disabled"
            },
            "PublicDnsName": "",
            "RootDeviceType": "ebs",
            "State": {
                "Code": 0,
                "Name": "pending"
            },
            "EbsOptimized": false,
            "LaunchTime": "2016-08-03T07:30:07.000Z",
            "PrivateIpAddress": "172.30.3.245",
            "ProductCodes": [],
            "VpcId": "vpc-0f8dec68",
            "StateTransitionReason": "",
            "InstanceId": "i-10c154e8",
            "ImageId": "ami-55870742",
            "PrivateDnsName": "ip-172-30-3-245.ec2.internal",
            "KeyName": "HelloWorld",
            "SecurityGroups": [
                {
                    "GroupName": "web",
                    "GroupId": "sg-c029c6ba"
                }
            ],
            "ClientToken": "",
            "SubnetId": "subnet-eacbc0d7",
            "InstanceType": "t2.micro",
            "NetworkInterfaces": [
                {
                    "Status": "in-use",
                    "MacAddress": "06:4d:eb:23:ff:6d",
                    "SourceDestCheck": true,
                    "VpcId": "vpc-0f8dec68",
                    "Description": "",
                    "NetworkInterfaceId": "eni-0355600f",
                    "PrivateIpAddresses": [
                        {
                            "Primary": true,
                            "PrivateIpAddress": "172.30.3.245"
                        }
                    ],
                    "Attachment": {
                        "Status": "attaching",
                        "DeviceIndex": 0,
                        "DeleteOnTermination": true,
                        "AttachmentId": "eni-attach-76a2868f",
                        "AttachTime": "2016-08-03T07:30:07.000Z"
                    },
                    "Groups": [
                        {
                            "GroupName": "web",
                            "GroupId": "sg-c029c6ba"
                        }
                    ],
                    "SubnetId": "subnet-eacbc0d7",
                    "OwnerId": "375144106126",
                    "PrivateIpAddress": "172.30.3.245"
                }
            ],
            "SourceDestCheck": true,
            "Placement": {
                "Tenancy": "default",
                "GroupName": "",
                "AvailabilityZone": "us-east-1e"
            },
            "Hypervisor": "xen",
            "BlockDeviceMappings": [],
            "Architecture": "x86_64",
            "StateReason": {
                "Message": "pending",
                "Code": "pending"
            },
            "IamInstanceProfile": {
                "Id": "AIPAJCIBNFMYSE6W5PDZK",
                "Arn": "arn:aws:iam::375144106126:instance-profile/web"
            },
            "RootDeviceName": "/dev/xvda",
            "VirtualizationType": "hvm",
            "AmiLaunchIndex": 0
        }
    ]
}
```

