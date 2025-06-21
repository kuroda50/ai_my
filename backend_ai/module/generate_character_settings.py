from openai_client import client
from prompt.character_generation import generate_character_prompt
import os

def generate_character_settings(user_input: dict, character_index: int, character_philosophy: str) -> str:
    
    response = client.chat.completions.create(
        model="gpt-4.1-mini",
        messages=[
            {"role": "user", "content": generate_character_prompt(user_input, character_philosophy)}
        ],
        temperature=0.8
    )

    # 応答からテキスト取得
    output_text = response.choices[0].message.content
    
    # 保存
    output_dir = f"backend_ai/data/character/{character_index}"
    os.makedirs(output_dir, exist_ok=True)
    
    output_path = os.path.join(output_dir, "settings.txt")
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(output_text)
        
    print(f"✅ キャラシートを生成しました")
    return output_text