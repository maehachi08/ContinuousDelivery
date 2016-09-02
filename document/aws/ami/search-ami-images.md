# AMIイメージの検索

 AMI-IDが分からない状態から特定のAMI Imagesを探す

## (WIP) 新しいecs-optimized AMIがリリースされたことを検知する
  - `aws ec2 describe-images` で(今使ってるAMIより)作成日が新しいものを探す
  - [Amazon ECS-optimized AMI](http://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/ecs-optimized_AMI.html#ecs-optimized_AMI_launch_latest)をスクレイピングして `AMI ID` の値が更新されていないかチェックする

## Nameに `amazon-ecs-optimized` が含まれるAMI

 ```sh
aws ec2 describe-images --owners self amazon \
  --filters "Name=root-device-type,Values=ebs,Name=name,Values=*amazon-ecs-optimized"
```

## Nameに `amazon-ecs-optimized` が含まれる `2016-08-19T00:30:39` に作成されたAMI

 ```sh
aws ec2 describe-images --owners self amazon \
  --filters "Name=root-device-type,Values=ebs,Name=name,Values=*amazon-ecs-optimized,Name=creation-date,Values=2016-08-19T00:30:39.000Z"
```

 ```sh
[root@ip-172-30-3-156 ami]# aws ec2 describe-images --owners self amazon --filters "Name=root-device-type,Values=ebs,Name=name,Values=*amazon-ecs-optimized,Name=creation-date,Values=2016-08-19T00:30:39.000Z"
{
    "Images": [
        {
            "VirtualizationType": "hvm",
            "Name": "amzn-ami-2016.03.h-amazon-ecs-optimized",
            "Hypervisor": "xen",
            "ImageOwnerAlias": "amazon",
            "EnaSupport": true,
            "SriovNetSupport": "simple",
            "ImageId": "ami-6bb2d67c",
            "State": "available",
            "BlockDeviceMappings": [
                {
                    "DeviceName": "/dev/xvda",
                    "Ebs": {
                        "DeleteOnTermination": true,
                        "SnapshotId": "snap-8b8ec570",
                        "VolumeSize": 8,
                        "VolumeType": "gp2",
                        "Encrypted": false
                    }
                },
                {
                    "DeviceName": "/dev/xvdcz",
                    "Ebs": {
                        "DeleteOnTermination": true,
                        "Encrypted": false,
                        "VolumeSize": 22,
                        "VolumeType": "gp2"
                    }
                }
            ],
            "Architecture": "x86_64",
            "ImageLocation": "amazon/amzn-ami-2016.03.h-amazon-ecs-optimized",
            "RootDeviceType": "ebs",
            "OwnerId": "591542846629",
            "RootDeviceName": "/dev/xvda",
            "CreationDate": "2016-08-19T00:30:39.000Z",
            "Public": true,
            "ImageType": "machine",
            "Description": "Amazon Linux AMI 2016.03.h x86_64 ECS HVM GP2"
        }
    ]
}
```


