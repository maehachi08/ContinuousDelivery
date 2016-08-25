# StackのChange Sets

 refs [AWS CloudFormation Adds Change Sets for Insight into Stack Updates](https://aws.amazon.com/jp/about-aws/whats-new/2016/03/aws-cloudformation-adds-change-sets-for-insight-into-stack-updates/)


## Change Setsとは

 CloudFormationのStackテンプレートを更新する際に、現在のStackと更新後のStackの差分情報(どのようなリソースが削除・追加・変更など)を確認するためのものです。Change Setsを作成し、差分情報を確認した上で、問題なければ適用(Execute)することが可能です。

## Change Sets 作成

 ```sh
aws cloudformation create-change-set --stack-name <Stack名> --template-body <更新済みのStackテンプレートデータ(json) --change-set-name <Stack Change Sets名>
```

 実行するとChange SetsのARN情報が表示されます。

 ```sh
[root@ ~]# aws cloudformation create-change-set --stack-name JavaServletHelloWorld2 --template-body file://template.json --change-set-name changeset001
{
    "Id": "arn:aws:cloudformation:us-east-1:XXXXXXXXXXXXXXX:changeSet/changeset001/63678b64-2fd4-445b-bbcd-ae92ece8bc3f"
}
```

## Change Setsの適用(Execute)

 ```
aws cloudformation execute-change-set --change-set-name <Stack Change Sets名> --stack-name <Stack名>
```

