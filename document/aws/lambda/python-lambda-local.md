# AWS Lambda Python をローカル環境で実行

  [python-lambda-local](https://github.com/HDE/python-lambda-local) を利用し、Lambdaファンクション用に記載したPythonコードをローカル環境で実行できるエミュレート環境を導入します。

  本項の作業の前提として、[Lambdaファンクションを作成](create-lambda-function.md) の [virtualenv をインストールしPython実行環境をプロジェクトディレクトリに作る](https://github.com/maehachi08/ContinuousDelivery/blob/master/document/aws/lambda/create-lambda-function.md#virtualenv-をインストールしpython実行環境をプロジェクトディレクトリに作る) まで完了している環境を使用します。

## python-lambda-local 導入

### Python実行環境の仮想環境を利用(activate)します

 ```sh
source virtual-env/bin/activate
```

  プロンプトの先頭に **(virtual-env)** が付いたことが確認できました。

 ```sh
[ec2-user@ip-10-171-158-136 lambda-project]$ source virtual-env/bin/activate
(virtual-env) [ec2-user@ip-10-171-158-136 lambda-project]$
```

### python-lambda-localをインストールします

 ```sh
pip install python-lambda-local
```

  ヘルプが表示できることを確認できました。

 ```sh
$ python-lambda-local -h
usage: python-lambda-local [-h] [-l LIBRARY_PATH] [-f HANDLER_FUNCTION]
                           [-t TIMEOUT] [-a ARN_STRING] [-v VERSION_NAME]
                           FILE EVENT

Run AWS Lambda function written in Python on local machine.

positional arguments:
  FILE                  Lambda function file name
  EVENT                 Event data file name.

optional arguments:
  -h, --help            show this help message and exit
  -l LIBRARY_PATH, --library LIBRARY_PATH
                        Path of 3rd party libraries.
  -f HANDLER_FUNCTION, --function HANDLER_FUNCTION
                        Lambda function handler name. Default: "handler".
  -t TIMEOUT, --timeout TIMEOUT
                        Seconds until lambda function timeout. Default: 3
  -a ARN_STRING, --arn-string ARN_STRING
                        arn string for function
  -v VERSION_NAME, --version-name VERSION_NAME
                        function version name
```

## python-lambda-local でLambdaファンクションを実行
  - virtualenvの仮想環境のまま(activateした状態)
  
### Eventファイルを作成
  - AWS Lambdaコンソールではサンプルを指定できたけど、ここでは手動で作成

 ```sh
vim event.json
```

 ```json
{
  "key3": "value3",
  "key2": "value2",
  "key1": "value1"
}
```

### Lambdaファンクションを実行

  基本的な実行方法は以下の通りです。

 ```sh
python-lambda-local -f <ハンドラ名> <Pythonスクリプト名> <Eventファイル名>
```

 ```sh
python-lambda-local -f lambda_handler lambda_function.py event.json
```

 ```sh
(virtual-env) [ec2-user@ip-10-171-158-136 lambda-project]$ python-lambda-local -f lambda_handler lambda_function.py event.json
[root - INFO - 2016-10-05 04:02:03,183] Event: {u'key3': u'value3', u'key2': u'value2', u'key1': u'value1'}
[root - INFO - 2016-10-05 04:02:03,183] START RequestId: 3f7ff730-3b3c-47a8-8795-8ae91b85bfca
('us-east-1', 'ami-40286957')
('ap-northeast-1', 'ami-010ed160')
('ap-southeast-1', 'ami-438b2f20')
('ap-southeast-2', 'ami-862211e5')
('us-west-2', 'ami-562cf236')
('us-west-1', 'ami-20fab440')
('eu-central-1', 'ami-c55ea2aa')
('eu-west-1', 'ami-175f1964')
[root - INFO - 2016-10-05 04:02:03,719] END RequestId: 3f7ff730-3b3c-47a8-8795-8ae91b85bfca
[root - INFO - 2016-10-05 04:02:03,720] RESULT:
{'us-east-1': 'ami-40286957', 'ap-northeast-1': 'ami-010ed160', 'ap-southeast-1': 'ami-438b2f20', 'ap-southeast-2': 'ami-862211e5', 'us-west-2': 'ami-562cf236', 'us-west-1': 'ami-20fab440', 'eu-central-1': 'ami-c55ea2aa', 'eu-west-1': 'ami-175f1964'}
[root - INFO - 2016-10-05 04:02:03,720] REPORT RequestId: 3f7ff730-3b3c-47a8-8795-8ae91b85bfca  Duration: 536.09 ms
```

