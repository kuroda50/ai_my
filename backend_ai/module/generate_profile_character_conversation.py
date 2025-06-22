from openai_client import client
import os

def generate_profile_character_conversation(character_settings: str, character_index: int) -> str:
    """
    プロフィールキャラクターの会話例を生成する
    """
    
    prompt = f"""
以下のキャラクター設定に基づいて、このキャラクターらしい会話例を5つ生成してください。
このキャラクターは理想的でポジティブな自分を表現するAIです。

【キャラクター設定】
{character_settings}

【出力形式】
以下の形式で会話例を生成してください：

会話例1:
キャラ名: [ポジティブで前向きなメッセージ]

会話例2:
キャラ名: [建設的なアドバイスや励ましのメッセージ]

会話例3:
キャラ名: [自分の価値観や目標について語るメッセージ]

会話例4:
キャラ名: [他者との良好な関係について語るメッセージ]

会話例5:
キャラ名: [未来への希望や成長について語るメッセージ]

【注意事項】
- キャラクターの設定に合った口調・一人称を使用
- ポジティブで建設的な内容
- 相手に元気や希望を与えるような内容
- 各メッセージは50-100文字程度
- 親しみやすく、自然な会話
"""

    try:
        response = client.chat.completions.create(
            model="gpt-4o",
            messages=[
                {"role": "system", "content": "あなたはキャラクターの会話生成の専門家です。与えられた設定に基づいて自然で魅力的な会話例を生成してください。"},
                {"role": "user", "content": prompt}
            ],
            max_tokens=1500,
            temperature=0.8
        )
        
        conversation_data = response.choices[0].message.content
        
        # ファイルに保存
        character_dir = f"backend_ai/data/character/{character_index}"
        os.makedirs(character_dir, exist_ok=True)
        
        with open(f"{character_dir}/conversation.txt", "w", encoding="utf-8") as f:
            f.write(conversation_data)
        
        print(f"プロフィール会話データがcharacter/{character_index}/conversation.txtに保存されました")
        
        return conversation_data
        
    except Exception as e:
        print(f"プロフィール会話データ生成エラー: {e}")
        return f"プロフィール会話データ生成に失敗しました: {e}"