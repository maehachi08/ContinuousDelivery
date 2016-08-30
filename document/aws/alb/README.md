# ALB(Application Load Balancer)
  - [【新発表】AWS アプリケーションロードバランサー](https://aws.amazon.com/jp/blogs/news/new-aws-application-load-balancer/)
  - [Application Load Balancer の詳細](https://aws.amazon.com/jp/elasticloadbalancing/applicationloadbalancer/)


## ALBとは

 L7のロードバランス機能を提供するフルマネージドサービスです。

## ALBとECS

 ALBによってECSクラスタによる複数のdockerコンテナへのロードバランスがサポートされました。ECSクラスタでは動的ポートマッピングという、同一EC2コンテナインスタンス上の複数のdockerマシンへのホスト側ポートを動的に割り当てる機能があり、ECSスケジューラはこのポート情報をALBに連携することが可能です。

 ALB(およびターゲットグループ)を定義しておけば、ECSクラスタのService定義にあるLoad Balancingにてターゲットグループを選択することで簡単にロードバランスさせることができ、Serviceの更新によってコンテナが再デプロイされた場合でも、動的ポートマッピングによって変更されたポート情報をALBに連携するので、途絶えることなくロードバランスすることができます。

