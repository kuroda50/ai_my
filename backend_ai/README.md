# Backend AI - キャラクター生成・AI会話システム

このプロジェクトは、ユーザーの悩みや価値観に基づいてAIキャラクターを生成し、そのキャラクターと対話できるシステムです。

## システム概要

### 主要機能
1. **キャラクター生成**: ユーザーの質問回答をもとに共感できるキャラクターを自動生成
2. **AI会話**: 生成されたキャラクターとリアルタイムで会話
3. **ベクトル検索**: キャラクター情報をベクトル化してコンテキストを活用した対話

## ディレクトリ構成

```
backend_ai/
├── main.py                 # Flaskサーバーのエントリーポイント
├── openai_client.py        # OpenAI APIクライアント設定
├── module/                 # 主要な機能モジュール
│   ├── generate_character_settings.py    # キャラクター設定生成
│   ├── generate_character_conversation.py # 会話データ生成
│   ├── vector_store.py     # ベクトルストア管理
│   ├── upload_content.py   # ファイルアップロード
│   ├── ai_chat.py         # AI会話処理
│   └── utils.py           # ユーティリティ関数
├── prompt/                # プロンプトテンプレート
│   ├── character_generation.py      # キャラ生成プロンプト
│   ├── conversation_generation.py   # 会話生成プロンプト
│   └── finetune_instructions.txt   # ファインチューニング用指示
├── data/                  # 生成データ保存
│   ├── character/
│   │   ├── A/            # キャラクターA用データ
│   │   │   ├── settings.txt      # キャラ設定
│   │   │   └── conversation.txt  # 会話例
│   │   └── B/            # キャラクターB用データ
│   └── input/
│       ├── answers.json  # ユーザー回答データ
│       └── answers copy.json
└── rag/                  # RAG（Retrieval Augmented Generation）
    ├── query_vectorsearch_with_history.py  # 履歴付き検索
    └── test_response.py  # レスポンステスト
```

## API エンドポイント

### 1. キャラクター生成 `/generate_character`
**Method**: POST

**リクエストボディ**:
```json
{
    "character_index": 0,
    "q0_answer": "20代、学生、大学3年生",
    "q1_answer": "人前で話すのが苦手で...",
    "q2_answer": "プレゼンテーションで...",
    "q3_answer": "練習したが緊張して...",
    "q4_answer": "真面目だけど自信がない人",
    "q5_answer": "同じ悩みを持つ仲間との出会い"
}
```

**処理フロー**:
1. ユーザーの回答からキャラクター設定を生成
2. そのキャラクターの会話例を生成
3. ベクトルストアを作成
4. 生成データをベクトルストアにアップロード

### 2. AI会話 `/ai_chat`
**Method**: POST

**リクエストボディ**:
```json
{
    "character_id": ["character1", "character2"]
}
```

## 技術詳細

### キャラクター生成プロセス
1. **プロンプト生成**: `prompt/character_generation.py`でユーザー回答を基にプロンプト作成
2. **AI生成**: GPT-4.1-miniを使用してキャラクター設定を生成
3. **会話例生成**: 生成されたキャラクター設定から会話例を10件作成
4. **データ保存**: `data/character/[A|B]/`にテキストファイルとして保存

### ベクトル検索システム
- OpenAIのVector Storeを使用
- キャラクター設定と会話例をベクトル化
- RAGによるコンテキスト活用で自然な対話を実現

### 使用技術
- **Backend**: Flask (Python)
- **AI Model**: OpenAI GPT-4.1-mini
- **Vector Search**: OpenAI Vector Store
- **Environment**: python-dotenv

## セットアップ

1. 環境変数設定 (`.env`ファイル)
```
OPENAI_API_KEY=your_openai_api_key
```

2. 依存関係インストール
```bash
pip install flask flask-cors openai python-dotenv
```

3. サーバー起動
```bash
python main.py
```

サーバーは `http://localhost:5000` で起動します。

## 使用例

キャラクター生成後、`rag/query_vectorsearch_with_history.py`を実行することで、生成されたキャラクターと対話型のチャットができます。