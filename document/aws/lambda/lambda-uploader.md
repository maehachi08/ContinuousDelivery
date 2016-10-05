# AWS Lambda Pythonをlambda-uploaderでデプロイ

  [AWS Lambda Python をローカル環境で実行](python-lambda-local.md) でローカル環境でのLambdaファンクションの実行が可能になりました。しかし、実際、AWS Lambdaで実行する場合には以下の作業が必要です。

  1. コードをZIP圧縮
    - 依存ライブラリのコードも含める必要がある
  1. ZIPファイルをLambdaにアップロード

  これらの作業を自動化するのが、[lambda-uploader](https://github.com/rackerlabs/lambda-uploader)です。

## lambda-uploader 導入

### Python実行環境の仮想環境を利用(activate)します

 ```sh
source virtual-env/bin/activate
```

  プロンプトの先頭に **(virtual-env)** が付いたことが確認できました。

 ```sh
[ec2-user@ip-10-171-158-136 lambda-project]$ source virtual-env/bin/activate
(virtual-env) [ec2-user@ip-10-171-158-136 lambda-project]$
```

### lambda-uploader インストール

 ```sh
pip install lambda-uploader
```

  ヘルプが表示できることを確認できました。

 ```sh
(virtual-env) [ec2-user@ip-10-171-158-136 lambda-project]$ lambda-uploader --version
1.0.3
(virtual-env) [ec2-user@ip-10-171-158-136 lambda-project]$ lambda-uploader --help
usage: lambda-uploader [-h] [--version] [--no-upload] [--no-clean] [--publish]
                       [--virtualenv VIRTUALENV] [--extra-files EXTRA_FILES]
                       [--no-virtualenv] [--role ROLE] [--profile PROFILE]
                       [--requirements REQUIREMENTS] [--alias ALIAS]
                       [--alias-description ALIAS_DESCRIPTION]
                       [--s3-bucket S3_BUCKET] [--s3-key S3_KEY]
                       [--config CONFIG] [-V | -VV]
                       [function_dir]

Simple way to create and upload python lambda jobs

positional arguments:
  function_dir          lambda function directory

optional arguments:
  -h, --help            show this help message and exit
  --version, -v         show program's version number and exit
  --no-upload           dont upload the zipfile
  --no-clean            dont cleanup the temporary workspace
  --publish, -p         publish an upload to an immutable version
  --virtualenv VIRTUALENV, -e VIRTUALENV
                        use specified virtualenv instead of making one
  --extra-files EXTRA_FILES, -x EXTRA_FILES
                        include file or directory path in package
  --no-virtualenv       do not create or include a virtualenv at all
  --role ROLE           IAM role to assign the lambda function, can be set
                        with $LAMBDA_UPLOADER_ROLE
  --profile PROFILE     specify AWS cli profile
  --requirements REQUIREMENTS, -r REQUIREMENTS
                        specify a requirements.txt file
  --alias ALIAS, -a ALIAS
                        alias for published version (WILL SET THE PUBLISH
                        FLAG)
  --alias-description ALIAS_DESCRIPTION, -m ALIAS_DESCRIPTION
                        alias description
  --s3-bucket S3_BUCKET, -s S3_BUCKET
                        S3 bucket to store the lambda function in
  --s3-key S3_KEY, -k S3_KEY
                        Key name of the lambda function s3 object
  --config CONFIG, -c CONFIG
                        Overrides lambda.json
  -V                    Set log-level to INFO.
  -VV                   Set log-level to DEBUG.
```

## Lambdaファンクションをデプロイ

### lambda-uploader の設定ファイルを作成

  lambda-uploader ではLambdaファンクション名やハンドラー名などのLambdaファンクションの作成や更新に必要な情報を `lambda.json` に記述しておきます。

  lambda.json の書き方などについては [example/lambda.json](https://github.com/rackerlabs/lambda-uploader/blob/master/example/lambda.json) や [READMEのconfiguration-file](https://github.com/rackerlabs/lambda-uploader#configuration-file) に記載されているサンプルを参照すること。

 ```sh
vim lambda.json
```

 ```json
{
  "name": "print-ecs-ami",
  "description": "Print ecs optimized ami ids",
  "region": "ap-northeast-1",
  "handler": "lambda_function.lambda_handler",
  "role": "arn:aws:iam::000000000000:role/lambda_basic_execution",
  "requirements": ["chardet", "BeautifulSoup"],
  "ignore": [
    "circle.yml",
    ".git",
    "/*.pyc"
  ],
  "timeout": 30,
  "memory": 512
}
```

### デプロイ

 ```sh
lambda-uploader
```

 ```sh
(virtual-env)[ec2-user@ip-172-30-1-36 lambda-project]$ lambda-uploader
λ Building Package
λ Uploading Package
λ Fin
```

 ```sh
[ec2-user@ip-172-30-1-36 ~]$ aws lambda get-function-configuration --function-name print-ecs-ami
{
    "CodeSha256": "ZDSH7ilVTvYQlwRHKhnoCe5Vk68QW4Fn364YXRdO3c8=",
    "FunctionName": "print-ecs-ami",
    "CodeSize": 37704740,
    "MemorySize": 512,
    "FunctionArn": "arn:aws:lambda:ap-northeast-1:000000000000:function:print-ecs-ami",
    "Version": "$LATEST",
    "Role": "arn:aws:iam::000000000000:role/lambda_basic_execution",
    "Timeout": 30,
    "LastModified": "2016-10-05T08:20:43.996+0000",
    "Handler": "lambda_function.lambda_handler",
    "Runtime": "python2.7",
    "Description": "Print ecs optimized ami ids"
}
```

#### Lambda Funcion Create権限がないと怒られる
  - 検証ではEC2インスタンスに適用しているインスタンスロールに対して `AWSLambdaFullAccess` ポリシーをアタッチしている

 ```
ClientError: An error occurred (AccessDeniedException) when calling the CreateFunction operation: User: arn:aws:sts::000000000000:assumed-role/ecsInstanceRole/i-5bc037d5 is not authorized to perform: lambda:CreateFunction
```

