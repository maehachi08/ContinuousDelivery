From docker.io/centos:latest
MAINTAINER Kazunori Maehata
ENV container docker

RUN yum update  -y && yum clean all

ADD setup-java-servlet.sh /tmp/setup-java-servlet.sh
RUN sh /tmp/setup-java-servlet.sh
ADD tomcat.conf /etc/httpd/conf.d/tomcat.conf


# tgzファイルをADDで指定した場合、
# 解凍された状態で配置先に配置される
ADD hello /var/lib/tomcat/webapps/hello/
#COPY hello.tgz /tmp/hello.tgz
#RUN tar xzf /tmp/hello.tgz -C /var/lib/tomcat/webapps/


# supervisord でプロセス起動する
ADD supervisord.conf /etc/supervisord.conf
ADD apache_tomcat.ini /etc/supervisord.d/apache_tomcat.ini

# コンテナ起動時に実行する
# httpdプロセス単体を起動するのはこれだけでもよい
#   httpd + tomcatなど複数サービスを起動する場合はsupervisordなどを併用する
#CMD ["/usr/sbin/httpd", "$OPTIONS", "-DFOREGROUND"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

EXPOSE 80
