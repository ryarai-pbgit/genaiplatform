import streamlit as st
import requests
import json
from datetime import datetime

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
        value="http://genai-platform-alb-1292090426.ap-northeast-1.elb.amazonaws.com",
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

# メイン画面
st.title("💬 LiteLLM Chat App")

# チャット履歴の初期化
if "messages" not in st.session_state:
    st.session_state.messages = []

# チャット履歴の表示
for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

# チャット入力
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
                # LiteLLM API呼び出し
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
                            *st.session_state.messages
                        ],
                        "temperature": 0.7,
                        "max_tokens": 1000
                    }
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

# チャット履歴のクリア
if st.button("チャット履歴をクリア"):
    st.session_state.messages = []
    st.rerun()

# 使用量表示
if st.session_state.messages:
    st.sidebar.markdown("---")
    st.sidebar.markdown(f"**メッセージ数**: {len(st.session_state.messages)}")