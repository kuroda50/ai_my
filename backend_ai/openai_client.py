from openai import OpenAI
import os
from dotenv import load_dotenv

load_dotenv()  # .env から読み込む

# APIキーを一度だけ設定
# openai.api_key = os.getenv("OPENAI_API_KEY")
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))