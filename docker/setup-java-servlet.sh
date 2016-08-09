#!/bin/bash
# apache + tomcatインストール

# epel
yum install -y epel-release
yum install -y supervisor

# apache + tomcat でJava Servletを動かす

## 事前準備
#systemctl stop firewalld
#systemctl disable firewalld

## インストール
### java実行環境をインストール
yum install -y java-1.8.0-openjdk 
yum install -y java-1.8.0-openjdk-headless
yum install -y java-1.8.0-openjdk-devel

### apacheをインストール
yum install -y httpd

### tomcatをインストール
yum install -y tomcat
