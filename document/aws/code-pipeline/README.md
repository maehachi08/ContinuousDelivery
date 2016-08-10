# AWS CodePipeline
 - refs [AWS CodePipeline](https://aws.amazon.com/jp/codepipeline/)


*AWS CodePipeline* とは継続的デリバリーを実現するためのフルマネージドサービスです。
 - refs [継続的デリバリーとは?](https://aws.amazon.com/jp/devops/continuous-delivery/)


## AWS CodePipeline 概要

### 継続的デリバリーを実現することができる
 1. コード更新を検知することが可能
   - 更新検知の対象は `Code Commit` / `S3` / `GitHub` を選択可能
 1. コードのビルドやテストを行うことが可能
   - ビルドツールは `Soplano CI` / `Jenkins` / `ビルドしない` を選択可能
 1. デプロイを行うことが可能
   - デプロイ方法は `OpsWorks` / `Beanstalk` / `CodeDeploy` 選択可能

### パイプラインベース

CodePipeline はパイプラインベースの継続的デリバリーを提供するサービスであり、複数のタスクを直列に並べて定義でき、`処理①が成功したら処理②を実行する`といったパイプラインを構築できます。マネージメントコンソールから視覚的に操作可能です。


