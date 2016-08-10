# CodeDeployServiceProfile プロファイル作成手順

## プロファイル新規作成

 ```sh
aws iam create-instance-profile --instance-profile-name CodeDeployServiceProfile
```

 実行結果は以下のとおり。

 ```sh
[root@localhost aws]# aws iam create-instance-profile --instance-profile-name CodeDeployServiceProfile
{
    "InstanceProfile": {
        "InstanceProfileId": "AIPAJPXS6W2SDTP2UTINW",
        "Roles": [],
        "CreateDate": "2016-08-05T07:07:33.760Z",
        "InstanceProfileName": "CodeDeployServiceProfile",
        "Path": "/",
        "Arn": "arn:aws:iam::375144106126:instance-profile/CodeDeployServiceProfile"
    }
}
```

## CodeDeployServiceRole ロールを紐つける

 ```sh
aws iam add-role-to-instance-profile \
  --instance-profile-name CodeDeployServiceProfile \
  --role-name CodeDeployServiceRole
```

## CodeDeployServiceProfile 設定確認

 ```sh
aws iam get-instance-profile --instance-profile-name CodeDeployServiceProfile
```

 実行結果は以下のとおり。
 
 ```sh
[root@localhost aws]# aws iam get-instance-profile --instance-profile-name CodeDeployServiceProfile
{
    "InstanceProfile": {
        "InstanceProfileId": "AIPAJPXS6W2SDTP2UTINW",
        "Roles": [
            {
                "AssumeRolePolicyDocument": {
                    "Version": "2012-10-17",
                    "Statement": [
                        {
                            "Action": "sts:AssumeRole",
                            "Principal": {
                                "Service": [
                                    "codedeploy.eu-west-1.amazonaws.com",
                                    "codedeploy.ap-south-1.amazonaws.com",
                                    "codedeploy.ap-southeast-1.amazonaws.com",
                                    "codedeploy.ap-northeast-1.amazonaws.com",
                                    "codedeploy.sa-east-1.amazonaws.com",
                                    "codedeploy.eu-central-1.amazonaws.com",
                                    "codedeploy.us-west-2.amazonaws.com",
                                    "codedeploy.us-east-1.amazonaws.com",
                                    "codedeploy.ap-northeast-2.amazonaws.com",
                                    "codedeploy.ap-southeast-2.amazonaws.com",
                                    "codedeploy.us-west-1.amazonaws.com"
                                ]
                            },
                            "Effect": "Allow",
                            "Sid": ""
                        }
                    ]
                },
                "RoleId": "AROAI65D2T7WKZCQ3GXPM",
                "CreateDate": "2016-08-05T06:33:47Z",
                "RoleName": "CodeDeployServiceRole",
                "Path": "/",
                "Arn": "arn:aws:iam::375144106126:role/CodeDeployServiceRole"
            }
        ],
        "CreateDate": "2016-08-05T07:07:33Z",
        "InstanceProfileName": "CodeDeployServiceProfile",
        "Path": "/",
        "Arn": "arn:aws:iam::375144106126:instance-profile/CodeDeployServiceProfile"
    }
}
```

