# LiteLLM データベーススキーマ

このドキュメントは、LiteLLMプラットフォームのデータベーステーブル定義を説明します。

## 目次
- [予算・レート制限](#予算レート制限)
- [認証・認可](#認証認可)
- [組織・チーム管理](#組織チーム管理)
- [ユーザー管理](#ユーザー管理)
- [APIキー管理](#apiキー管理)
- [ログ・監査](#ログ監査)
- [ファイル管理](#ファイル管理)
- [ヘルスチェック](#ヘルスチェック)

---

## 予算・レート制限

### LiteLLM_BudgetTable
組織の予算とレート制限を管理するテーブル

| カラム名 | データ型 | 説明 |
|---------|---------|-------|
| budget_id | String (PK) | 予算ID（UUID） |
| max_budget | Float? | 最大予算額 |
| soft_budget | Float? | ソフト予算額（警告レベル） |
| max_parallel_requests | Int? | 最大並行リクエスト数 |
| tpm_limit | BigInt? | トークン/分の制限 |
| rpm_limit | BigInt? | リクエスト/分の制限 |
| model_max_budget | Json? | モデル別最大予算設定 |
| budget_duration | String? | 予算期間 |
| budget_reset_at | DateTime? | 予算リセット日時 |
| created_at | DateTime | 作成日時 |
| created_by | String | 作成者 |
| updated_at | DateTime | 更新日時 |
| updated_by | String | 更新者 |

---

## 認証・認可

### LiteLLM_CredentialsTable
プロキシの認証情報を管理するテーブル

| カラム名 | データ型 | 説明 |
|---------|---------|-------|
| credential_id | String (PK) | 認証情報ID（UUID） |
| credential_name | String (UNIQUE) | 認証情報名 |
| credential_values | Json | 認証情報の値 |
| credential_info | Json? | 認証情報の詳細 |
| created_at | DateTime | 作成日時 |
| created_by | String | 作成者 |
| updated_at | DateTime | 更新日時 |
| updated_by | String | 更新者 |

### LiteLLM_ObjectPermissionTable
オブジェクトレベルの権限を管理するテーブル

| カラム名 | データ型 | 説明 |
|---------|---------|-------|
| object_permission_id | String (PK) | オブジェクト権限ID（UUID） |
| mcp_servers | String[] | MCPサーバー一覧 |
| mcp_access_groups | String[] | MCPアクセスグループ |
| mcp_tool_permissions | Json? | MCPツール権限設定 |
| vector_stores | String[] | ベクターストア一覧 |

---

## 組織・チーム管理

### LiteLLM_OrganizationTable
組織情報を管理するテーブル

| カラム名 | データ型 | 説明 |
|---------|---------|-------|
| organization_id | String (PK) | 組織ID（UUID） |
| organization_alias | String | 組織エイリアス |
| budget_id | String | 予算ID（外部キー） |
| metadata | Json | メタデータ |
| models | String[] | 利用可能モデル一覧 |
| spend | Float | 現在の支出額 |
| model_spend | Json | モデル別支出 |
| object_permission_id | String? | オブジェクト権限ID |
| created_at | DateTime | 作成日時 |
| created_by | String | 作成者 |
| updated_at | DateTime | 更新日時 |
| updated_by | String | 更新者 |

### LiteLLM_TeamTable
チーム情報を管理するテーブル

| カラム名 | データ型 | 説明 |
|---------|---------|-------|
| team_id | String (PK) | チームID（UUID） |
| team_alias | String? | チームエイリアス |
| organization_id | String? | 組織ID（外部キー） |
| object_permission_id | String? | オブジェクト権限ID |
| admins | String[] | 管理者一覧 |
| members | String[] | メンバー一覧 |
| members_with_roles | Json | ロール付きメンバー情報 |
| metadata | Json | メタデータ |
| max_budget | Float? | 最大予算 |
| spend | Float | 現在の支出額 |
| models | String[] | 利用可能モデル一覧 |
| max_parallel_requests | Int? | 最大並行リクエスト数 |
| tpm_limit | BigInt? | トークン/分の制限 |
| rpm_limit | BigInt? | リクエスト/分の制限 |
| budget_duration | String? | 予算期間 |
| budget_reset_at | DateTime? | 予算リセット日時 |
| blocked | Boolean | ブロック状態 |
| model_spend | Json | モデル別支出 |
| model_max_budget | Json | モデル別最大予算 |
| team_member_permissions | String[] | チームメンバー権限 |
| model_id | Int? | モデルID（外部キー） |
| created_at | DateTime | 作成日時 |
| updated_at | DateTime | 更新日時 |

### LiteLLM_ModelTable
チームレベルのモデル情報を管理するテーブル

| カラム名 | データ型 | 説明 |
|---------|---------|-------|
| id | Int (PK) | モデルID（自動増分） |
| model_aliases | Json? | モデルエイリアス |
| created_at | DateTime | 作成日時 |
| created_by | String | 作成者 |
| updated_at | DateTime | 更新日時 |
| updated_by | String | 更新者 |

---

## ユーザー管理

### LiteLLM_UserTable
ユーザー情報を管理するテーブル

| カラム名 | データ型 | 説明 |
|---------|---------|-------|
| user_id | String (PK) | ユーザーID |
| user_alias | String? | ユーザーエイリアス |
| team_id | String? | チームID（外部キー） |
| sso_user_id | String? (UNIQUE) | SSOユーザーID |
| organization_id | String? | 組織ID（外部キー） |
| object_permission_id | String? | オブジェクト権限ID |
| password | String? | パスワード |
| teams | String[] | 所属チーム一覧 |
| user_role | String? | ユーザーロール |
| max_budget | Float? | 最大予算 |
| spend | Float | 現在の支出額 |
| user_email | String? | ユーザーメールアドレス |
| models | String[] | 利用可能モデル一覧 |
| metadata | Json | メタデータ |
| max_parallel_requests | Int? | 最大並行リクエスト数 |
| tpm_limit | BigInt? | トークン/分の制限 |
| rpm_limit | BigInt? | リクエスト/分の制限 |
| budget_duration | String? | 予算期間 |
| budget_reset_at | DateTime? | 予算リセット日時 |
| allowed_cache_controls | String[] | 許可されたキャッシュ制御 |
| model_spend | Json | モデル別支出 |
| model_max_budget | Json | モデル別最大予算 |
| created_at | DateTime? | 作成日時 |
| updated_at | DateTime? | 更新日時 |

### LiteLLM_EndUserTable
エンドユーザー情報を管理するテーブル

| カラム名 | データ型 | 説明 |
|---------|---------|-------|
| user_id | String (PK) | ユーザーID |
| alias | String? | エイリアス |
| spend | Float | 現在の支出額 |
| allowed_model_region | String? | 許可されたモデルリージョン |
| default_model | String? | デフォルトモデル |
| budget_id | String? | 予算ID（外部キー） |
| blocked | Boolean | ブロック状態 |

### LiteLLM_TeamMembership
チームメンバーシップを管理するテーブル

| カラム名 | データ型 | 説明 |
|---------|---------|-------|
| user_id | String (PK) | ユーザーID |
| team_id | String (PK) | チームID |
| spend | Float | チーム内での支出額 |
| budget_id | String? | 予算ID（外部キー） |

### LiteLLM_OrganizationMembership
組織メンバーシップを管理するテーブル

| カラム名 | データ型 | 説明 |
|---------|---------|-------|
| user_id | String (PK) | ユーザーID |
| organization_id | String (PK) | 組織ID |
| user_role | String? | ユーザーロール |
| spend | Float? | 組織内での支出額 |
| budget_id | String? | 予算ID（外部キー） |
| created_at | DateTime? | 作成日時 |
| updated_at | DateTime? | 更新日時 |

---

## APIキー管理

### LiteLLM_VerificationToken
APIキー（トークン）を管理するテーブル

| カラム名 | データ型 | 説明 |
|---------|---------|-------|
| token | String (PK) | APIトークン |
| key_name | String? | キー名 |
| key_alias | String? | キーエイリアス |
| soft_budget_cooldown | Boolean | ソフト予算クールダウン状態 |
| spend | Float | 現在の支出額 |
| expires | DateTime? | 有効期限 |
| models | String[] | 利用可能モデル一覧 |
| aliases | Json | エイリアス設定 |
| config | Json | 設定情報 |
| user_id | String? | ユーザーID |
| team_id | String? | チームID |
| permissions | Json | 権限設定 |
| max_parallel_requests | Int? | 最大並行リクエスト数 |
| metadata | Json | メタデータ |
| blocked | Boolean? | ブロック状態 |
| tpm_limit | BigInt? | トークン/分の制限 |
| rpm_limit | BigInt? | リクエスト/分の制限 |
| max_budget | Float? | 最大予算 |
| budget_duration | String? | 予算期間 |
| budget_reset_at | DateTime? | 予算リセット日時 |
| allowed_cache_controls | String[] | 許可されたキャッシュ制御 |
| allowed_routes | String[] | 許可されたルート |
| model_spend | Json | モデル別支出 |
| model_max_budget | Json | モデル別最大予算 |
| budget_id | String? | 予算ID（外部キー） |
| organization_id | String? | 組織ID（外部キー） |
| object_permission_id | String? | オブジェクト権限ID |
| created_at | DateTime? | 作成日時 |
| created_by | String? | 作成者 |
| updated_at | DateTime? | 更新日時 |
| updated_by | String? | 更新者 |
| rotation_count | Int? | ローテーション回数 |
| auto_rotate | Boolean? | 自動ローテーション設定 |
| rotation_interval | String? | ローテーション間隔 |
| last_rotation_at | DateTime? | 最終ローテーション日時 |
| key_rotation_at | DateTime? | 次回ローテーション予定日時 |

---

## プロキシモデル管理

### LiteLLM_ProxyModelTable
プロキシで管理されるモデル情報を格納するテーブル

| カラム名 | データ型 | 説明 |
|---------|---------|-------|
| model_id | String (PK) | モデルID（UUID） |
| model_name | String | モデル名 |
| litellm_params | Json | LiteLLMパラメータ |
| model_info | Json? | モデル情報 |
| created_at | DateTime | 作成日時 |
| created_by | String | 作成者 |
| updated_at | DateTime | 更新日時 |
| updated_by | String | 更新者 |

---

## タグ管理

### LiteLLM_TagTable
タグと予算・支出を管理するテーブル

| カラム名 | データ型 | 説明 |
|---------|---------|-------|
| tag_name | String (PK) | タグ名 |
| description | String? | 説明 |
| models | String[] | 関連モデル一覧 |
| model_info | Json? | モデル情報マッピング |
| spend | Float | 現在の支出額 |
| budget_id | String? | 予算ID（外部キー） |
| created_at | DateTime | 作成日時 |
| created_by | String? | 作成者 |
| updated_at | DateTime | 更新日時 |

---

## 設定管理

### LiteLLM_Config
プロキシ設定を格納するテーブル

| カラム名 | データ型 | 説明 |
|---------|---------|-------|
| param_name | String (PK) | パラメータ名 |
| param_value | Json? | パラメータ値 |

---

## ログ・監査

### LiteLLM_SpendLogs
リクエストごとの支出・モデル・APIキーを記録するテーブル

| カラム名 | データ型 | 説明 |
|---------|---------|-------|
| request_id | String (PK) | リクエストID |
| call_type | String | 呼び出しタイプ |
| api_key | String | ハッシュ化されたAPIトークン |
| spend | Float | 支出額 |
| total_tokens | Int | 総トークン数 |
| prompt_tokens | Int | プロンプトトークン数 |
| completion_tokens | Int | 完了トークン数 |
| startTime | DateTime | 開始時刻 |
| endTime | DateTime | 終了時刻 |
| completionStartTime | DateTime? | 完了開始時刻 |
| model | String | モデル名 |
| model_id | String? | モデルID |
| model_group | String? | モデルグループ |
| custom_llm_provider | String? | カスタムLLMプロバイダー |
| api_base | String? | APIベースURL |
| user | String? | ユーザー |
| metadata | Json? | メタデータ |
| cache_hit | String? | キャッシュヒット |
| cache_key | String? | キャッシュキー |
| request_tags | Json? | リクエストタグ |
| team_id | String? | チームID |
| end_user | String? | エンドユーザー |
| requester_ip_address | String? | リクエスタIPアドレス |
| messages | Json? | メッセージ |
| response | Json? | レスポンス |
| session_id | String? | セッションID |
| status | String? | ステータス |
| mcp_namespaced_tool_name | String? | MCP名前空間ツール名 |
| proxy_server_request | Json? | プロキシサーバーリクエスト |

### LiteLLM_ErrorLogs
エラーログを記録するテーブル

| カラム名 | データ型 | 説明 |
|---------|---------|-------|
| request_id | String (PK) | リクエストID（UUID） |
| startTime | DateTime | 開始時刻 |
| endTime | DateTime | 終了時刻 |
| api_base | String | APIベースURL |
| model_group | String | モデルグループ |
| litellm_model_name | String | LiteLLMモデル名 |
| model_id | String | モデルID |
| request_kwargs | Json | リクエスト引数 |
| exception_type | String | 例外タイプ |
| exception_string | String | 例外文字列 |
| status_code | String | ステータスコード |

### LiteLLM_AuditLog
監査ログを記録するテーブル

| カラム名 | データ型 | 説明 |
|---------|---------|-------|
| id | String (PK) | ログID（UUID） |
| updated_at | DateTime | 更新日時 |
| changed_by | String | 変更者 |
| changed_by_api_key | String | 変更者APIキー |
| action | String | アクション（create, update, delete） |
| table_name | String | テーブル名 |
| object_id | String | オブジェクトID |
| before_value | Json? | 変更前の値 |
| updated_values | Json? | 更新された値 |

---

## 日次集計

### LiteLLM_DailyUserSpend
ユーザー別日次支出メトリクスを記録するテーブル

| カラム名 | データ型 | 説明 |
|---------|---------|-------|
| id | String (PK) | レコードID（UUID） |
| user_id | String? | ユーザーID |
| date | String | 日付 |
| api_key | String | APIキー |
| model | String? | モデル名 |
| model_group | String? | モデルグループ |
| custom_llm_provider | String? | カスタムLLMプロバイダー |
| mcp_namespaced_tool_name | String? | MCP名前空間ツール名 |
| prompt_tokens | BigInt | プロンプトトークン数 |
| completion_tokens | BigInt | 完了トークン数 |
| cache_read_input_tokens | BigInt | キャッシュ読み取り入力トークン数 |
| cache_creation_input_tokens | BigInt | キャッシュ作成入力トークン数 |
| spend | Float | 支出額 |
| api_requests | BigInt | APIリクエスト数 |
| successful_requests | BigInt | 成功リクエスト数 |
| failed_requests | BigInt | 失敗リクエスト数 |
| created_at | DateTime | 作成日時 |
| updated_at | DateTime | 更新日時 |

### LiteLLM_DailyTeamSpend
チーム別日次支出メトリクスを記録するテーブル

| カラム名 | データ型 | 説明 |
|---------|---------|-------|
| id | String (PK) | レコードID（UUID） |
| team_id | String? | チームID |
| date | String | 日付 |
| api_key | String | APIキー |
| model | String? | モデル名 |
| model_group | String? | モデルグループ |
| custom_llm_provider | String? | カスタムLLMプロバイダー |
| mcp_namespaced_tool_name | String? | MCP名前空間ツール名 |
| prompt_tokens | BigInt | プロンプトトークン数 |
| completion_tokens | BigInt | 完了トークン数 |
| cache_read_input_tokens | BigInt | キャッシュ読み取り入力トークン数 |
| cache_creation_input_tokens | BigInt | キャッシュ作成入力トークン数 |
| spend | Float | 支出額 |
| api_requests | BigInt | APIリクエスト数 |
| successful_requests | BigInt | 成功リクエスト数 |
| failed_requests | BigInt | 失敗リクエスト数 |
| created_at | DateTime | 作成日時 |
| updated_at | DateTime | 更新日時 |

### LiteLLM_DailyTagSpend
タグ別日次支出メトリクスを記録するテーブル

| カラム名 | データ型 | 説明 |
|---------|---------|-------|
| id | String (PK) | レコードID（UUID） |
| tag | String? | タグ名 |
| date | String | 日付 |
| api_key | String | APIキー |
| model | String? | モデル名 |
| model_group | String? | モデルグループ |
| custom_llm_provider | String? | カスタムLLMプロバイダー |
| mcp_namespaced_tool_name | String? | MCP名前空間ツール名 |
| prompt_tokens | BigInt | プロンプトトークン数 |
| completion_tokens | BigInt | 完了トークン数 |
| cache_read_input_tokens | BigInt | キャッシュ読み取り入力トークン数 |
| cache_creation_input_tokens | BigInt | キャッシュ作成入力トークン数 |
| spend | Float | 支出額 |
| api_requests | BigInt | APIリクエスト数 |
| successful_requests | BigInt | 成功リクエスト数 |
| failed_requests | BigInt | 失敗リクエスト数 |
| created_at | DateTime | 作成日時 |
| updated_at | DateTime | 更新日時 |

---

## 通知・招待

### LiteLLM_UserNotifications
ユーザー通知を管理するテーブル

| カラム名 | データ型 | 説明 |
|---------|---------|-------|
| request_id | String (PK) | リクエストID |
| user_id | String | ユーザーID |
| models | String[] | モデル一覧 |
| justification | String | 正当化理由 |
| status | String | ステータス（approved, disapproved, pending） |

### LiteLLM_InvitationLink
招待リンクを管理するテーブル

| カラム名 | データ型 | 説明 |
|---------|---------|-------|
| id | String (PK) | 招待ID（UUID） |
| user_id | String | ユーザーID |
| is_accepted | Boolean | 承認状態 |
| accepted_at | DateTime? | 承認日時 |
| expires_at | DateTime | 有効期限 |
| created_at | DateTime | 作成日時 |
| created_by | String | 作成者 |
| updated_at | DateTime | 更新日時 |
| updated_by | String | 更新者 |

---

## ファイル管理

### LiteLLM_ManagedFileTable
管理されたファイルを格納するテーブル

| カラム名 | データ型 | 説明 |
|---------|---------|-------|
| id | String (PK) | ファイルID（UUID） |
| unified_file_id | String (UNIQUE) | 統一ファイルID（Base64エンコード） |
| file_object | Json? | OpenAIファイルオブジェクト |
| model_mappings | Json | モデルマッピング |
| flat_model_file_ids | String[] | フラットなモデルファイルID一覧 |
| created_at | DateTime | 作成日時 |
| created_by | String? | 作成者 |
| updated_at | DateTime | 更新日時 |
| updated_by | String? | 更新者 |

### LiteLLM_ManagedObjectTable
管理されたオブジェクト（バッチやファインチューニングジョブ）を格納するテーブル

| カラム名 | データ型 | 説明 |
|---------|---------|-------|
| id | String (PK) | オブジェクトID（UUID） |
| unified_object_id | String (UNIQUE) | 統一オブジェクトID（Base64エンコード） |
| model_object_id | String (UNIQUE) | モデルオブジェクトID |
| file_object | Json | OpenAIファイルオブジェクト |
| file_purpose | String | ファイル目的（batch または fine-tune） |
| status | String? | ステータス |
| created_at | DateTime | 作成日時 |
| created_by | String? | 作成者 |
| updated_at | DateTime | 更新日時 |
| updated_by | String? | 更新者 |

### LiteLLM_ManagedVectorStoresTable
管理されたベクターストアを格納するテーブル

| カラム名 | データ型 | 説明 |
|---------|---------|-------|
| vector_store_id | String (PK) | ベクターストアID |
| custom_llm_provider | String | カスタムLLMプロバイダー |
| vector_store_name | String? | ベクターストア名 |
| vector_store_description | String? | ベクターストア説明 |
| vector_store_metadata | Json? | ベクターストアメタデータ |
| created_at | DateTime | 作成日時 |
| updated_at | DateTime | 更新日時 |
| litellm_credential_name | String? | LiteLLM認証情報名 |
| litellm_params | Json? | LiteLLMパラメータ |

---

## ガードレール・プロンプト

### LiteLLM_GuardrailsTable
ガードレール設定を格納するテーブル

| カラム名 | データ型 | 説明 |
|---------|---------|-------|
| guardrail_id | String (PK) | ガードレールID（UUID） |
| guardrail_name | String (UNIQUE) | ガードレール名 |
| litellm_params | Json | LiteLLMパラメータ |
| guardrail_info | Json? | ガードレール情報 |
| created_at | DateTime | 作成日時 |
| updated_at | DateTime | 更新日時 |

### LiteLLM_PromptTable
プロンプト設定を格納するテーブル

| カラム名 | データ型 | 説明 |
|---------|---------|-------|
| id | String (PK) | プロンプトID（UUID） |
| prompt_id | String (UNIQUE) | プロンプトID |
| litellm_params | Json | LiteLLMパラメータ |
| prompt_info | Json? | プロンプト情報 |
| created_at | DateTime | 作成日時 |
| updated_at | DateTime | 更新日時 |

---

## MCP（Model Context Protocol）

### LiteLLM_MCPServerTable
MCPサーバー設定を格納するテーブル

| カラム名 | データ型 | 説明 |
|---------|---------|-------|
| server_id | String (PK) | サーバーID（UUID） |
| server_name | String? | サーバー名 |
| alias | String? | エイリアス |
| description | String? | 説明 |
| url | String? | URL |
| transport | String | トランスポート（デフォルト: sse） |
| auth_type | String? | 認証タイプ |
| created_at | DateTime? | 作成日時 |
| created_by | String? | 作成者 |
| updated_at | DateTime? | 更新日時 |
| updated_by | String? | 更新者 |
| mcp_info | Json? | MCP情報 |
| mcp_access_groups | String[] | MCPアクセスグループ |
| allowed_tools | String[] | 許可されたツール |
| extra_headers | String[] | 追加ヘッダー |
| status | String? | ヘルスチェックステータス |
| last_health_check | DateTime? | 最終ヘルスチェック日時 |
| health_check_error | String? | ヘルスチェックエラー |
| command | String? | コマンド（stdio用） |
| args | String[] | 引数（stdio用） |
| env | Json? | 環境変数（stdio用） |

---

## ヘルスチェック

### LiteLLM_HealthCheckTable
モデルのヘルスチェック結果を記録するテーブル

| カラム名 | データ型 | 説明 |
|---------|---------|-------|
| health_check_id | String (PK) | ヘルスチェックID（UUID） |
| model_name | String | モデル名 |
| model_id | String? | モデルID |
| status | String | ステータス |
| healthy_count | Int | ヘルシー回数 |
| unhealthy_count | Int | アンヘルシー回数 |
| error_message | String? | エラーメッセージ |
| response_time_ms | Float? | レスポンス時間（ミリ秒） |
| details | Json? | 詳細情報 |
| checked_by | String? | チェック実行者 |
| checked_at | DateTime | チェック日時 |
| created_at | DateTime | 作成日時 |
| updated_at | DateTime | 更新日時 |

---

## ジョブ管理

### LiteLLM_CronJob
cronジョブの実行状態を管理するテーブル

| カラム名 | データ型 | 説明 |
|---------|---------|-------|
| cronjob_id | String (PK) | cronジョブID（CUID） |
| pod_id | String | リーダーとして動作するポッドの識別子 |
| status | JobStatus | cronジョブのステータス（ACTIVE/INACTIVE） |
| last_updated | DateTime | cronジョブレコードの最終更新日時 |
| ttl | DateTime | リーダーのリース有効期限 |

### JobStatus（Enum）
- ACTIVE: アクティブ
- INACTIVE: 非アクティブ

---

## インデックス

主要なテーブルには以下のインデックスが設定されています：

- **LiteLLM_SpendLogs**: startTime, end_user, session_id
- **LiteLLM_DailyUserSpend**: date, user_id, api_key, model, mcp_namespaced_tool_name
- **LiteLLM_DailyTeamSpend**: date, team_id, api_key, model, mcp_namespaced_tool_name
- **LiteLLM_DailyTagSpend**: date, tag, api_key, model, mcp_namespaced_tool_name
- **LiteLLM_HealthCheckTable**: model_name, checked_at, status
- **LiteLLM_ManagedFileTable**: unified_file_id
- **LiteLLM_ManagedObjectTable**: unified_object_id, model_object_id

---

## リレーション

主要なリレーションシップ：

- **組織 ↔ 予算**: 1対多
- **チーム ↔ 組織**: 多対1
- **ユーザー ↔ チーム**: 多対多
- **ユーザー ↔ 組織**: 多対多
- **APIキー ↔ 予算**: 多対1
- **APIキー ↔ 組織**: 多対1
- **APIキー ↔ オブジェクト権限**: 多対1
- **タグ ↔ 予算**: 多対1
- **チームメンバーシップ ↔ 予算**: 多対1
- **組織メンバーシップ ↔ 予算**: 多対1
