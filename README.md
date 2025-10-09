# GenAI Platform Infrastructure

検証用サーバ環境構築の過程など<br>
操作する上の基本的な内容（Terraform実行環境の構築、EKSできたら認証とる、とか、そういうこと）は書きません。<br>

## 1. 構成図
Cursor（Mermaid）で作成。随時更新予定。
```mermaid
graph TB
    subgraph "AWS Cloud"
        subgraph "VPC (10.0.0.0/16)"
            subgraph "Public Subnets"
                ALB[Application Load Balancer]
            end
            
            subgraph "Private Subnets"
                subgraph "EKS Cluster"
                    subgraph "genai-platform namespace"
                        LiteLLM[LiteLLM Pod]
                        LiteLLMSvc[LiteLLM Service]
                        LiteLLMPV[LiteLLM PV]
                        
                        LangfuseWeb[Langfuse Web Pod]
                        LangfuseWorker[Langfuse Worker Pod]
                        LangfuseWebSvc[Langfuse Web Service]
                        LangfusePV[Langfuse PV]
                        
                        ClickHouse[ClickHouse Pods]
                        ClickHousePV[ClickHouse PV]
                        
                        Zookeeper[Zookeeper Pods]
                        ZookeeperSvc[Zookeeper Service]
                        ZookeeperPV[Zookeeper PV]
                    end
                end
                
                subgraph "RDS Aurora PostgreSQL"
                    RDS[(Aurora Cluster)]
                end
                
                subgraph "ElastiCache Redis"
                    Redis[(Redis Single Node)]
                end
            end
        end
        
        subgraph "S3 Storage"
            S3Langfuse[(Langfuse S3 Bucket)]
            S3ClickHouse[(ClickHouse S3 Bucket)]
        end
    end
    
    subgraph "External"
        User[User/Client]
        AzureOpenAI[Azure OpenAI]
    end
    
    %% User connections
    User --> ALB
    ALB --> LiteLLMSvc
    LiteLLMSvc --> LiteLLM
    
    %% LiteLLM connections
    LiteLLM --> AzureOpenAI
    LiteLLM -->|"http://langfuse-web:3000"| LangfuseWebSvc
    LangfuseWebSvc --> LangfuseWeb
    
    %% Langfuse connections
    LangfuseWeb --> RDS
    LangfuseWeb --> Redis
    LangfuseWeb --> S3Langfuse
    LangfuseWorker --> RDS
    LangfuseWorker --> Redis
    LangfuseWorker --> S3Langfuse
    LangfuseWorker --> ClickHouse
    
    %% ClickHouse connections
    ClickHouse --> S3ClickHouse
    ClickHouse --> ZookeeperSvc
    ZookeeperSvc --> Zookeeper
    
    %% PV connections
    LiteLLM --> LiteLLMPV
    LangfuseWeb --> LangfusePV
    LangfuseWorker --> LangfusePV
    ClickHouse --> ClickHousePV
    Zookeeper --> ZookeeperPV
    
    %% IAM Roles positioned near pods
    LiteLLMRole[LiteLLM IAM Role]
    LangfuseRole[Langfuse IAM Role]
    ClickHouseRole[ClickHouse IAM Role]
    
    %% Styling
    classDef aws fill:#ff9900,stroke:#232f3e,stroke-width:2px,color:#fff
    classDef k8s fill:#326ce5,stroke:#fff,stroke-width:2px,color:#fff
    classDef storage fill:#3f51b5,stroke:#fff,stroke-width:2px,color:#fff
    classDef external fill:#4caf50,stroke:#fff,stroke-width:2px,color:#fff
    classDef coordination fill:#9c27b0,stroke:#fff,stroke-width:2px,color:#fff
    classDef service fill:#ff5722,stroke:#fff,stroke-width:2px,color:#fff
    classDef pv fill:#795548,stroke:#fff,stroke-width:2px,color:#fff
    classDef iam fill:#607d8b,stroke:#fff,stroke-width:2px,color:#fff
    
    class ALB,RDS,Redis,S3Langfuse,S3ClickHouse aws
    class LiteLLM,LangfuseWeb,LangfuseWorker,ClickHouse k8s
    class S3Langfuse,S3ClickHouse,RDS,Redis storage
    class User,AzureOpenAI external
    class Zookeeper coordination
    class LiteLLMSvc,LangfuseWebSvc service
    class LiteLLMPV,LangfusePV,ClickHousePV,ZookeeperPV pv
    class LiteLLMRole,LangfuseRole,ClickHouseRole iam
```


## 2. 事前準備
 - AWS
 - Terraform
 - kubectl
 - helm
 - Azure OpenAI （例：gpt-4o-miniをデプロイ）
 - （Option）コーディングAI（例：Github Coplot, Cursor）

## 3. AWSリソースの構築
src/のtfファイルをご参照。随時更新。<br>
EKS Auto Mode、Aurora、Redis、S3、IAM、VPCなど<br>
エンタ押すだけ、15分ぐらい。<br>
検証用のためセキュアでも何でもない（あまりそこはやらない予定）<br>

## 4. LiteLLMデプロイ
以降、まだかなり手動作業残る状態。徐々にコツコツ改善予定。<br>

### 4.1 k8s名前空間を作成。
```bash
kubectl apply -f k8s/namespace.yaml
```

### 4.2 LiteLLM立ち上げ
terraformのoutputを元に下記のファイルを修正して適用。<br>
src/k8s/mylitellm.yaml<br>
```bash
kubectl apply -f k8s/mylitellm.yaml
```

### 4.3 Ingress立ち上げ
現状はlangfuse用もまとめて立ち上げ。<br>
```bash
kubectl apply -f k8s/myingress.yaml
```

### 4.4 動作確認
数分待ってから下記の観点で確認する。
 - [ALBのURL]：LiteLLMのOpenAPI定義が確認できること。
 - [ALBのURL]/ui：LiteLLMの管理画面が表示されること。ログインして事前に登録しているモデルが確認できること。
 - curlリクエスト：LiteLLM越しにAzure OpenAIにリクエストして、LiteLLMの管理画面でログが確認できること。
 ```bash
 curl -X POST "[ALBのURL]/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer [LiteLLM Key]" \
  -d '{
    "model": "[YOUR_LLM_MODEL]",
    "messages": [
      {
        "role": "user",
        "content": "こんにちは！LiteLLMのテストです。"
      }
    ]
  }'
 ```

## 5. Langfuseデプロイ
まだまだ手動手順が残る状況。徐々に改善予定。<br>

### 5.1 Langfuse用のSecret、ConfigMap、StorageClass
src/k8s/mylangfuse.yamlを更新して適用する。
```bash
kubectl apply -f k8s/myingress.yaml
```

### 5.2 Helmでインストール
（まだ試行錯誤中）<br>
src/helm/values.yamlを更新して適用する。
```bash
# Helmリポジトリ追加
helm repo add langfuse https://langfuse.github.io/langfuse-k8s
helm repo update

# Langfuseデプロイ
helm install langfuse langfuse/langfuse -n genai-platform -f helm/values.yaml

# アンインストールするとき
helm uninstall langfuse -n genai-platform
```

### 5.3 事後作業（工事中）
現時点で残ってしまっている残作業<br>
その１）サービスアカウントへのアノテーション付与<br>
helmインストールではできず、手動になっている。<br>
下記の2つの対応が必要。<br>
- langfuse-web, langfuse-workerのサービスアカウントへのIAMロールARNのアノテーション
- langfuse-clickhouseのサービスアカウントへのIAMロールARNのアノテーション
```bash
kubectl annotate serviceaccount langfuse -n genai-platform eks.amazonaws.com/role-arn=[YOUR_LANGFUSE_ROLE_ARN]
kubectl annotate serviceaccount langfuse -n genai-platform eks.amazonaws.com/role-arn=[YOUR_CLICKHOUSE_ROLE_ARN]
```
実行後は再起動が必要。
```bash
# Langfuse全コンポーネントの再起動
kubectl rollout restart deployment langfuse-web -n genai-platform
kubectl rollout restart deployment langfuse-worker -n genai-platform
kubectl rollout restart statefulset langfuse-clickhouse-shard0 -n genai-platform
```
その２）ClickHouseのConfigMapパッチ<br>
これもHelmインストール時にできるはずなのだが、現状は手作業。。
```bash
kubectl patch statefulset langfuse-clickhouse-shard0 -n genai-platform --type='json' -p='[{"op": "add", "path": "/spec/template/spec/volumes/-", "value": {"name": "clickhouse-s3-config", "configMap": {"name": "clickhouse-s3-config"}}}, {"op": "add", "path": "/spec/template/spec/containers/0/volumeMounts/-", "value": {"name": "clickhouse-s3-config", "mountPath": "/etc/clickhouse-server/config.d/s3disk.xml", "subPath": "s3disk.xml"}}]'
```

### 5.4 動作確認＆LiteLLM連結
数分待ってから下記の観点で確認、作業する。
 - [ALBのURL]：Langfuseのログイン画面が表示されること。初回は新規アカウント作成を行い、管理画面に侵入する。
 - プロジェクトのパブリックキーとシークレットキーを生成し、LiteLLMに登録する。
 - curlリクエスト：先ほどと同じくLiteLLM越しにAzure OpenAIにリクエストする。
 - Langfuseの管理画面でトレースが見れることを確認する。
 - Langfuse用のS3にデータができていることを確認する。
 - Clickhouse用のS3に大量のプレフィクスができていることを確認する。

## 6. 1日の終わりに必ず実施すること
```bash
terraform destroy
```

## 7. 認証認可統合（EntraID,API Management)検証

検証したい内容は、下記のとおり。段階的に少しずつ動作確認しつつ進める。
- EntraIDにアプリケーション登録
- APIManagementで、Oauth2.0認証
- LiteLLMで仮想キーを払い出してKeyVaultに登録
- APIManagementで、KeyVaultから登録した仮想キーを取得して、LiteLLMへルーティングする

### 7.1 EntraIDにアプリケーション登録
下記を参考に設定を行う。<br>
参考）https://learn.microsoft.com/ja-jp/azure/api-management/api-management-howto-protect-backend-with-aad#register-an-application-in-microsoft-entra-id-to-represent-the-api

今回は下記を実施。
- アプリケーションの登録：LiteLLMを登録する
- クライアントシークレットの払い出し
- APIの公開、スコープの設定
  
### 7.2 APIManagementで、Oauth2.0認証

確認のため、下記の簡易設定を実施。<br>
- LiteLLMのドメインに対して/*へのPOSTのAPIを作成、サブスクリプションキーは除去、製品設定もなし。
- JWT認証後にLiteLLMキーはポリシー内で書き換える

作成したポリシーは、tf/doc/litellm_policy.xml参照。

### 7.3 ここまでの動作確認
```bash
# 環境変数を使用したトークン取得
TOKEN=$(curl -s -X POST "https://login.microsoftonline.com/$TENANT_ID/oauth2/v2.0/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=$CLIENT_ID" \
  -d "client_secret=$CLIENT_SECRET" \
  -d "scope=$SCOPE" \
  -d "grant_type=client_credentials" | jq -r '.access_token')

# API Management越しにLiteLLMを呼び出し
curl -X POST "https://myapim20251009.azure-api.net/v1/chat/completions" \
 -H "Content-Type: application/json" \
 -H "Authorization: Bearer $TOKEN" \
 -H "X-Litellm-Key: Bearer sk-1234" \
 -d '{
   "model": "gpt-4o-mini",
   "messages": [
     {
       "role": "user",
       "content": "こんにちは！LiteLLMのテストです。"
     }
   ]
 }'
・・・
"message":{"content":"こんにちは！LiteLLMのテストですね。どのようにお手伝いできますか？"
・・・      
```

### （実施中）7.4 APIMがKeyVaultから値を取得することの確認
なぜかポータル経由では、Key Vault Secrets Officerロールが見つからず、CLIにて実施。<br>

- Key Vaultの作成
```bash
az keyvault create --name "myvault20251009" --resource-group "myrg" --location "JapanEast"

az role assignment create --role "Key Vault Secrets Officer" --assignee "<upn>" --scope "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.KeyVault/vaults/<your-unique-keyvault-name>"

az keyvault secret set --vault-name "myvault20251009" --name "litellmPassword" --value "{litellm masterkey}"
```

（今ここまで）

