# CodePipelineでGitHubへの接続が失敗する

## エラーメッセージ

 ```
Insufficient permissions
Could not access the GitHub repository: "JavaServletHelloWorld". The access token might be invalid or has been revoked. Edit the pipeline to reconnect with GitHub.
```

## 原因
  - http://docs.aws.amazon.com/ja_jp/codepipeline/latest/userguide/troubleshooting.html

  1. Token文字列の前後にスペースなど不要な文字が含まれていないことを確認する
  1. GitHubの `Edit personal access token`ページで以下権限が付与されていることを確認する
    - `admin:repo_hook`
    - `repo`
  1. `Regenerate Token` を実施し、トークンを再生成してみる

