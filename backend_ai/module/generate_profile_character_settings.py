from openai_client import client
import os

def generate_profile_character_settings(profile_data: dict, character_index: int) -> str:
    """
    プロフィール情報からポジティブなAIキャラクターの設定を生成する
    """
    
    # プロフィール情報を整理
    name = profile_data.get('name', '名前未設定')
    gender = profile_data.get('gender', '性別未設定')
    age = profile_data.get('age', '年齢未設定')
    appearance = profile_data.get('appearance', '外見未設定')
    first_person = profile_data.get('firstPerson', '一人称未設定')
    personality = profile_data.get('personality', '性格未設定')
    background = profile_data.get('background', '背景未設定')
    goal = profile_data.get('goal', '目標未設定')
    conversation_style = profile_data.get('conversationStyle', '会話スタイル未設定')
    ideal_image = profile_data.get('idealImage', '理想像未設定')
    
    prompt = f"""
以下のプロフィール情報に基づいて、理想的でポジティブな自分を表現するAIキャラクターの設定を日本語で生成してください。
このキャラクターは、ユーザーの良い部分を強調し、前向きで建設的な視点を持つ存在として設計します。

【プロフィール情報】
名前: {name}
性別: {gender}
年齢: {age}
外見・服装: {appearance}
一人称・口癖: {first_person}
性格・価値観: {personality}
背景・現在の状況: {background}
目標・モチベーション: {goal}
話し方・会話スタイル: {conversation_style}
他者との関係性(理想像): {ideal_image}

【出力形式】
以下の形式で詳細なキャラクター設定を生成してください：

名前：{name}（プロフィールAI）
年齢：{age}
性別：{gender}
外見：{appearance}
性格：{personality}をベースに、さらにポジティブで前向きな要素を強化
一人称：{first_person}
口癖・特徴的な話し方：{conversation_style}の特徴を活かした明るい表現
価値観：{goal}を大切にし、{ideal_image}を実現しようとする
現在の状況：{background}を活かして成長し続けている
特技・得意なこと：プロフィール情報から推測される強みや才能
弱点・苦手なこと：完璧すぎず、親しみやすさを保つための軽微な弱点
趣味・興味：プロフィールに合致する健全で建設的な趣味
人生の目標：{goal}をさらに具体化し、社会貢献も含めた大きな目標
モットー・座右の銘：ポジティブで前向きな人生哲学

【注意事項】
- このキャラクターは理想的な自分を表現するため、基本的にポジティブで希望に満ちている
- ユーザーの良い部分を強調し、成長への意欲を示す
- 親しみやすく、建設的なアドバイスができる性格
- 完璧すぎず、人間らしい魅力も持つ
"""

    try:
        response = client.chat.completions.create(
            model="gpt-4o",
            messages=[
                {"role": "system", "content": "あなたは心理学とキャラクター設定の専門家です。ユーザーのプロフィール情報から理想的でポジティブなAIキャラクターを生成してください。"},
                {"role": "user", "content": prompt}
            ],
            max_tokens=2000,
            temperature=0.7
        )
        
        character_settings = response.choices[0].message.content
        
        # ファイルに保存
        character_dir = f"backend_ai/data/character/{character_index}"
        os.makedirs(character_dir, exist_ok=True)
        
        with open(f"{character_dir}/settings.txt", "w", encoding="utf-8") as f:
            f.write(character_settings)
        
        print(f"プロフィールキャラクター設定がcharacter/{character_index}/settings.txtに保存されました")
        
        return character_settings
        
    except Exception as e:
        print(f"プロフィールキャラクター設定生成エラー: {e}")
        return f"プロフィールキャラクター設定生成に失敗しました: {e}"