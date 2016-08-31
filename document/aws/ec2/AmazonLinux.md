# AmazonLinux AMI
  - [Amazon Linuxの特徴とCentOSとの違い まとめ](http://dev.classmethod.jp/cloud/aws/amazon-linux-centos-rhel-difference/)
  - [Amazon Linux](http://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/AmazonLinuxAMIBasics.html)
  - [Amazon Linux AMI](https://aws.amazon.com/jp/amazon-linux-ami/)

## 組み込みツール

### /opt/aws/bin/ec2-metadata
 - `/opt/aws/bin/ec2-metadata` というシェルスクリプト
 - 起動しているEC2インスタンスのメタデータを取得する

  - 残念ながら、`-h` は重複していてヘルプじゃないので注意。

 ```sh
[root@ip-172-30-3-156 ~]# /opt/aws/bin/ec2-metadata -help
ec2-metadata v0.1.2
Use to retrieve EC2 instance metadata from within a running EC2 instance.
e.g. to retrieve instance id: ec2-metadata -i
                 to retrieve ami id: ec2-metadata -a
                 to get help: ec2-metadata --help
For more information on Amazon EC2 instance meta-data, refer to the documentation at
http://docs.amazonwebservices.com/AWSEC2/2008-05-05/DeveloperGuide/AESDG-chapter-instancedata.html

Usage: ec2-metadata <option>
Options:
--all                     Show all metadata information for this host (also default).
-a/--ami-id               The AMI ID used to launch this instance
-l/--ami-launch-index     The index of this instance in the reservation (per AMI).
-m/--ami-manifest-path    The manifest path of the AMI with which the instance was launched.
-n/--ancestor-ami-ids     The AMI IDs of any instances that were rebundled to create this AMI.
-b/--block-device-mapping Defines native device names to use when exposing virtual devices.
-i/--instance-id          The ID of this instance
-t/--instance-type        The type of instance to launch. For more information, see Instance Types.
-h/--local-hostname       The local hostname of the instance.
-o/--local-ipv4           Public IP address if launched with direct addressing; private IP address if launched with public addressing.
-k/--kernel-id            The ID of the kernel launched with this instance, if applicable.
-z/--availability-zone    The availability zone in which the instance launched. Same as placement
-c/--product-codes        Product codes associated with this instance.
-p/--public-hostname      The public hostname of the instance.
-v/--public-ipv4          NATted public IP Address
-u/--public-keys          Public keys. Only available if supplied at instance launch time
-r/--ramdisk-id           The ID of the RAM disk launched with this instance, if applicable.
-e/--reservation-id       ID of the reservation.
-s/--security-groups      Names of the security groups the instance is launched in. Only available if supplied at instance launch time
-d/--user-data            User-supplied data.Only available if supplied at instance launch time.
```

  - 引数なしで実行すると取得可能なメタデータをすべて表示します。

 ```sh
[root@ip-172-30-3-156 ~]# /opt/aws/bin/ec2-metadata
ami-id: ami-55870742
ami-launch-index: 0
ami-manifest-path: (unknown)
ancestor-ami-ids: not available
block-device-mapping:
         ami: /dev/xvda
         ebs1: xvdcz
         root: /dev/xvda
instance-id: i-ac315a54
instance-type: t2.micro
```

  - --user-dataオプションで初回起動時に実行したuser dataを確認できます。

 ```sh
[root@ip-172-30-3-156 ~]# /opt/aws/bin/ec2-metadata --user-data
user-data: #!/bin/bash
echo ECS_CLUSTER=JavaTomcatCluster >> /etc/ecs/ecs.config

sudo wget -O /usr/local/bin/jq http://stedolan.github.io/jq/download/linux64/jq
sudo chmod 755 /usr/local/bin/jq

sudo yum install -y aws-cli ruby
aws s3 cp s3://aws-codedeploy-us-east-1/latest/install . --region us-east-1
sudo chmod +x ./install
sudo ./install auto
```
