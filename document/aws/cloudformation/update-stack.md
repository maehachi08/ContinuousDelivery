# Stackテンプレートを更新する

 1. 現在のテンプレート情報を取得する

 ```sh
aws cloudformation get-template --stack-name JavaServletHelloWorld2 > template.json
```

 1. 不要なキーと値を削除する
   - 削除しないとaws cloudformation update-stack` で読み込む際にエラーとなる

 ```json
    "TemplateBody": {
        "AWSTemplateFormatVersion": "2010-09-09",
    }
```

 1. テンプレートを修正する
 
 1. テンプレートのバリデーションチェックを実施する
 
 ```sh
aws cloudformation validate-template --template-body file://template.json
```

 1. Stackを更新する

 ```sh
aws cloudformation update-stack --stack-name JavaServletHelloWorld2 --template-body file://template.json
```

