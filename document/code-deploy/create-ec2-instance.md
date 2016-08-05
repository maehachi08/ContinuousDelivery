# CodeDeploy でDcokerビルドに使用するEC2インスタンスを作成

## User Dataを準備

 ```sh
cat << EOT > install_codedeploy-agent.sh
#!/bin/bash
sudo yum install -y ruby
sudo yum install -y aws-cli

aws s3 cp s3://aws-codedeploy-us-east-1/latest/install . --region us-east-1
sudo chmod +x ./install
sudo ./install auto
EOT
```

## EC2インスタンスを起動

```
aws ec2 run-instances --image-id ami-55870742 \
--instance-type t2.micro \
--count 1 \
--key-name HelloWorld \
--iam-instance-profile Name=CodeDeployServiceProfile \
--security-group-ids sg-c029c6ba \
--user-data  file://install_codedeploy-agent.sh \
--subnet subnet-eacbc0d7 \
--associate-public-ip-address
```

 実行結果は以下のとおり。

 ```sh
[root@localhost aws]# aws ec2 run-instances --image-id ami-55870742 \
> --instance-type t2.micro \
> --count 1 \
> --key-name HelloWorld \
> --iam-instance-profile Name=CodeDeployServiceProfile \
> --security-group-ids sg-c029c6ba \
> --user-data  file://install_codedeploy-agent.sh \
> --subnet subnet-eacbc0d7 \
> --associate-public-ip-address
{
    "OwnerId": "375144106126",
    "ReservationId": "r-de457727",
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
            "LaunchTime": "2016-08-05T07:17:36.000Z",
            "PrivateIpAddress": "172.30.3.110",
            "ProductCodes": [],
            "VpcId": "vpc-0f8dec68",
            "StateTransitionReason": "",
            "InstanceId": "i-71e37589",
            "ImageId": "ami-55870742",
            "PrivateDnsName": "ip-172-30-3-110.ec2.internal",
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
                    "MacAddress": "06:57:01:d4:86:cb",
                    "SourceDestCheck": true,
                    "VpcId": "vpc-0f8dec68",
                    "Description": "",
                    "NetworkInterfaceId": "eni-553e0259",
                    "PrivateIpAddresses": [
                        {
                            "Primary": true,
                            "PrivateIpAddress": "172.30.3.110"
                        }
                    ],
                    "Attachment": {
                        "Status": "attaching",
                        "DeviceIndex": 0,
                        "DeleteOnTermination": true,
                        "AttachmentId": "eni-attach-10765ae9",
                        "AttachTime": "2016-08-05T07:17:36.000Z"
                    },
                    "Groups": [
                        {
                            "GroupName": "web",
                            "GroupId": "sg-c029c6ba"
                        }
                    ],
                    "SubnetId": "subnet-eacbc0d7",
                    "OwnerId": "375144106126",
                    "PrivateIpAddress": "172.30.3.110"
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
                "Id": "AIPAJPXS6W2SDTP2UTINW",
                "Arn": "arn:aws:iam::375144106126:instance-profile/CodeDeployServiceProfile"
            },
            "RootDeviceName": "/dev/xvda",
            "VirtualizationType": "hvm",
            "AmiLaunchIndex": 0
        }
    ]
}
```

