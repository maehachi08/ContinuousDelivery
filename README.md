# 継続的デリバリー(Continuous Delivery) 

本レポジトリは継続的デリバリー、特に継続的デプロイメントの実現方法を検証する過程で溜まる知見などをドキュメントとして残すことが目的です。

また、デプロイ対象は以下を想定しています。
  - Javaアプリを内包するDockerコンテナイメージ
    - `docker build` と `docker push` を実行する
      - DockerfileとJavaアプリはそれぞれ異なるGitレポジトリで管理している
      - dockerレジストリはECR(Amazon EC2 Container Registry)を使用する
  - ECS(Amazon EC2 Container Service)のDockerアプリケーション
    - コンテナインスタンス上にECSクラスタを構成する

## 検証するツール

 1. AWS CodePipeline + AWS CodeDeploy
   - https://aws.amazon.com/jp/codepipeline/
   - https://aws.amazon.com/jp/codedeploy/
 1. GoCD
   - https://www.go.cd/

