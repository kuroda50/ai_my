# Flutter App と Backend AI の統合

このプロジェクトは、Flutter アプリから backend_ai の Python システムを使ってAIキャラクターを生成し、対話できるシステムです。

## 実装した機能

### 1. データ変換システム
- **a.dart** の5W1H入力 + 感情パラメーター
- **complex_form.dart** のコンプレックス分析（9つの質問）
- 上記データを backend_ai の期待する形式に自動変換

### 2. AI キャラクター生成
- ユーザーの入力データから GPT-4.1-mini がキャラクター設定を生成
- 生成されたキャラクターの会話例を10件作成
- OpenAI Vector Store にデータを保存

### 3. AI 対話システム
- 生成されたキャラクターとリアルタイム対話
- **b.dart** でキャラクターをタップ/ドラッグして会話開始
- AIキャラクターには専用の対話UI を使用

## セットアップ手順

### Backend AI の準備

1. Python依存関係をインストール：
```bash
cd backend_ai
pip install flask flask-cors openai python-dotenv
```

2. 環境変数を設定（.envファイル）：
```
OPENAI_API_KEY=your_openai_api_key
```

3. バックエンドサーバーを起動：
```bash
python main.py
```

### Flutter アプリの準備

1. 依存関係をインストール：
```bash
cd flutter_app
flutter pub get
```

2. アプリを実行：
```bash
flutter run
```

## データフロー

```
a.dart (5W1H + 感情) 
    ↓
complex_form.dart (9つの質問)
    ↓
AIService.generateCharacter() (データ変換)
    ↓
backend_ai/generate_character API
    ↓
GPT-4.1-mini でキャラクター生成
    ↓
Vector Store にアップロード
    ↓
b.dart で AI キャラクターと対話
```

## API エンドポイント統合

### キャラクター生成
- **エンドポイント**: `POST /generate_character`
- **Flutter側**: `AIService.generateCharacter()`
- **変換処理**: 5W1H + 感情 + コンプレックス → backend_ai 形式

### AI 対話
- **実装**: `AIConversationDialog` ウィジェット
- **将来拡張**: RAG システムと連携予定

## 使用方法

1. **a.dart** で5W1H と感情パラメーターを入力
2. **complex_form.dart** でコンプレックス分析の9つの質問に回答
3. 「AIキャラクターを生成」ボタンでAI処理を実行
4. **b.dart** でAI生成されたキャラクターが表示される
5. キャラクターをタップ/ドラッグして対話開始

## 技術仕様

- **Frontend**: Flutter (Dart)
- **Backend**: Flask (Python)
- **AI Model**: OpenAI GPT-4.1-mini
- **Vector Database**: OpenAI Vector Store
- **HTTP Client**: Dart http package

## 注意事項

- backend_ai サーバーが `http://localhost:5000` で起動している必要があります
- OpenAI API キーが正しく設定されている必要があります
- AIキャラクター生成には数秒から数十秒かかる場合があります