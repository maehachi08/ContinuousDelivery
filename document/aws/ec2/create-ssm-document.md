# EC2 Run Commandドキュメントの作成

 ```json
{
  "schemaVersion": "1.0",
  "runtimeConfig": {
    "aws:runShellScript": {
      "properties": [
        {
          "runCommand": [
            "date >> /var/log/maehata.log",
            "uname -an >> /var/log/maehata.log",
            "ls -l >> /var/log/maehata.log"
          ],
          "workingDirectory": "/root",
          "timeoutSeconds": "300"
        }
      ]
    }
  }
}
```

  ```sh
[root@ip-172-30-3-156 ~]# aws ssm  create-association --name CommandDocument --instance-id i-ac315a54
{
    "AssociationDescription": {
        "InstanceId": "i-ac315a54",
        "Date": 1473314894.756,
        "Name": "CommandDocument",
        "Status": {
            "Date": 1473314894.756,
            "Message": "Associated with CommandDocument",
            "Name": "Associated"
        }
    }
}

[root@ip-172-30-3-156 ~]# aws ssm create-association --name CommandDocument --instance-id i-839c47b2
{
    "AssociationDescription": {
        "InstanceId": "i-839c47b2",
        "Date": 1473316033.202,
        "Name": "CommandDocument",
        "Status": {
            "Date": 1473316033.202,
            "Message": "Associated with CommandDocument",
            "Name": "Associated"
        }
    }
}
```

 ```sh

