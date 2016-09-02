# PackerでAWS AMIを作成する
  - https://www.packer.io/docs/builders/amazon.html
  - https://www.packer.io/docs/builders/amazon-ebs.html

## 要件
  1. [Amazon ECS-optimized AMI](http://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/ecs-optimized_AMI.html)をSourceとして使用する
  1. 要件に従い、初期構築済みのAMIイメージを作成できること
  1. *Amazon ECS-optimized AMIがアップデートされたら新しいAMIを再ビルド* を自動的に行えること


## Packerのインストール
  - [公式のダウンロードページ](https://www.packer.io/downloads.html)
  - [クレデンシャル情報をセットする](https://www.packer.io/docs/builders/amazon.html#specifying-amazon-credentials)

 ```sh
wget https://releases.hashicorp.com/packer/0.10.1/packer_0.10.1_linux_amd64.zip
unzip packer_0.10.1_linux_amd64.zip
mv packer /usr/local/bin/
packer version
```

 `packer version`コマンドで以下のように表示されればOKです。

 ```sh
[root@ip-172-30-3-156 packer]# packer version
Packer v0.10.1
```

## テンプレートの作成
  - Packerでビルドに使用する定義のJSONデータ

 1. テンプレートファイルを作成する
   - `vpc_id`と`subnet_id`を指定しないと以下エラーになるので要注意

 ```
==> amazon-ebs: Error launching source instance: InvalidParameterCombination: VPC security groups may not be used for a non-VPC launch
==> amazon-ebs:         status code: 400, request id:
```

 ```sh
cat << EOT > packer_ecs-optimized_custom.json
{
  "builders": [
    {
      "type": "amazon-ebs",
      "region": "us-east-1",
      "vpc_id": "vpc-0f8dec68",
      "subnet_id": "subnet-eacbc0d7",
      "source_ami": "ami-6bb2d67c",
      "instance_type": "t2.micro",
      "ssh_username": "ec2-user",
      "ssh_timeout": "5m",
      "ami_name": "maehata_amzn-ami-2016.03.h-amazon-ecs-optimized {{timestamp}}"
    }
  ],
  "provisioners": [
    {
      "type": "shell",
      "inline": [
        "sudo yum -y update",
        "sudo yum install -y wget",
        "echo ECS_CLUSTER=JavaTomcatCluster | sudo tee -a /etc/ecs/ecs.config",
        "sudo wget -O /usr/local/bin/jq http://stedolan.github.io/jq/download/linux64/jq",
        "sudo chmod 755 /usr/local/bin/jq",
        "sudo yum install -y aws-cli ruby",
        "wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install",
        "chmod +x ./install",
        "sudo ./install auto"
      ]
    }
  ]
}
EOT
```

 1. 作成したテンプレートファイルのバリデーションチェックを実行する

 ```sh
packer validate  packer_ecs-optimized_custom.json
```

 以下のように `Template validated successfully.` と表示されればOKです。

 ```sh
[root@ip-172-30-3-156 packer]# packer validate  packer_ecs-optimized_custom.json
Template validated successfully.
```

## AMIを作成する

 ```sh
packer build packer_ecs-optimized_custom.json
```

 実行ログを全文ペロッと貼ります。

 ```sh
[root@ip-172-30-3-156 packer]# packer build packer_ecs-optimized_custom.json
amazon-ebs output will be in this color.

==> amazon-ebs: Prevalidating AMI Name...
==> amazon-ebs: Inspecting the source AMI...
==> amazon-ebs: Creating temporary keypair: packer 57c8f5c8-f7f6-350b-a51c-43c2e8f821ba
==> amazon-ebs: Creating temporary security group for this instance...
==> amazon-ebs: Authorizing access to port 22 the temporary security group...
==> amazon-ebs: Launching a source AWS instance...
    amazon-ebs: Instance ID: i-5e2f59a6
==> amazon-ebs: Waiting for instance (i-5e2f59a6) to become ready...
==> amazon-ebs: Waiting for SSH to become available...
==> amazon-ebs: Connected to SSH!
==> amazon-ebs: Provisioning with shell script: /tmp/packer-shell486070916
    amazon-ebs: Loaded plugins: priorities, update-motd, upgrade-helper
    amazon-ebs: Resolving Dependencies
    amazon-ebs: --> Running transaction check
    amazon-ebs: ---> Package kernel.x86_64 0:4.4.19-29.55.amzn1 will be installed
    amazon-ebs: ---> Package python27.x86_64 0:2.7.10-4.122.amzn1 will be updated
    amazon-ebs: ---> Package python27.x86_64 0:2.7.12-2.120.amzn1 will be an update
    amazon-ebs: ---> Package python27-libs.x86_64 0:2.7.10-4.122.amzn1 will be updated
    amazon-ebs: ---> Package python27-libs.x86_64 0:2.7.12-2.120.amzn1 will be an update
    amazon-ebs: --> Finished Dependency Resolution
    amazon-ebs:
    amazon-ebs: Dependencies Resolved
    amazon-ebs:
    amazon-ebs: ================================================================================
    amazon-ebs: Package            Arch        Version                 Repository         Size
    amazon-ebs: ================================================================================
    amazon-ebs: Installing:
    amazon-ebs: kernel             x86_64      4.4.19-29.55.amzn1      amzn-updates       16 M
    amazon-ebs: Updating:
    amazon-ebs: python27           x86_64      2.7.12-2.120.amzn1      amzn-updates      102 k
    amazon-ebs: python27-libs      x86_64      2.7.12-2.120.amzn1      amzn-updates      6.8 M
    amazon-ebs:
    amazon-ebs: Transaction Summary
    amazon-ebs: ================================================================================
    amazon-ebs: Install  1 Package
    amazon-ebs: Upgrade  2 Packages
    amazon-ebs:
    amazon-ebs: Total download size: 23 M
    amazon-ebs: Downloading packages:
    amazon-ebs: --------------------------------------------------------------------------------
    amazon-ebs: Total                                               14 MB/s |  23 MB  00:01
    amazon-ebs: Running transaction check
    amazon-ebs: Running transaction test
    amazon-ebs: Transaction test succeeded
    amazon-ebs: Running transaction
    amazon-ebs: Updating   : python27-2.7.12-2.120.amzn1.x86_64                           1/5
    amazon-ebs: Updating   : python27-libs-2.7.12-2.120.amzn1.x86_64                      2/5
    amazon-ebs: Installing : kernel-4.4.19-29.55.amzn1.x86_64                             3/5
    amazon-ebs: Cleanup    : python27-2.7.10-4.122.amzn1.x86_64                           4/5
    amazon-ebs: Cleanup    : python27-libs-2.7.10-4.122.amzn1.x86_64                      5/5
    amazon-ebs: Verifying  : python27-libs-2.7.12-2.120.amzn1.x86_64                      1/5
    amazon-ebs: Verifying  : python27-2.7.12-2.120.amzn1.x86_64                           2/5
    amazon-ebs: Verifying  : kernel-4.4.19-29.55.amzn1.x86_64                             3/5
    amazon-ebs: Verifying  : python27-libs-2.7.10-4.122.amzn1.x86_64                      4/5
    amazon-ebs: Verifying  : python27-2.7.10-4.122.amzn1.x86_64                           5/5
    amazon-ebs:
    amazon-ebs: Installed:
    amazon-ebs: kernel.x86_64 0:4.4.19-29.55.amzn1
    amazon-ebs:
    amazon-ebs: Updated:
    amazon-ebs: python27.x86_64 0:2.7.12-2.120.amzn1
    amazon-ebs: python27-libs.x86_64 0:2.7.12-2.120.amzn1
    amazon-ebs:
    amazon-ebs: Complete!
    amazon-ebs: Loaded plugins: priorities, update-motd, upgrade-helper
    amazon-ebs: Existing lock /var/run/yum.pid: another copy is running as pid 10376.
    amazon-ebs: Another app is currently holding the yum lock; waiting for it to exit...
    amazon-ebs: The other application is: yum
    amazon-ebs: Memory :  37 M RSS (247 MB VSZ)
    amazon-ebs: Started: Fri Sep  2 03:47:34 2016 - 00:01 ago
    amazon-ebs: State  : Running, pid: 10376
    amazon-ebs: Resolving Dependencies
    amazon-ebs: --> Running transaction check
    amazon-ebs: ---> Package wget.x86_64 0:1.18-1.18.amzn1 will be installed
    amazon-ebs: --> Processing Dependency: libpsl.so.0()(64bit) for package: wget-1.18-1.18.amzn1.x86_64
    amazon-ebs: --> Running transaction check
    amazon-ebs: ---> Package libpsl.x86_64 0:0.6.2-1.2.amzn1 will be installed
    amazon-ebs: --> Processing Dependency: libicuuc.so.50()(64bit) for package: libpsl-0.6.2-1.2.amzn1.x86_64
    amazon-ebs: --> Running transaction check
    amazon-ebs: ---> Package libicu.x86_64 0:50.1.2-11.12.amzn1 will be installed
    amazon-ebs: --> Finished Dependency Resolution
    amazon-ebs:
    amazon-ebs: Dependencies Resolved
    amazon-ebs:
    amazon-ebs: ================================================================================
    amazon-ebs: Package      Arch         Version                     Repository          Size
    amazon-ebs: ================================================================================
    amazon-ebs: Installing:
    amazon-ebs: wget         x86_64       1.18-1.18.amzn1             amzn-updates       980 k
    amazon-ebs: Installing for dependencies:
    amazon-ebs: libicu       x86_64       50.1.2-11.12.amzn1          amzn-main          9.6 M
    amazon-ebs: libpsl       x86_64       0.6.2-1.2.amzn1             amzn-main           52 k
    amazon-ebs:
    amazon-ebs: Transaction Summary
    amazon-ebs: ================================================================================
    amazon-ebs: Install  1 Package (+2 Dependent packages)
    amazon-ebs:
    amazon-ebs: Total download size: 11 M
    amazon-ebs: Installed size: 27 M
    amazon-ebs: Downloading packages:
    amazon-ebs: --------------------------------------------------------------------------------
    amazon-ebs: Total                                               13 MB/s |  11 MB  00:00
    amazon-ebs: Running transaction check
    amazon-ebs: Running transaction test
    amazon-ebs: Transaction test succeeded
    amazon-ebs: Running transaction
    amazon-ebs: Installing : libicu-50.1.2-11.12.amzn1.x86_64                             1/3
    amazon-ebs: Installing : libpsl-0.6.2-1.2.amzn1.x86_64                                2/3
    amazon-ebs: Installing : wget-1.18-1.18.amzn1.x86_64                                  3/3
    amazon-ebs: Verifying  : libpsl-0.6.2-1.2.amzn1.x86_64                                1/3
    amazon-ebs: Verifying  : libicu-50.1.2-11.12.amzn1.x86_64                             2/3
    amazon-ebs: Verifying  : wget-1.18-1.18.amzn1.x86_64                                  3/3
    amazon-ebs:
    amazon-ebs: Installed:
    amazon-ebs: wget.x86_64 0:1.18-1.18.amzn1
    amazon-ebs:
    amazon-ebs: Dependency Installed:
    amazon-ebs: libicu.x86_64 0:50.1.2-11.12.amzn1       libpsl.x86_64 0:0.6.2-1.2.amzn1
    amazon-ebs:
    amazon-ebs: Complete!
    amazon-ebs: ECS_CLUSTER=JavaTomcatCluster
    amazon-ebs: --2016-09-02 03:47:40--  http://stedolan.github.io/jq/download/linux64/jq
    amazon-ebs: Resolving stedolan.github.io (stedolan.github.io)... 151.101.20.133
    amazon-ebs: Connecting to stedolan.github.io (stedolan.github.io)|151.101.20.133|:80... connected.
    amazon-ebs: HTTP request sent, awaiting response... 200 OK
    amazon-ebs: Length: 497799 (486K) [application/octet-stream]
    amazon-ebs: Saving to: ‘/usr/local/bin/jq’
    amazon-ebs:
    amazon-ebs: 0K .......... .......... .......... .......... .......... 10% 2.54M 0s
    amazon-ebs: 50K .......... .......... .......... .......... .......... 20% 3.97M 0s
    amazon-ebs: 100K .......... .......... .......... .......... .......... 30%  556M 0s
    amazon-ebs: 150K .......... .......... .......... .......... .......... 41% 2.65M 0s
    amazon-ebs: 200K .......... .......... .......... .......... .......... 51%  457M 0s
    amazon-ebs: 250K .......... .......... .......... .......... .......... 61%  640M 0s
    amazon-ebs: 300K .......... .......... .......... .......... .......... 71%  559M 0s
    amazon-ebs: 350K .......... .......... .......... .......... .......... 82% 4.03M 0s
    amazon-ebs: 400K .......... .......... .......... .......... .......... 92%  569M 0s
    amazon-ebs: 450K .......... .......... .......... ......               100%  516M=0.06s
    amazon-ebs:
    amazon-ebs: 2016-09-02 03:47:41 (7.58 MB/s) - ‘/usr/local/bin/jq’ saved [497799/497799]
    amazon-ebs:
    amazon-ebs: Loaded plugins: priorities, update-motd, upgrade-helper
    amazon-ebs: Resolving Dependencies
    amazon-ebs: --> Running transaction check
    amazon-ebs: ---> Package aws-cli.noarch 0:1.10.56-1.41.amzn1 will be installed
    amazon-ebs: --> Processing Dependency: python27-botocore = 1.4.46 for package: aws-cli-1.10.56-1.41.amzn1.noarch
    amazon-ebs: --> Processing Dependency: python27-jmespath = 0.9.0 for package: aws-cli-1.10.56-1.41.amzn1.noarch
    amazon-ebs: --> Processing Dependency: python27-rsa >= 3.1.2-4.7 for package: aws-cli-1.10.56-1.41.amzn1.noarch
    amazon-ebs: --> Processing Dependency: python27-docutils >= 0.10 for package: aws-cli-1.10.56-1.41.amzn1.noarch
    amazon-ebs: --> Processing Dependency: python27-colorama >= 0.2.5 for package: aws-cli-1.10.56-1.41.amzn1.noarch
    amazon-ebs: --> Processing Dependency: python27-futures >= 2.2.0 for package: aws-cli-1.10.56-1.41.amzn1.noarch
    amazon-ebs: --> Processing Dependency: /etc/mime.types for package: aws-cli-1.10.56-1.41.amzn1.noarch
    amazon-ebs: ---> Package ruby.noarch 1:2.0-0.3.amzn1 will be installed
    amazon-ebs: --> Processing Dependency: ruby20 for package: 1:ruby-2.0-0.3.amzn1.noarch
    amazon-ebs: --> Running transaction check
    amazon-ebs: ---> Package mailcap.noarch 0:2.1.31-2.7.amzn1 will be installed
    amazon-ebs: ---> Package python27-botocore.noarch 0:1.4.46-1.58.amzn1 will be installed
    amazon-ebs: --> Processing Dependency: python27-dateutil >= 2.1 for package: python27-botocore-1.4.46-1.58.amzn1.noarch
    amazon-ebs: ---> Package python27-colorama.noarch 0:0.2.5-1.7.amzn1 will be installed
    amazon-ebs: ---> Package python27-docutils.noarch 0:0.11-1.15.amzn1 will be installed
    amazon-ebs: --> Processing Dependency: python27-imaging for package: python27-docutils-0.11-1.15.amzn1.noarch
    amazon-ebs: ---> Package python27-futures.noarch 0:3.0.3-1.3.amzn1 will be installed
    amazon-ebs: ---> Package python27-jmespath.noarch 0:0.9.0-1.11.amzn1 will be installed
    amazon-ebs: --> Processing Dependency: python27-ply >= 3.4 for package: python27-jmespath-0.9.0-1.11.amzn1.noarch
    amazon-ebs: ---> Package python27-rsa.noarch 0:3.4.1-1.8.amzn1 will be installed
    amazon-ebs: --> Processing Dependency: python27-pyasn1 >= 0.1.3 for package: python27-rsa-3.4.1-1.8.amzn1.noarch
    amazon-ebs: ---> Package ruby20.x86_64 0:2.0.0.648-1.29.amzn1 will be installed
    amazon-ebs: --> Processing Dependency: ruby20-libs(x86-64) = 2.0.0.648-1.29.amzn1 for package: ruby20-2.0.0.648-1.29.amzn1.x86_64
    amazon-ebs: --> Processing Dependency: rubygem20(bigdecimal) >= 1.2.0 for package: ruby20-2.0.0.648-1.29.amzn1.x86_64
    amazon-ebs: --> Processing Dependency: ruby20(rubygems) >= 2.0.14.1 for package: ruby20-2.0.0.648-1.29.amzn1.x86_64
    amazon-ebs: --> Processing Dependency: rubygem20(json) >= 1.7.7 for package: ruby20-2.0.0.648-1.29.amzn1.x86_64
    amazon-ebs: --> Processing Dependency: rubygem20(psych) >= 2.0.0 for package: ruby20-2.0.0.648-1.29.amzn1.x86_64
    amazon-ebs: --> Processing Dependency: libruby.so.2.0()(64bit) for package: ruby20-2.0.0.648-1.29.amzn1.x86_64
    amazon-ebs: --> Running transaction check
    amazon-ebs: ---> Package python27-dateutil.noarch 0:2.1-1.3.amzn1 will be installed
    amazon-ebs: ---> Package python27-imaging.x86_64 0:1.1.6-19.9.amzn1 will be installed
    amazon-ebs: --> Processing Dependency: libjpeg.so.62(LIBJPEG_6.2)(64bit) for package: python27-imaging-1.1.6-19.9.amzn1.x86_64
    amazon-ebs: --> Processing Dependency: libjpeg.so.62()(64bit) for package: python27-imaging-1.1.6-19.9.amzn1.x86_64
    amazon-ebs: --> Processing Dependency: libfreetype.so.6()(64bit) for package: python27-imaging-1.1.6-19.9.amzn1.x86_64
    amazon-ebs: ---> Package python27-ply.noarch 0:3.4-3.12.amzn1 will be installed
    amazon-ebs: ---> Package python27-pyasn1.noarch 0:0.1.7-2.9.amzn1 will be installed
    amazon-ebs: ---> Package ruby20-libs.x86_64 0:2.0.0.648-1.29.amzn1 will be installed
    amazon-ebs: ---> Package rubygem20-bigdecimal.x86_64 0:1.2.0-1.29.amzn1 will be installed
    amazon-ebs: ---> Package rubygem20-json.x86_64 0:1.8.3-1.51.amzn1 will be installed
    amazon-ebs: ---> Package rubygem20-psych.x86_64 0:2.0.0-1.29.amzn1 will be installed
    amazon-ebs: ---> Package rubygems20.noarch 0:2.0.14.1-1.29.amzn1 will be installed
    amazon-ebs: --> Processing Dependency: rubygem20(rdoc) >= 4.0.0 for package: rubygems20-2.0.14.1-1.29.amzn1.noarch
    amazon-ebs: --> Running transaction check
    amazon-ebs: ---> Package freetype.x86_64 0:2.3.11-15.14.amzn1 will be installed
    amazon-ebs: ---> Package libjpeg-turbo.x86_64 0:1.2.90-5.14.amzn1 will be installed
    amazon-ebs: ---> Package rubygem20-rdoc.noarch 0:4.2.2-1.43.amzn1 will be installed
    amazon-ebs: --> Processing Dependency: ruby20(irb) for package: rubygem20-rdoc-4.2.2-1.43.amzn1.noarch
    amazon-ebs: --> Running transaction check
    amazon-ebs: ---> Package ruby20-irb.noarch 0:2.0.0.648-1.29.amzn1 will be installed
    amazon-ebs: --> Finished Dependency Resolution
    amazon-ebs:
    amazon-ebs: Dependencies Resolved
    amazon-ebs:
    amazon-ebs: ================================================================================
    amazon-ebs: Package                Arch     Version                   Repository      Size
    amazon-ebs: ================================================================================
    amazon-ebs: Installing:
    amazon-ebs: aws-cli                noarch   1.10.56-1.41.amzn1        amzn-updates   1.0 M
    amazon-ebs: ruby                   noarch   1:2.0-0.3.amzn1           amzn-main      2.5 k
    amazon-ebs: Installing for dependencies:
    amazon-ebs: freetype               x86_64   2.3.11-15.14.amzn1        amzn-main      398 k
    amazon-ebs: libjpeg-turbo          x86_64   1.2.90-5.14.amzn1         amzn-main      144 k
    amazon-ebs: mailcap                noarch   2.1.31-2.7.amzn1          amzn-main       27 k
    amazon-ebs: python27-botocore      noarch   1.4.46-1.58.amzn1         amzn-updates   2.7 M
    amazon-ebs: python27-colorama      noarch   0.2.5-1.7.amzn1           amzn-main       23 k
    amazon-ebs: python27-dateutil      noarch   2.1-1.3.amzn1             amzn-main       92 k
    amazon-ebs: python27-docutils      noarch   0.11-1.15.amzn1           amzn-main      1.9 M
    amazon-ebs: python27-futures       noarch   3.0.3-1.3.amzn1           amzn-updates    30 k
    amazon-ebs: python27-imaging       x86_64   1.1.6-19.9.amzn1          amzn-main      428 k
    amazon-ebs: python27-jmespath      noarch   0.9.0-1.11.amzn1          amzn-updates    43 k
    amazon-ebs: python27-ply           noarch   3.4-3.12.amzn1            amzn-main      158 k
    amazon-ebs: python27-pyasn1        noarch   0.1.7-2.9.amzn1           amzn-main      112 k
    amazon-ebs: python27-rsa           noarch   3.4.1-1.8.amzn1           amzn-updates    80 k
    amazon-ebs: ruby20                 x86_64   2.0.0.648-1.29.amzn1      amzn-main       69 k
    amazon-ebs: ruby20-irb             noarch   2.0.0.648-1.29.amzn1      amzn-main       90 k
    amazon-ebs: ruby20-libs            x86_64   2.0.0.648-1.29.amzn1      amzn-main      3.7 M
    amazon-ebs: rubygem20-bigdecimal   x86_64   1.2.0-1.29.amzn1          amzn-main       79 k
    amazon-ebs: rubygem20-json         x86_64   1.8.3-1.51.amzn1          amzn-main       69 k
    amazon-ebs: rubygem20-psych        x86_64   2.0.0-1.29.amzn1          amzn-main       76 k
    amazon-ebs: rubygem20-rdoc         noarch   4.2.2-1.43.amzn1          amzn-main      581 k
    amazon-ebs: rubygems20             noarch   2.0.14.1-1.29.amzn1       amzn-main      224 k
    amazon-ebs:
    amazon-ebs: Transaction Summary
    amazon-ebs: ================================================================================
    amazon-ebs: Install  2 Packages (+21 Dependent packages)
    amazon-ebs:
    amazon-ebs: Total download size: 12 M
    amazon-ebs: Installed size: 43 M
    amazon-ebs: Downloading packages:
    amazon-ebs: --------------------------------------------------------------------------------
    amazon-ebs: Total                                              6.3 MB/s |  12 MB  00:01
    amazon-ebs: Running transaction check
    amazon-ebs: Running transaction test
    amazon-ebs: Transaction test succeeded
    amazon-ebs: Running transaction
    amazon-ebs: Installing : ruby20-libs-2.0.0.648-1.29.amzn1.x86_64                     1/23
    amazon-ebs: Installing : rubygem20-psych-2.0.0-1.29.amzn1.x86_64                     2/23
    amazon-ebs: Installing : rubygem20-bigdecimal-1.2.0-1.29.amzn1.x86_64                3/23
    amazon-ebs: Installing : rubygem20-json-1.8.3-1.51.amzn1.x86_64                      4/23
    amazon-ebs: Installing : rubygem20-rdoc-4.2.2-1.43.amzn1.noarch                      5/23
    amazon-ebs: Installing : ruby20-irb-2.0.0.648-1.29.amzn1.noarch                      6/23
    amazon-ebs: Installing : ruby20-2.0.0.648-1.29.amzn1.x86_64                          7/23
    amazon-ebs: Installing : rubygems20-2.0.14.1-1.29.amzn1.noarch                       8/23
    amazon-ebs: Installing : python27-colorama-0.2.5-1.7.amzn1.noarch                    9/23
    amazon-ebs: Installing : freetype-2.3.11-15.14.amzn1.x86_64                         10/23
    amazon-ebs: Installing : mailcap-2.1.31-2.7.amzn1.noarch                            11/23
    amazon-ebs: Installing : python27-ply-3.4-3.12.amzn1.noarch                         12/23
    amazon-ebs: Installing : python27-jmespath-0.9.0-1.11.amzn1.noarch                  13/23
    amazon-ebs: Installing : python27-futures-3.0.3-1.3.amzn1.noarch                    14/23
    amazon-ebs: Installing : python27-dateutil-2.1-1.3.amzn1.noarch                     15/23
    amazon-ebs: Installing : python27-pyasn1-0.1.7-2.9.amzn1.noarch                     16/23
    amazon-ebs: Installing : python27-rsa-3.4.1-1.8.amzn1.noarch                        17/23
    amazon-ebs: Installing : libjpeg-turbo-1.2.90-5.14.amzn1.x86_64                     18/23
    amazon-ebs: Installing : python27-imaging-1.1.6-19.9.amzn1.x86_64                   19/23
    amazon-ebs: Installing : python27-docutils-0.11-1.15.amzn1.noarch                   20/23
    amazon-ebs: Installing : python27-botocore-1.4.46-1.58.amzn1.noarch                 21/23
    amazon-ebs: Installing : aws-cli-1.10.56-1.41.amzn1.noarch                          22/23
    amazon-ebs: Installing : 1:ruby-2.0-0.3.amzn1.noarch                                23/23
    amazon-ebs: Verifying  : rubygems20-2.0.14.1-1.29.amzn1.noarch                       1/23
    amazon-ebs: Verifying  : libjpeg-turbo-1.2.90-5.14.amzn1.x86_64                      2/23
    amazon-ebs: Verifying  : python27-pyasn1-0.1.7-2.9.amzn1.noarch                      3/23
    amazon-ebs: Verifying  : ruby20-libs-2.0.0.648-1.29.amzn1.x86_64                     4/23
    amazon-ebs: Verifying  : rubygem20-rdoc-4.2.2-1.43.amzn1.noarch                      5/23
    amazon-ebs: Verifying  : 1:ruby-2.0-0.3.amzn1.noarch                                 6/23
    amazon-ebs: Verifying  : python27-dateutil-2.1-1.3.amzn1.noarch                      7/23
    amazon-ebs: Verifying  : python27-docutils-0.11-1.15.amzn1.noarch                    8/23
    amazon-ebs: Verifying  : python27-botocore-1.4.46-1.58.amzn1.noarch                  9/23
    amazon-ebs: Verifying  : python27-futures-3.0.3-1.3.amzn1.noarch                    10/23
    amazon-ebs: Verifying  : aws-cli-1.10.56-1.41.amzn1.noarch                          11/23
    amazon-ebs: Verifying  : python27-ply-3.4-3.12.amzn1.noarch                         12/23
    amazon-ebs: Verifying  : rubygem20-psych-2.0.0-1.29.amzn1.x86_64                    13/23
    amazon-ebs: Verifying  : mailcap-2.1.31-2.7.amzn1.noarch                            14/23
    amazon-ebs: Verifying  : rubygem20-bigdecimal-1.2.0-1.29.amzn1.x86_64               15/23
    amazon-ebs: Verifying  : rubygem20-json-1.8.3-1.51.amzn1.x86_64                     16/23
    amazon-ebs: Verifying  : ruby20-irb-2.0.0.648-1.29.amzn1.noarch                     17/23
    amazon-ebs: Verifying  : python27-rsa-3.4.1-1.8.amzn1.noarch                        18/23
    amazon-ebs: Verifying  : freetype-2.3.11-15.14.amzn1.x86_64                         19/23
    amazon-ebs: Verifying  : python27-colorama-0.2.5-1.7.amzn1.noarch                   20/23
    amazon-ebs: Verifying  : python27-imaging-1.1.6-19.9.amzn1.x86_64                   21/23
    amazon-ebs: Verifying  : python27-jmespath-0.9.0-1.11.amzn1.noarch                  22/23
    amazon-ebs: Verifying  : ruby20-2.0.0.648-1.29.amzn1.x86_64                         23/23
    amazon-ebs:
    amazon-ebs: Installed:
    amazon-ebs: aws-cli.noarch 0:1.10.56-1.41.amzn1        ruby.noarch 1:2.0-0.3.amzn1
    amazon-ebs:
    amazon-ebs: Dependency Installed:
    amazon-ebs: freetype.x86_64 0:2.3.11-15.14.amzn1
    amazon-ebs: libjpeg-turbo.x86_64 0:1.2.90-5.14.amzn1
    amazon-ebs: mailcap.noarch 0:2.1.31-2.7.amzn1
    amazon-ebs: python27-botocore.noarch 0:1.4.46-1.58.amzn1
    amazon-ebs: python27-colorama.noarch 0:0.2.5-1.7.amzn1
    amazon-ebs: python27-dateutil.noarch 0:2.1-1.3.amzn1
    amazon-ebs: python27-docutils.noarch 0:0.11-1.15.amzn1
    amazon-ebs: python27-futures.noarch 0:3.0.3-1.3.amzn1
    amazon-ebs: python27-imaging.x86_64 0:1.1.6-19.9.amzn1
    amazon-ebs: python27-jmespath.noarch 0:0.9.0-1.11.amzn1
    amazon-ebs: python27-ply.noarch 0:3.4-3.12.amzn1
    amazon-ebs: python27-pyasn1.noarch 0:0.1.7-2.9.amzn1
    amazon-ebs: python27-rsa.noarch 0:3.4.1-1.8.amzn1
    amazon-ebs: ruby20.x86_64 0:2.0.0.648-1.29.amzn1
    amazon-ebs: ruby20-irb.noarch 0:2.0.0.648-1.29.amzn1
    amazon-ebs: ruby20-libs.x86_64 0:2.0.0.648-1.29.amzn1
    amazon-ebs: rubygem20-bigdecimal.x86_64 0:1.2.0-1.29.amzn1
    amazon-ebs: rubygem20-json.x86_64 0:1.8.3-1.51.amzn1
    amazon-ebs: rubygem20-psych.x86_64 0:2.0.0-1.29.amzn1
    amazon-ebs: rubygem20-rdoc.noarch 0:4.2.2-1.43.amzn1
    amazon-ebs: rubygems20.noarch 0:2.0.14.1-1.29.amzn1
    amazon-ebs:
    amazon-ebs: Complete!
    amazon-ebs: --2016-09-02 03:47:45--  https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
    amazon-ebs: Resolving aws-codedeploy-us-east-1.s3.amazonaws.com (aws-codedeploy-us-east-1.s3.amazonaws.com)... 54.231.13.225
    amazon-ebs: Connecting to aws-codedeploy-us-east-1.s3.amazonaws.com (aws-codedeploy-us-east-1.s3.amazonaws.com)|54.231.13.225|:443... connected.
    amazon-ebs: HTTP request sent, awaiting response... 200 OK
    amazon-ebs: Length: 13377 (13K) []
    amazon-ebs: Saving to: ‘install’
    amazon-ebs:
    amazon-ebs: 0K .......... ...                                        100%  176M=0s
    amazon-ebs:
    amazon-ebs: 2016-09-02 03:47:46 (176 MB/s) - ‘install’ saved [13377/13377]
    amazon-ebs:
==> amazon-ebs: Stopping the source instance...
==> amazon-ebs: Waiting for the instance to stop...
==> amazon-ebs: Creating the AMI: maehata_amzn-ami-2016.03.h-amazon-ecs-optimized 1472787912
    amazon-ebs: AMI: ami-440b6353
==> amazon-ebs: Waiting for AMI to become ready...
==> amazon-ebs: Terminating the source AWS instance...
==> amazon-ebs: Cleaning up any extra volumes...
==> amazon-ebs: No volumes to clean up, skipping
==> amazon-ebs: Deleting temporary security group...
==> amazon-ebs: Deleting temporary keypair...
Build 'amazon-ebs' finished.

==> Builds finished. The artifacts of successful builds are:
--> amazon-ebs: AMIs were created:

us-east-1: ami-440b6353
```

### 作成したAMI情報を確認

 ```
aws ec2 describe-images --image-ids ami-440b6353
```

 ```json
{
    "Images": [
        {
            "VirtualizationType": "hvm",
            "Name": "maehata_amzn-ami-2016.03.h-amazon-ecs-optimized 1472787912",
            "Hypervisor": "xen",
            "EnaSupport": true,
            "SriovNetSupport": "simple",
            "ImageId": "ami-440b6353",
            "State": "available",
            "BlockDeviceMappings": [
                {
                    "DeviceName": "/dev/xvda",
                    "Ebs": {
                        "DeleteOnTermination": true,
                        "SnapshotId": "snap-f7711016",
                        "VolumeSize": 8,
                        "VolumeType": "gp2",
                        "Encrypted": false
                    }
                },
                {
                    "DeviceName": "/dev/xvdcz",
                    "Ebs": {
                        "DeleteOnTermination": true,
                        "SnapshotId": "snap-799b70e2",
                        "VolumeSize": 22,
                        "VolumeType": "gp2",
                        "Encrypted": false
                    }
                }
            ],
            "Architecture": "x86_64",
            "ImageLocation": "375144106126/maehata_amzn-ami-2016.03.h-amazon-ecs-optimized 1472787912",
            "RootDeviceType": "ebs",
            "OwnerId": "375144106126",
            "RootDeviceName": "/dev/xvda",
            "CreationDate": "2016-09-02T03:48:50.000Z",
            "Public": false,
            "ImageType": "machine"
        }
    ]
}
```

