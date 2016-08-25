https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/protect-stack-resources.html#stack-policy-referenc
  - StackポリシーとしてAWS::CodePipeline::Pipelineを拒否するポリシーを割り当てることでCodePipelineの更新をさせないことは可能だが、Stackテンプレートで更新した内容(ステージやアクションの追加など)自体も更新されない。
  - 既存StackへのStackポリシーはaws cliからのみ追加可能

 ```sh
cat << EOF > stack-policy.json
{
  "Statement" : [
    {
      "Effect" : "Deny",
      "Action" : "Update:*",
      "Principal" : "*",
      "Resource" : "*",
      "Condition" : {
        "StringEquals" : {
          "ResourceType" : [ "AWS::CodePipeline::Pipeline" ]
        }
      }
    }
  ]
}
EOF

aws s3 cp ./stack-policy.json s3://java-servlet-hello-world-cloud-formation

aws cloudformation set-stack-policy \
  --stack-name JavaServletHelloWorld2 \
  --stack-policy-url https://s3.amazonaws.com/java-servlet-hello-world-cloud-formation/stack-policy.json
```

