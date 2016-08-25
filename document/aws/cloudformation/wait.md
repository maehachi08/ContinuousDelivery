# aws cliにおけるwait処理

 refs [AWS CLIがCloudFormationの状態遷移ポーリング(waiters)に対応しました](http://dev.classmethod.jp/cloud/aws/awscli-now-supports-cloudformation-waiters/)

## waitの種類

 ```
       o stack-create-complete

       o stack-delete-complete

       o stack-exists

       o stack-update-complete
``` 

## 使ってみる

 ```sh
aws cloudformation wait stack-exists --stack-name JavaServletHelloWorld2
```
