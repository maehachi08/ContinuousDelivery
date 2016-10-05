# Lambdaファンクションを作成

## Lambdaファンクションやライブラリを含めるディレクトリを作成

 ```sh
mkdir lambda-project
cd lambda-project
```

## pythonプログラムを作成

 ```sh
vim lambda_function.py
```

 ```python
# coding:utf-8
#  Name:
#    get-ecs-ami.py
#
#  Description:
#    ECS Optimized AMIのAMI IDをAWSドキュメント内から取得する
#
#    AWS Lambdaで使用する場合は
#    BeautifulSoupライブラリとchardetライブラリをデプロイパッケージに含めること
#
#    refs https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/lambda-python-how-to-create-deployment-package.html
#
import urllib2
import chardet
from BeautifulSoup import BeautifulSoup

def lambda_handler(event, context):
  # URLをセット
  url = 'http://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/ecs-optimized_AMI.html'

  # URLを開く
  response = urllib2.urlopen(url)

  # HTMLを読み込む
  html = response.read().decode("utf-8", "replace")

  # BeautifulSoupオブジェクト
  soup = BeautifulSoup(html)
  table = soup.findAll( "div", { "class" : "informaltable-contents" } )[0]
  t_body = table.findAll( "table" )[0].findAll( "tbody" )[0]
  
  # ディクショナリ型変数を初期化
  dict = {}

  # <code class="literal"></code> を抽出
  #   1つ目がリージョン、2つ目がAMI IDの組みなので、
  #   ディクショナリ型変数に格納する
  for t_code in t_body.findAll( "tr" ):
    k, v = BeautifulSoup( str( t_code ) ).findAll( "code", { "class" : "literal" } )
    # k,vはunicode型インスタンスなのでstrで文字列へ変換する
    dict[str( k.text )] = str( v.text )

  for key, value in dict.items():
    print( key,  value )

  return dict
```

## デプロイパッケージの作成
  - [デプロイパッケージの作成 (Python)](https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/lambda-python-how-to-create-deployment-package.html#deployment-pkg-for-virtualenv)
  - [ステップ 2.1: デプロイパッケージを作成する](https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/with-s3-example-deployment-pkg.html#with-s3-example-deployment-pkg-python)
  - [Pythonの仮想環境を構築できるvirtualenvを使ってみる](http://qiita.com/H-A-L/items/5d5a2ef73be8d140bdf3)

### ライブラリをプロジェクトディレクトリにインストールする

 ```sh
pip install BeautifulSoup -t ./
pip install chardet -t ./
```

### virtualenv をインストールしPython実行環境をプロジェクトディレクトリに作る

 ```sh
easy_install virtualenv
virtualenv ./virtual-env
```

### ZIPで圧縮する

 ```sh
zip -r lambda_function.zip *
```

## Lambdaファンクションを作成する
  - http://inokara.hateblo.jp/entry/2015/10/10/211516

### ファンクション初回作成

 ```sh
aws lambda --region us-east-1 \
  create-function \
    --function-name get-ecs-optimzed-ami-id \
    --runtime python2.7 \
    --role arn:aws:iam::375144106126:role/lambda_basic_execution \
    --handler lambda_function.lambda_handler \
    --timeout 30 \
    --zip-file fileb://lambda_function.zip
```

### 作成済みファンクションへコードアップロード

 ```sh
aws lambda --region us-east-1 \
  update-function-code \
    --function-name get-ecs-optimzed-ami-id \
    --zip-file fileb://lambda_function.zip
```

### VPCを指定する場合の注意点
  - [Qiita AWS LambdaのVPCアクセスに関して少しだけ解説](http://qiita.com/Keisuke69/items/1d84684f0511a062e968)
  - [Amazon VPC 内のリソースにアクセスできるように Lambda 関数を構成する](http://docs.aws.amazon.com/ja_jp/lambda/latest/dg/vpc.html)
  - [実行ロール (IAM ロール) を作成する](https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/vpc-rds-create-iam-role.html)

  Lambdaファンクションを使ってVPC内のリソースにアクセスできるようにする場合、 `--vpc-config` オプションで対象VPCのVPC サブネット ID やセキュリティグループ ID など、追加の VPC 固有設定情報を指定する必要があります。AWS Lambdaは `--vpc-config` オプションで指定された情報を使用して、Lambdaファンクションがプライベート VPC 内の他のリソースに安全に接続できる [Elastic Network Interface (ENI)](http://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/using-eni.html) を作成します。

  従って、Lambdaファンクションの実行ロール(上記例ではlambda_basic_execution)は[Elastic Network Interface (ENI)](http://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/using-eni.html)を作成するためのアクセス許可が必要です。

  AWS Lambdaでは、アクセス権限ポリシー AWSLambdaVPCAccessExecutionRole が提供されています。このポリシーでは、ロールの作成時に使用できる、必要な EC2 アクション (ec2:CreateNetworkInterface、 ec2:DescribeNetworkInterfaces、ec2:DeleteNetworkInterface) 用のアクセス許可が定義されます。

   1. IAMコンソールを開く
   1. ロール > 新しいロールの作成
   1. ロール名を入力(lambda-vpc-execution-roleなど)
   1. ロールタイプの選択で `AWS Lambda` を選択
   1. `AWSLambdaVPCAccessExecutionRole` をチェック
   1. `ロールの作成` をクリック
