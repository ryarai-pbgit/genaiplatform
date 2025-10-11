```bash
# プロジェクトディレクトリを作成
mkdir litellm-chat-app
cd litellm-chat-app

# 仮想環境を作成
python3 -m venv venv

# 仮想環境をアクティベート
source venv/bin/activate

# 必要なパッケージをインストール
pip install streamlit openai requests
