#!/usr/bin/env ruby
require 'yaml'
require 'open-uri'
require 'nokogiri'

# 変数初期化
ami_info = {}
url = 'http://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/ecs-optimized_AMI.html'
charset = nil

html = open(url) do |f|
  charset = f.charset # 文字種別を取得
  f.read # htmlを読み込んで変数htmlに渡す
end

# htmlをパース(解析)してオブジェクトを生成
doc = Nokogiri::HTML.parse(html, nil, charset)

table = doc.xpath('//div[@class="informaltable-contents"]/table/tbody')
table.xpath('tr').each do |line|
  # line変数には各リージョンごとの情報が入る
  # "us-east-1amzn-ami-2016.03.h-amazon-ecs-optimizedami-6bb2d67cLaunch instance"
  # "us-west-1amzn-ami-2016.03.h-amazon-ecs-optimizedami-70632110Launch instance"
  # p line.xpath('//td/code[@class="literal"]').text
  ami_info[line.xpath('td/code')[0].text] = line.xpath('td/code')[1].text.to_s
end

# AMI-IDを取得するだけ
def get_ami(doc)
  table = doc.xpath('//div[@class="informaltable-contents"]/table')
  table.xpath('//td/code[@class="literal"]').each do |line|
    if line.text =~ /^ami-/
      p line.text
    end
  end
end

