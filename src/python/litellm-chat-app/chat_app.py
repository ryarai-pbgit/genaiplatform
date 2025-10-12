import streamlit as st
import requests
import json
from datetime import datetime
# Langfuse SDK v3
from langfuse import get_client, observe
import os # Added for os.environ

# Langfuseの設定（環境変数から自動取得）
try:
    langfuse = get_client()  # 環境変数から自動的に取得
    langfuse_available = True
except Exception as e:
    st.error(f"Langfuse初期化エラー: {str(e)}")
    langfuse_available = False

# ページ設定
st.set_page_config(
    page_title="LiteLLM Chat App",
    page_icon="💬",
    layout="wide"
)

# サイドバー設定
with st.sidebar:
    st.title("設定")
    
    # LiteLLMサーバー設定
    litellm_url = st.text_input(
        "LiteLLM URL", 
        value="",
        help="LiteLLMサーバーのURL"
    )
    
    # APIキー設定
    api_key = st.text_input(
        "API Key", 
        type="password",
        help="LiteLLMの仮想キー"
    )
    
    # モデル選択
    model_options = [
        "gpt-4o-mini",
        "gemini/gemini-2.0-flash-lite"
    ]
    
    selected_model = st.selectbox(
        "モデル選択",
        model_options,
        index=0
    )
    
    # システムメッセージ設定
    system_message = st.text_area(
        "システムメッセージ",
        value="あなたは親切なアシスタントです。",
        height=100
    )
    
    # エンドユーザー設定（オプション）
    end_user = st.text_input(
        "エンドユーザーID（オプション）",
        help="LiteLLMのエンドユーザーID"
    )
    
    # Langfuse設定
    st.markdown("---")
    st.markdown("**Langfuse設定**")
    
    if not langfuse_available:
        st.error("❌ Langfuseが利用できません")
        enable_langfuse = False
    else:
        enable_langfuse = st.checkbox("Langfuseトレースを有効化", value=True)
    
    session_id = st.text_input(
        "セッションID（オプション）",
        value=f"session-{datetime.now().strftime('%Y%m%d-%H%M%S')}",
        help="LangfuseのセッションID"
    )
    
    # デバッグ用：Langfuse接続テスト
    if st.button("Langfuse接続テスト") and langfuse_available:
        try:
            # デバッグ情報を表示
            st.info(f"Langfuse Host: {os.environ.get('LANGFUSE_HOST', 'Not set')}")
            st.info(f"Public Key: {os.environ.get('LANGFUSE_PUBLIC_KEY', 'Not set')[:10]}...")
            
            # SDK v3の正しい方法でトレースを送信
            # 1. スパンを作成（user_idとsession_idを引数から削除）
            with langfuse.start_as_current_span(
                name="connection-test",
                input={"test": "connection", "timestamp": datetime.now().isoformat()},
                metadata={"test_type": "connection", "app": "litellm-chat"}
            ) as span:
                # 2. スパンを更新（user_idとsession_idをここで設定）
                span.update(
                    output={"status": "success", "message": "Connection test completed"},
                    user_id="test-user",
                    session_id=f"test-session-{datetime.now().strftime('%Y%m%d-%H%M%S')}",
                    metadata={"test_result": "success"}
                )
            
            # 3. フラッシュを確実に実行
            langfuse.flush()
            st.success("✅ Langfuse接続成功")
            st.info("トレースが送信されました。Langfuseの画面で確認してください。")
            
        except Exception as e:
            st.error(f"❌ Langfuse接続エラー: {str(e)}")
            st.error(f"エラー詳細: {type(e).__name__}: {str(e)}")

# @observeデコレータを使用した関数
@observe
def call_litellm_api(litellm_url, api_key, selected_model, system_message, messages):
    """LiteLLM APIを呼び出す関数（@observeデコレータで自動トレース）"""
    response = requests.post(
        f"{litellm_url}/v1/chat/completions",
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json"
        },
        json={
            "model": selected_model,
            "messages": [
                {"role": "system", "content": system_message},
                *messages
            ],
            "temperature": 0.7,
            "max_tokens": 1000
        }
    )
    return response

# メイン画面
st.title("💬 LiteLLM Chat App")

# チャット履歴の初期化
if "messages" not in st.session_state:
    st.session_state.messages = []

# セッションIDの初期化（StreamlitのセッションIDを使用）
if "langfuse_session_id" not in st.session_state:
    st.session_state.langfuse_session_id = f"session-{datetime.now().strftime('%Y%m%d-%H%M%S')}"

# チャット履歴の表示
for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

# チャット入力処理
if prompt := st.chat_input("メッセージを入力してください..."):
    # ユーザーメッセージを履歴に追加
    st.session_state.messages.append({"role": "user", "content": prompt})
    
    # ユーザーメッセージを表示
    with st.chat_message("user"):
        st.markdown(prompt)
    
    # アシスタントの応答を生成
    with st.chat_message("assistant"):
        with st.spinner("応答を生成中..."):
            try:
                # Langfuseトレースの開始（SDK v3のコンテキストマネージャー）
                if enable_langfuse and langfuse_available:
                    with langfuse.start_as_current_span(
                        name="chat-completion",
                        input={"messages": st.session_state.messages},
                        metadata={
                            "model": selected_model,
                            "system_message": system_message,
                            "litellm_url": litellm_url
                        }
                    ) as span:
                        # セッションIDをトレースに追加（正しい方法）
                        langfuse.update_current_trace(
                            session_id=st.session_state.langfuse_session_id,
                            user_id=end_user if end_user else "anonymous"
                        )
                        
                        st.sidebar.success("✅ Langfuseトレース開始")
                        
                        # LiteLLM API呼び出し（@observeデコレータで自動トレース）
                        response = call_litellm_api(
                            litellm_url, api_key, selected_model, 
                            system_message, st.session_state.messages
                        )
                        
                        if response.status_code == 200:
                            result = response.json()
                            assistant_response = result["choices"][0]["message"]["content"]
                            
                            # アシスタントの応答を表示
                            st.markdown(assistant_response)
                            
                            # アシスタントの応答を履歴に追加
                            st.session_state.messages.append({
                                "role": "assistant", 
                                "content": assistant_response
                            })
                            
                            # Langfuseにトレースを送信
                            span.update(
                                output={"response": assistant_response},
                                metadata={
                                    "model": selected_model,
                                    "system_message": system_message,
                                    "litellm_url": litellm_url,
                                    "usage": result.get("usage", {}),
                                    "response_time": datetime.now().isoformat(),
                                    "message_count": len(st.session_state.messages)
                                }
                            )
                            langfuse.flush()
                            st.sidebar.success("✅ Langfuseトレース送信完了")
                            
                            # 使用量情報を表示
                            if "usage" in result:
                                usage = result["usage"]
                                st.caption(f"使用トークン: {usage.get('total_tokens', 'N/A')}")
                                
                        else:
                            st.error(f"エラー: {response.status_code} - {response.text}")
                            
                            # エラー時もLangfuseに記録
                            span.update(
                                output={"error": f"{response.status_code} - {response.text}"},
                                metadata={
                                    "model": selected_model,
                                    "system_message": system_message,
                                    "litellm_url": litellm_url,
                                    "error": True,
                                    "error_time": datetime.now().isoformat(),
                                    "message_count": len(st.session_state.messages)
                                }
                            )
                            langfuse.flush()
                else:
                    # Langfuseが無効な場合は通常のAPI呼び出し
                    response = call_litellm_api(
                        litellm_url, api_key, selected_model, 
                        system_message, st.session_state.messages
                    )
                    
                    if response.status_code == 200:
                        result = response.json()
                        assistant_response = result["choices"][0]["message"]["content"]
                        
                        # アシスタントの応答を表示
                        st.markdown(assistant_response)
                        
                        # アシスタントの応答を履歴に追加
                        st.session_state.messages.append({
                            "role": "assistant", 
                            "content": assistant_response
                        })
                        
                        # 使用量情報を表示
                        if "usage" in result:
                            usage = result["usage"]
                            st.caption(f"使用トークン: {usage.get('total_tokens', 'N/A')}")
                    else:
                        st.error(f"エラー: {response.status_code} - {response.text}")
                    
            except Exception as e:
                st.error(f"エラーが発生しました: {str(e)}")
                
                # 例外時もLangfuseに記録
                if enable_langfuse and langfuse_available:
                    try:
                        with langfuse.start_as_current_span(
                            name="exception-handling",
                            input={"error": str(e)},
                            metadata={
                                "model": selected_model,
                                "system_message": system_message,
                                "litellm_url": litellm_url,
                                "exception": True,
                                "exception_time": datetime.now().isoformat()
                            }
                        ) as span:
                            # セッションIDをトレースに追加
                            langfuse.update_current_trace(
                                session_id=st.session_state.langfuse_session_id,
                                user_id=end_user if end_user else "anonymous"
                            )
                            
                            span.update(
                                output={"error": str(e)}
                            )
                            langfuse.flush()
                    except Exception as trace_error:
                        st.sidebar.error(f"❌ Langfuse例外トレース送信エラー: {str(trace_error)}")

# チャット履歴のクリア
if st.button("チャット履歴をクリア"):
    st.session_state.messages = []
    # セッションIDもリセット
    st.session_state.langfuse_session_id = f"session-{datetime.now().strftime('%Y%m%d-%H%M%S')}"
    st.rerun()

# 使用量表示
if st.session_state.messages:
    st.sidebar.markdown("---")
    st.sidebar.markdown(f"**メッセージ数**: {len(st.session_state.messages)}")
    
    # Langfuse情報表示
    if enable_langfuse and langfuse_available:
        st.sidebar.markdown(f"**セッションID**: {st.session_state.langfuse_session_id}")
        st.sidebar.markdown(f"**ユーザーID**: {end_user if end_user else 'anonymous'}")