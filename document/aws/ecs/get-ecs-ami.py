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

def main():
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

if __name__ == "__main__":
  main()


