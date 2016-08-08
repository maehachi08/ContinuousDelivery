# ECR(Amazon EC2 Container Registry) 

Dockerマシンイメージのレジストリサービスであり、フルマネージドサービスの1つです。

## EC2インスタンスからdocker pushする際の注意点
  1. **AmazonEC2ContainerRegistryFullAccess** ポリシーをアタッチする必要がある
  1. **ECS > Repositories > Permissions** で全プリンシパルに全許可する必要がある


