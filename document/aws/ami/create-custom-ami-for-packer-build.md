# カスタムAMIビルド環境のAMIを作る
  - [packer](https://www.packer.io/) がインストール済み
  - `packer build` に必要最低限のポリシーが存在する
    - 本項で作成するAMIを使って起動するEC2に適用するロールにアタッチするだけ

## AMIビルド

### packerファイル作成

 ```sh
vim packer_builder.json
```

 ```json
{
  "builders": [
    {
      "type": "amazon-ebs",
      "region": "ap-northeast-1",
      "vpc_id": "vpc-816262e4",
      "subnet_id": "subnet-11ded148",
      "source_ami": "ami-1a15c77b",
      "instance_type": "t2.micro",
      "associate_public_ip_address": true,
      "ssh_username": "ec2-user",
      "ssh_timeout": "5m",
      "ami_name": "packer-builder_amzn-ami-hvm-2016.09.0.20160923-x86_64-gp2 {{timestamp}}"
    }
  ],
  "provisioners": [
    {
      "type": "shell",
      "inline": [
        "sudo yum update -y",
        "sudo yum install -y wget unzip",
        "wget https://releases.hashicorp.com/packer/0.10.2/packer_0.10.2_linux_amd64.zip",
        "unzip packer_0.10.2_linux_amd64.zip",
        "sudo mv packer /usr/local/bin/"
      ]
    }
  ]
}
```

### packer build

 ```sh
packer validate packer_builder.json
packer build packer_builder.json
```

## PackerPolicy ポリシーの作成
  - https://www.packer.io/docs/builders/amazon.html
  - https://gist.github.com/MattSurabian/5976061

 Packerで必要なIAM権限をビルダーインスタンスが持っていない場合は以下のようなエラーとなる。

 ```
==> amazon-ebs: Error querying AMI: UnauthorizedOperation: You are not authorized to perform this operation.
==> amazon-ebs:         status code: 403, request id:
Build 'amazon-ebs' errored: Error querying AMI: UnauthorizedOperation: You are not authorized to perform this operation.
        status code: 403, request id:

==> Some builds didn't complete successfully and had errors:
--> amazon-ebs: Error querying AMI: UnauthorizedOperation: You are not authorized to perform this operation.
        status code: 403, request id:
```

 従って、Packerビルドに必要なポリシーを定義しインスタンスロールにアタッチする必要がある。

 ```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PackerSecurityGroupAccess",
            "Action": [
                "ec2:CreateSecurityGroup",
                "ec2:DeleteSecurityGroup",
                "ec2:DescribeSecurityGroups",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupIngress"
            ],
            "Effect": "Allow",
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "PackerAMIAccess",
            "Action": [
                "ec2:CreateImage",
                "ec2:RegisterImage",
                "ec2:DeregisterImage",
                "ec2:DescribeImages"
            ],
            "Effect": "Allow",
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "PackerSnapshotAccess",
            "Action": [
                "ec2:CreateSnapshot",
                "ec2:DeleteSnaphot",
                "ec2:DescribeSnapshots"
            ],
            "Effect": "Allow",
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "PackerInstanceAccess",
            "Action": [
                "ec2:RunInstances",
                "ec2:StartInstances",
                "ec2:StopInstances",
                "ec2:RebootInstances",
                "ec2:TerminateInstances",
                "ec2:DescribeInstances",
                "ec2:CreateTags"
            ],
            "Effect": "Allow",
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "PackerKeyPairAccess",
            "Action": [
                "ec2:CreateKeyPair",
                "ec2:DeleteKeyPair",
                "ec2:DescribeKeyPairs"
            ],
            "Effect": "Allow",
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "PackerS3Access",
            "Action": [
                "s3:Get*",
                "s3:List*",
                "s3:PutObject*",
                "s3:DeleteObject*"
            ],
            "Effect": "Allow",
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "PackerS3BucketAccess",
            "Action": [
                "s3:ListAllMyBuckets",
                "s3:CreateBucket"
            ],
            "Effect": "Allow",
            "Resource": [
                "*"
            ]
        }
    ]
}
```


