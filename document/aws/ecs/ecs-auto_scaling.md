# ECSクラスタをAutoScalingさせる
  - [Amazon ECSでAuto Scaling](https://aws.amazon.com/jp/blogs/news/automatic-scaling-with-amazon-ecs/)
  - [[新機能]ECSがAutoScalingに対応しました！](http://dev.classmethod.jp/cloud/ecs-autoscaling/)

## 概要
  - 2016/05/23 の `AutoScaling` と `CloudWatch Alarm` の新機能によりECSのServiceにScaling Policyを利用可能になった
  - ECS ServiceとECS ClusterのAuto Scaling Groupの両方にScaling Policyを使えます
    - Cluster InstanceとService Taskのスケールアウト/スケールイン を実現


