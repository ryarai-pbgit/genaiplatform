# Langfuse データベーススキーマ

このドキュメントは、Langfuseプラットフォームのデータベーステーブル定義を説明します。

## 目次
- [認証・ユーザー管理](#認証ユーザー管理)
- [組織・プロジェクト管理](#組織プロジェクト管理)
- [トレース・観測管理](#トレース観測管理)
- [データセット管理](#データセット管理)
- [プロンプト管理](#プロンプト管理)
- [評価・スコア管理](#評価スコア管理)
- [メディア管理](#メディア管理)
- [ダッシュボード管理](#ダッシュボード管理)
- [自動化・ワークフロー](#自動化ワークフロー)
- [インテグレーション](#インテグレーション)

---

## 認証・ユーザー管理

### User
ユーザー情報を管理するテーブル

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| id | String | PK | ユーザーID（CUID） |
| name | String? | | ユーザー名 |
| email | String? | UNIQUE | メールアドレス |
| emailVerified | DateTime? | | メール認証日時 |
| password | String? | | パスワード（ハッシュ化） |
| image | String? | | プロフィール画像URL |
| admin | Boolean | DEFAULT false | 管理者フラグ |
| featureFlags | String[] | DEFAULT [] | 機能フラグ |
| createdAt | DateTime | DEFAULT now() | 作成日時 |
| updatedAt | DateTime | DEFAULT now() | 更新日時 |

### Account
OAuth認証アカウント情報を管理するテーブル

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| id | String | PK | アカウントID（CUID） |
| userId | String | FK | ユーザーID |
| type | String | | 認証タイプ |
| provider | String | | プロバイダー名 |
| providerAccountId | String | | プロバイダーアカウントID |
| refresh_token | String? | | リフレッシュトークン |
| access_token | String? | | アクセストークン |
| expires_at | Int? | | 有効期限 |
| id_token | String? | | IDトークン |
| session_state | String? | | セッション状態 |

### Session
ユーザーセッション情報を管理するテーブル

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| id | String | PK | セッションID（CUID） |
| sessionToken | String | UNIQUE | セッショントークン |
| userId | String | FK | ユーザーID |
| expires | DateTime | | 有効期限 |

---

## 組織・プロジェクト管理

### Organization
組織情報を管理するテーブル

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| id | String | PK | 組織ID（CUID） |
| name | String | | 組織名 |
| cloudConfig | Json? | | クラウド設定 |
| metadata | Json? | | メタデータ |
| cloudBillingCycleAnchor | DateTime? | | クラウド請求サイクル開始日 |
| cloudCurrentCycleUsage | Int? | | 現在のサイクル使用量 |
| aiFeaturesEnabled | Boolean | DEFAULT false | AI機能有効フラグ |
| createdAt | DateTime | DEFAULT now() | 作成日時 |
| updatedAt | DateTime | DEFAULT now() | 更新日時 |

### Project
プロジェクト情報を管理するテーブル

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| id | String | PK | プロジェクトID（CUID） |
| orgId | String | FK | 組織ID |
| name | String | | プロジェクト名 |
| retentionDays | Int? | | データ保持日数 |
| metadata | Json? | | メタデータ |
| deletedAt | DateTime? | | 削除日時 |
| createdAt | DateTime | DEFAULT now() | 作成日時 |
| updatedAt | DateTime | DEFAULT now() | 更新日時 |

### OrganizationMembership
組織メンバーシップを管理するテーブル

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| id | String | PK | メンバーシップID（CUID） |
| orgId | String | FK | 組織ID |
| userId | String | FK | ユーザーID |
| role | Role | | ロール |
| createdAt | DateTime | DEFAULT now() | 作成日時 |
| updatedAt | DateTime | DEFAULT now() | 更新日時 |

### ProjectMembership
プロジェクトメンバーシップを管理するテーブル

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| orgMembershipId | String | FK | 組織メンバーシップID |
| projectId | String | FK | プロジェクトID |
| userId | String | FK | ユーザーID |
| role | Role | | ロール |
| createdAt | DateTime | DEFAULT now() | 作成日時 |
| updatedAt | DateTime | DEFAULT now() | 更新日時 |

### ApiKey
APIキーを管理するテーブル

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| id | String | PK | APIキーID（CUID） |
| publicKey | String | UNIQUE | パブリックキー |
| hashedSecretKey | String | UNIQUE | ハッシュ化されたシークレットキー |
| displaySecretKey | String | | 表示用シークレットキー |
| lastUsedAt | DateTime? | | 最終使用日時 |
| expiresAt | DateTime? | | 有効期限 |
| projectId | String? | FK | プロジェクトID |
| orgId | String? | FK | 組織ID |
| scope | ApiKeyScope | DEFAULT PROJECT | スコープ |
| createdAt | DateTime | DEFAULT now() | 作成日時 |

---

## トレース・観測管理

### TraceSession
トレースセッションを管理するテーブル

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| id | String | PK | セッションID（CUID） |
| projectId | String | FK | プロジェクトID |
| bookmarked | Boolean | DEFAULT false | ブックマーク状態 |
| public | Boolean | DEFAULT false | 公開状態 |
| environment | String | DEFAULT "default" | 環境 |
| createdAt | DateTime | DEFAULT now() | 作成日時 |
| updatedAt | DateTime | DEFAULT now() | 更新日時 |

### LegacyPrismaTrace
トレース情報を管理するテーブル（レガシー）

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| id | String | PK | トレースID（CUID） |
| externalId | String? | | 外部ID |
| timestamp | DateTime | DEFAULT now() | タイムスタンプ |
| name | String? | | トレース名 |
| userId | String? | | ユーザーID |
| metadata | Json? | | メタデータ |
| projectId | String | FK | プロジェクトID |
| public | Boolean | DEFAULT false | 公開状態 |
| bookmarked | Boolean | DEFAULT false | ブックマーク状態 |
| tags | String[] | DEFAULT [] | タグ |
| input | Json? | | 入力データ |
| output | Json? | | 出力データ |
| sessionId | String? | | セッションID |
| createdAt | DateTime | DEFAULT now() | 作成日時 |
| updatedAt | DateTime | DEFAULT now() | 更新日時 |

### LegacyPrismaObservation
観測データを管理するテーブル（レガシー）

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| id | String | PK | 観測ID（CUID） |
| traceId | String? | | トレースID |
| projectId | String | FK | プロジェクトID |
| type | LegacyPrismaObservationType | | 観測タイプ |
| startTime | DateTime | DEFAULT now() | 開始時刻 |
| endTime | DateTime? | | 終了時刻 |
| name | String? | | 観測名 |
| metadata | Json? | | メタデータ |
| parentObservationId | String? | | 親観測ID |
| level | LegacyPrismaObservationLevel | DEFAULT DEFAULT | レベル |
| statusMessage | String? | | ステータスメッセージ |
| model | String? | | モデル名 |
| input | Json? | | 入力データ |
| output | Json? | | 出力データ |
| promptTokens | Int | DEFAULT 0 | プロンプトトークン数 |
| completionTokens | Int | DEFAULT 0 | 完了トークン数 |
| totalTokens | Int | DEFAULT 0 | 総トークン数 |
| inputCost | Decimal? | | 入力コスト |
| outputCost | Decimal? | | 出力コスト |
| totalCost | Decimal? | | 総コスト |
| createdAt | DateTime | DEFAULT now() | 作成日時 |
| updatedAt | DateTime | DEFAULT now() | 更新日時 |

---

## データセット管理

### Dataset
データセットを管理するテーブル

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| id | String | PK | データセットID（CUID） |
| projectId | String | FK | プロジェクトID |
| name | String | | データセット名 |
| description | String? | | 説明 |
| metadata | Json? | | メタデータ |
| remoteExperimentUrl | String? | | リモート実験URL |
| createdAt | DateTime | DEFAULT now() | 作成日時 |
| updatedAt | DateTime | DEFAULT now() | 更新日時 |

### DatasetItem
データセットアイテムを管理するテーブル

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| id | String | PK | アイテムID（CUID） |
| projectId | String | FK | プロジェクトID |
| status | DatasetStatus | DEFAULT ACTIVE | ステータス |
| input | Json? | | 入力データ |
| expectedOutput | Json? | | 期待される出力 |
| metadata | Json? | | メタデータ |
| sourceTraceId | String? | | ソーストレースID |
| sourceObservationId | String? | | ソース観測ID |
| datasetId | String | FK | データセットID |
| createdAt | DateTime | DEFAULT now() | 作成日時 |
| updatedAt | DateTime | DEFAULT now() | 更新日時 |

### DatasetRuns
データセット実行を管理するテーブル

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| id | String | PK | 実行ID（CUID） |
| projectId | String | FK | プロジェクトID |
| name | String | | 実行名 |
| description | String? | | 説明 |
| metadata | Json? | | メタデータ |
| datasetId | String | FK | データセットID |
| createdAt | DateTime | DEFAULT now() | 作成日時 |
| updatedAt | DateTime | DEFAULT now() | 更新日時 |

---

## プロンプト管理

### Prompt
プロンプトを管理するテーブル

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| id | String | PK | プロンプトID（CUID） |
| projectId | String | FK | プロジェクトID |
| createdBy | String | | 作成者 |
| prompt | Json | | プロンプト内容 |
| name | String | | プロンプト名 |
| version | Int | | バージョン |
| type | String | DEFAULT "text" | タイプ |
| isActive | Boolean? | | アクティブ状態 |
| config | Json | DEFAULT {} | 設定 |
| tags | String[] | DEFAULT [] | タグ |
| labels | String[] | DEFAULT [] | ラベル |
| commitMessage | String? | | コミットメッセージ |
| createdAt | DateTime | DEFAULT now() | 作成日時 |
| updatedAt | DateTime | DEFAULT now() | 更新日時 |

### PromptDependency
プロンプト依存関係を管理するテーブル

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| id | String | PK | 依存関係ID（CUID） |
| projectId | String | FK | プロジェクトID |
| parentId | String | FK | 親プロンプトID |
| childName | String | | 子プロンプト名 |
| childLabel | String? | | 子プロンプトラベル |
| childVersion | Int? | | 子プロンプトバージョン |
| createdAt | DateTime | DEFAULT now() | 作成日時 |
| updatedAt | DateTime | DEFAULT now() | 更新日時 |

---

## 評価・スコア管理

### ScoreConfig
スコア設定を管理するテーブル

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| id | String | PK | 設定ID（CUID） |
| projectId | String | FK | プロジェクトID |
| name | String | | スコア名 |
| dataType | ScoreDataType | | データタイプ |
| isArchived | Boolean | DEFAULT false | アーカイブ状態 |
| minValue | Float? | | 最小値 |
| maxValue | Float? | | 最大値 |
| categories | Json? | | カテゴリ |
| description | String? | | 説明 |
| createdAt | DateTime | DEFAULT now() | 作成日時 |
| updatedAt | DateTime | DEFAULT now() | 更新日時 |

### LegacyPrismaScore
スコアデータを管理するテーブル（レガシー）

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| id | String | PK | スコアID（CUID） |
| projectId | String | FK | プロジェクトID |
| name | String | | スコア名 |
| value | Float? | | 数値 |
| source | LegacyPrismaScoreSource | | ソース |
| authorUserId | String? | | 作成者ユーザーID |
| comment | String? | | コメント |
| traceId | String | | トレースID |
| observationId | String? | | 観測ID |
| configId | String? | FK | 設定ID |
| stringValue | String? | | 文字列値 |
| dataType | ScoreDataType | DEFAULT NUMERIC | データタイプ |
| timestamp | DateTime | DEFAULT now() | タイムスタンプ |
| createdAt | DateTime | DEFAULT now() | 作成日時 |
| updatedAt | DateTime | DEFAULT now() | 更新日時 |

---

## メディア管理

### Media
メディアファイルを管理するテーブル

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| id | String | PK | メディアID |
| sha256Hash | String | | SHA256ハッシュ |
| projectId | String | FK | プロジェクトID |
| uploadedAt | DateTime? | | アップロード日時 |
| uploadHttpStatus | Int? | | アップロードHTTPステータス |
| uploadHttpError | String? | | アップロードHTTPエラー |
| bucketPath | String | | バケットパス |
| bucketName | String | | バケット名 |
| contentType | String | | コンテンツタイプ |
| contentLength | BigInt | | コンテンツ長 |
| createdAt | DateTime | DEFAULT now() | 作成日時 |
| updatedAt | DateTime | DEFAULT now() | 更新日時 |

### TraceMedia
トレースメディア関連を管理するテーブル

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| id | String | PK | 関連ID（CUID） |
| projectId | String | FK | プロジェクトID |
| mediaId | String | FK | メディアID |
| traceId | String | | トレースID |
| field | String | | フィールド名 |
| createdAt | DateTime | DEFAULT now() | 作成日時 |
| updatedAt | DateTime | DEFAULT now() | 更新日時 |

---

## ダッシュボード管理

### Dashboard
ダッシュボードを管理するテーブル

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| id | String | PK | ダッシュボードID（CUID） |
| projectId | String? | FK | プロジェクトID |
| name | String | | ダッシュボード名 |
| description | String | | 説明 |
| definition | Json | | 定義 |
| filters | Json | DEFAULT [] | フィルター |
| createdBy | String? | | 作成者 |
| updatedBy | String? | | 更新者 |
| createdAt | DateTime | DEFAULT now() | 作成日時 |
| updatedAt | DateTime | DEFAULT now() | 更新日時 |

### DashboardWidget
ダッシュボードウィジェットを管理するテーブル

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| id | String | PK | ウィジェットID（CUID） |
| projectId | String? | FK | プロジェクトID |
| name | String | | ウィジェット名 |
| description | String | | 説明 |
| view | DashboardWidgetViews | | ビュー |
| dimensions | Json | | ディメンション |
| metrics | Json | | メトリクス |
| filters | Json | | フィルター |
| chartType | DashboardWidgetChartType | | チャートタイプ |
| chartConfig | Json | | チャート設定 |
| createdBy | String? | | 作成者 |
| updatedBy | String? | | 更新者 |
| createdAt | DateTime | DEFAULT now() | 作成日時 |
| updatedAt | DateTime | DEFAULT now() | 更新日時 |

---

## 自動化・ワークフロー

### Action
アクションを管理するテーブル

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| id | String | PK | アクションID（CUID） |
| projectId | String | FK | プロジェクトID |
| type | ActionType | | アクションタイプ |
| config | Json | | 設定 |
| createdAt | DateTime | DEFAULT now() | 作成日時 |
| updatedAt | DateTime | DEFAULT now() | 更新日時 |

### Trigger
トリガーを管理するテーブル

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| id | String | PK | トリガーID（CUID） |
| projectId | String | FK | プロジェクトID |
| eventSource | String | | イベントソース |
| eventActions | String[] | | イベントアクション |
| filter | Json? | | フィルター |
| status | JobConfigState | DEFAULT ACTIVE | ステータス |
| createdAt | DateTime | DEFAULT now() | 作成日時 |
| updatedAt | DateTime | DEFAULT now() | 更新日時 |

### Automation
自動化を管理するテーブル

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| id | String | PK | 自動化ID（CUID） |
| name | String | | 自動化名 |
| triggerId | String | FK | トリガーID |
| actionId | String | FK | アクションID |
| projectId | String | FK | プロジェクトID |
| createdAt | DateTime | DEFAULT now() | 作成日時 |

---

## インテグレーション

### LlmApiKeys
LLM APIキーを管理するテーブル

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| id | String | PK | APIキーID（CUID） |
| projectId | String | FK | プロジェクトID |
| provider | String | | プロバイダー |
| adapter | String | | アダプター |
| displaySecretKey | String | | 表示用シークレットキー |
| secretKey | String | | シークレットキー |
| baseURL | String? | | ベースURL |
| customModels | String[] | DEFAULT [] | カスタムモデル |
| withDefaultModels | Boolean | DEFAULT true | デフォルトモデル使用 |
| extraHeaders | String? | | 追加ヘッダー |
| config | Json? | | 設定 |
| createdAt | DateTime | DEFAULT now() | 作成日時 |
| updatedAt | DateTime | DEFAULT now() | 更新日時 |

### SlackIntegration
Slack統合を管理するテーブル

| カラム名 | データ型 | 制約 | 説明 |
|---------|---------|------|------|
| id | String | PK | 統合ID（CUID） |
| projectId | String | UNIQUE FK | プロジェクトID |
| teamId | String | | SlackワークスペースID |
| teamName | String | | ワークスペース名 |
| botToken | String | | ボットトークン（暗号化） |
| botUserId | String | | ボットユーザーID |
| createdAt | DateTime | DEFAULT now() | 作成日時 |
| updatedAt | DateTime | DEFAULT now() | 更新日時 |

---

## 列挙型（Enum）

### Role
- OWNER: オーナー
- ADMIN: 管理者
- MEMBER: メンバー
- VIEWER: 閲覧者
- NONE: なし

### ApiKeyScope
- ORGANIZATION: 組織スコープ
- PROJECT: プロジェクトスコープ

### LegacyPrismaObservationType
- SPAN: スパン
- EVENT: イベント
- GENERATION: 生成
- AGENT: エージェント
- TOOL: ツール
- CHAIN: チェーン
- RETRIEVER: リトリーバー
- EVALUATOR: 評価器
- EMBEDDING: 埋め込み
- GUARDRAIL: ガードレール

### LegacyPrismaObservationLevel
- DEBUG: デバッグ
- DEFAULT: デフォルト
- WARNING: 警告
- ERROR: エラー

### ScoreDataType
- CATEGORICAL: カテゴリカル
- NUMERIC: 数値
- BOOLEAN: ブール

### DatasetStatus
- ACTIVE: アクティブ
- ARCHIVED: アーカイブ

### ActionType
- WEBHOOK: Webhook
- SLACK: Slack

### DashboardWidgetViews
- TRACES: トレース
- OBSERVATIONS: 観測
- SCORES_NUMERIC: 数値スコア
- SCORES_CATEGORICAL: カテゴリスコア

### DashboardWidgetChartType
- LINE_TIME_SERIES: 時系列線グラフ
- BAR_TIME_SERIES: 時系列棒グラフ
- HORIZONTAL_BAR: 水平棒グラフ
- VERTICAL_BAR: 垂直棒グラフ
- PIE: 円グラフ
- NUMBER: 数値
- HISTOGRAM: ヒストグラム
- PIVOT_TABLE: ピボットテーブル

---

## インデックス

主要なテーブルには以下のインデックスが設定されています：

- **LegacyPrismaTrace**: projectId, timestamp, sessionId, name, userId, tags
- **LegacyPrismaObservation**: projectId, traceId, startTime, type, model
- **LegacyPrismaScore**: projectId, name, value, traceId, observationId
- **DatasetItem**: projectId, datasetId, sourceTraceId, sourceObservationId
- **Prompt**: projectId, name, version, tags
- **Media**: projectId, sha256Hash
- **DashboardWidget**: projectId, view
- **Automation**: projectId, name

---

## リレーション

主要なリレーションシップ：

- **User** ↔ **Organization**: 多対多（OrganizationMembership経由）
- **User** ↔ **Project**: 多対多（ProjectMembership経由）
- **Organization** → **Project**: 1対多
- **Project** → **LegacyPrismaTrace**: 1対多
- **LegacyPrismaTrace** → **LegacyPrismaObservation**: 1対多
- **Project** → **Dataset**: 1対多
- **Dataset** → **DatasetItem**: 1対多
- **Project** → **Prompt**: 1対多
- **Project** → **ScoreConfig**: 1対多
- **ScoreConfig** → **LegacyPrismaScore**: 1対多
- **Project** → **Media**: 1対多
- **Project** → **Dashboard**: 1対多
- **Dashboard** → **DashboardWidget**: 1対多
- **Project** → **Action**: 1対多
- **Project** → **Trigger**: 1対多
- **Trigger** → **Automation**: 1対多
- **Action** → **Automation**: 1対多
