# GoCD Serverからのメール通知機能を検証

## `Email Notification plugin`
  - [公式ページの手順](https://github.com/gocd-contrib/email-notifier)
  - ステージのstatusが変わった場合に通知する仕組み

### まとめ
  - TLS認証をサポート
  - 宛先は全体で1つ
  - メール通知はステージ毎に開始と終了のタイミングで計2通(3ステージあれば6通)
  - メールの抑止(特定パイプラインは通知しない、など)は設定できない
  - メールの本文変更はできない

### Postfix設定

 1. /etc/postfix/main.cf` を以下のとおり設定
 
 ```diff
--- /etc/postfix/main.cf.org    2016-08-18 18:21:22.462198686 -0700
+++ /etc/postfix/main.cf        2016-08-18 18:44:54.726503543 -0700
@@ -73,14 +73,14 @@
 # other configuration parameters.
 #
 #myhostname = host.domain.tld
-#myhostname = virtual.domain.tld
+myhostname = localhost.localdomain

 # The mydomain parameter specifies the local internet domain name.
 # The default is to use $myhostname minus the first component.
 # $mydomain is used as a default value for many other configuration
 # parameters.
 #
-#mydomain = domain.tld
+mydomain = localdomain

 # SENDING MAIL
 #
@@ -96,7 +96,7 @@
 # to recipient addresses that have no @domain part.
 #
 #myorigin = $myhostname
-#myorigin = $mydomain
+myorigin = $mydomain

 # RECEIVING MAIL

@@ -112,8 +112,8 @@
 #
 #inet_interfaces = all
 #inet_interfaces = $myhostname
-#inet_interfaces = $myhostname, localhost
-inet_interfaces = localhost
+inet_interfaces = $myhostname, localhost
+#inet_interfaces = localhost

 # Enable IPv4, and IPv6 if supported
 inet_protocols = all
@@ -161,8 +161,8 @@
 #
 # See also below, section "REJECTING MAIL FOR UNKNOWN LOCAL USERS".
 #
-mydestination = $myhostname, localhost.$mydomain, localhost
-#mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain
+#mydestination = $myhostname, localhost.$mydomain, localhost
+mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain
 #mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain,
 #      mail.$mydomain, www.$mydomain, ftp.$mydomain

@@ -416,7 +416,7 @@
 # "Maildir/" for qmail-style delivery (the / is required).
 #
 #home_mailbox = Mailbox
-#home_mailbox = Maildir/
+home_mailbox = Maildir/

 # The mail_spool_directory parameter specifies the directory where
 # UNIX-style mailboxes are kept. The default setting depends on the
@@ -568,6 +568,7 @@
 #
 #smtpd_banner = $myhostname ESMTP $mail_name
 #smtpd_banner = $myhostname ESMTP $mail_name ($mail_version)
+smtpd_banner = $myhostname ESMTP unknown

 # PARALLEL DELIVERY TO THE SAME DESTINATION
 #
```

 1. sendmailを止めてpostfixを起動

 ```sh
# sendmail停止
/etc/rc.d/init.d/sendmail stop
chkconfig sendmail off

# MTAをpostfixへ切り替え
alternatives --config mta

# postfix起動
/etc/rc.d/init.d/postfix start
chkconfig postfix on
```

### `Email Notification plugin` インストール
  - https://github.com/gocd-contrib/email-notifier/releases
  - pluginを配置してgo-serverを再起動するだけ

 ```sh
wget https://github.com/gocd-contrib/email-notifier/releases/download/v0.1/email-notifier-0.1.jar
service go-server restart
```

### `Email Notification plugin` 設定

[公式ページの手順](https://github.com/gocd-contrib/email-notifier#configuration)

  1. `http://<GoCD Server>:8153/go/admin/plugins` へアクセスする
  2. `Email Notification plugin`の左側に表示されている歯車アイコンをクリック
  3. `Plugin Settings` で以下設定を実施
    - SMTP Host: `127.0.0.1`
    - SMTP Port: `25`
    - TLS?: `False`
    - Sender Email-id: `kmaehata@localhost.localdomain`
    - Sender Password: **********
    - Receiver Email-id: `kmaehata@localhost.localdomain`

### 動作確認
  - パイプラインを手動スケジューリングして通知を確認
  - `JavaServletHelloWorld`パイプラインにおいてどれだけの通知量なのか確認

#### GoCD Serverのメール通知ログ
  - `/var/log/go-server/plugin-email.notifier.log`

 ```
2016-08-18 18:48:34,984  INFO [66@MessageListener for PluginNotificationListener] EmailNotificationPluginImpl:52 - Sending Email for Stage: JavaServletHelloWorld/109/BuildDockerStage/1
2016-08-18 18:48:36,545  INFO [66@MessageListener for PluginNotificationListener] EmailNotificationPluginImpl:52 - Successfully delivered an email.
2016-08-18 18:48:36,548  INFO [66@MessageListener for PluginNotificationListener] EmailNotificationPluginImpl:52 - Sending Email for Stage: JavaServletHelloWorld/109/DeployEcrStage/1
2016-08-18 18:48:36,562  INFO [66@MessageListener for PluginNotificationListener] EmailNotificationPluginImpl:52 - Successfully delivered an email.
2016-08-18 18:48:56,952  INFO [66@MessageListener for PluginNotificationListener] EmailNotificationPluginImpl:52 - Sending Email for Stage: JavaServletHelloWorld/109/DeployEcrStage/1
2016-08-18 18:48:56,989  INFO [66@MessageListener for PluginNotificationListener] EmailNotificationPluginImpl:52 - Successfully delivered an email.
2016-08-18 18:48:57,011  INFO [66@MessageListener for PluginNotificationListener] EmailNotificationPluginImpl:52 - Sending Email for Stage: JavaServletHelloWorld/109/DeployEcsStage/1
2016-08-18 18:48:57,053  INFO [66@MessageListener for PluginNotificationListener] EmailNotificationPluginImpl:52 - Successfully delivered an email.
2016-08-18 18:49:14,322  INFO [66@MessageListener for PluginNotificationListener] EmailNotificationPluginImpl:52 - Sending Email for Stage: JavaServletHelloWorld/109/DeployEcsStage/1
2016-08-18 18:49:14,359  INFO [66@MessageListener for PluginNotificationListener] EmailNotificationPluginImpl:52 - Successfully delivered an email.
```

#### メール通知先のメールファイル
  - 以下はJavaServletHelloWorldパイプラインを回した際の全メール
  - ステージ毎に開始(Building)と終了(Passed)を通知している

 ```sh
[kmaehata@ip-172-30-3-34 ~]$ ls -l Maildir/new/
total 32
-rw------- 1 kmaehata kmaehata 852 Aug 18 18:45 1471571121.Vca01Ic40dM234375.ip-172-30-3-34
-rw------- 1 kmaehata kmaehata 872 Aug 18 18:48 1471571316.Vca01Ic3f7M567035.ip-172-30-3-34
-rw------- 1 kmaehata kmaehata 850 Aug 18 18:48 1471571316.Vca01Ic3f8M567358.ip-172-30-3-34
-rw------- 1 kmaehata kmaehata 871 Aug 18 18:48 1471571336.Vca01Ic3f6M990153.ip-172-30-3-34
-rw------- 1 kmaehata kmaehata 851 Aug 18 18:48 1471571337.Vca01Ic3f9M49686.ip-172-30-3-34
-rw------- 1 kmaehata kmaehata 872 Aug 18 18:49 1471571354.Vca01Ic3faM360417.ip-172-30-3-34
```

 ```sh
[kmaehata@ip-172-30-3-34 new]$ ls -1tr | xargs grep Subject
1471571121.Vca01Ic40dM234375.ip-172-30-3-34:Subject: Stage: JavaServletHelloWorld/109/BuildDockerStage/1
1471571316.Vca01Ic3f8M567358.ip-172-30-3-34:Subject: Stage: JavaServletHelloWorld/109/DeployEcrStage/1
1471571316.Vca01Ic3f7M567035.ip-172-30-3-34:Subject: Stage: JavaServletHelloWorld/109/BuildDockerStage/1
1471571336.Vca01Ic3f6M990153.ip-172-30-3-34:Subject: Stage: JavaServletHelloWorld/109/DeployEcrStage/1
1471571337.Vca01Ic3f9M49686.ip-172-30-3-34:Subject: Stage: JavaServletHelloWorld/109/DeployEcsStage/1
1471571354.Vca01Ic3faM360417.ip-172-30-3-34:Subject: Stage: JavaServletHelloWorld/109/DeployEcsStage/1
```

##### メール内容

 1. ビルド開始

 ```
Return-Path: <kmaehata@localhost.localdomain>
X-Original-To: kmaehata@localhost.localdomain
Delivered-To: kmaehata@localhost.localdomain
Received: from ip-172-30-3-34 (localhost [127.0.0.1])
        by localhost.localdomain (Postfix) with ESMTP id E265A8FA0
        for <kmaehata@localhost.localdomain>; Thu, 18 Aug 2016 18:45:17 -0700 (PDT)
Date: Thu, 18 Aug 2016 18:45:17 -0700 (PDT)
From: kmaehata@localhost.localdomain
Sender: kmaehata@localhost.localdomain
Reply-To: kmaehata@localhost.localdomain
To: kmaehata@localhost.localdomain
Message-ID: <161468058.0.1471571121182.JavaMail.kmaehata@localhost.localdomain>
Subject: Stage: JavaServletHelloWorld/109/BuildDockerStage/1
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

State: Building
Result: Unknown
Create Time: 2016-08-18T18:45:17.624Z
Last Transition Time:
```

 1. ビルド成功

 ```
Return-Path: <kmaehata@localhost.localdomain>
X-Original-To: kmaehata@localhost.localdomain
Delivered-To: kmaehata@localhost.localdomain
Received: from ip-172-30-3-34 (localhost [127.0.0.1])
        by localhost.localdomain (Postfix) with ESMTP id 810B7C3F5
        for <kmaehata@localhost.localdomain>; Thu, 18 Aug 2016 18:48:36 -0700 (PDT)
Date: Thu, 18 Aug 2016 18:48:36 -0700 (PDT)
From: kmaehata@localhost.localdomain
Sender: kmaehata@localhost.localdomain
Reply-To: kmaehata@localhost.localdomain
To: kmaehata@localhost.localdomain
Message-ID: <87340967.1.1471571316529.JavaMail.kmaehata@localhost.localdomain>
Subject: Stage: JavaServletHelloWorld/109/BuildDockerStage/1
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

State: Passed
Result: Passed
Create Time: 2016-08-18T18:45:17.624Z
Last Transition Time: 2016-08-18T18:48:34.910Z
```

### メール抑止や本文を変えるなどの設定はできるのか？
  - Pluginの設定画面に該当の設定項目はありません。
  - 各パイプラインやステージの設定ページにもemail-notification関連の設定はありません。

#### メールbody

[ソースコードでハードコード](https://github.com/gocd-contrib/email-notifier/blob/master/src/com/tw/go/plugin/EmailNotificationPluginImpl.java#L106)

