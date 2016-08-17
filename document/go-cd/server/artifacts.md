# artifacts
  - [Publishing artifacts](https://docs.go.cd/16.4.0/configuration/dev_upload_test_report.html)
  - [Managing artifacts and reports](https://docs.go.cd/16.4.0/configuration/managing_artifacts_and_reports.html)

## artifactsとは

パイプライン処理を実施する中でレポートファイルやログ、何かしらの成果物を退避させるための機能です。

Agent側の任意ファイルをServerへアップロードします。

 ```
2016-08-16 19:55:01,636 [loopThread] INFO  thoughtworks.go.util.HttpService:69 - Uploading file [/tmp/cruise-06ff07fc-b760-4f7c-a4fe-cdef09ba1ec1/1babe85e-781d-4934-8801-c8e02ba7969b/Dockerfile.zip] to url [https://127.0.0.1:8154/go/remoting/files/JavaServletHelloWorld/97/BuildDockerStage/1/docker-build/./?attempt=1&buildId=222]
2016-08-16 19:55:01,724 [loopThread] INFO  thoughtworks.go.util.HttpService:135 - Got back 201 from server
```

ServerにアップロードされたものはWebUI上からダウンロードできます。
  - `http://<GoCD Server>:8153/go/tab/build/detail/JavaServletHelloWorld/97/BuildDockerStage/1/docker-build`
  - `Artifacts` タブ

