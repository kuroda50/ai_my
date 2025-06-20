from openai_client import client
from prompt.character_generation import generate_character_prompt

def generate_character_settings(user_input: dict, character_index: int) -> str:
    
    response = client.chat.completions.create(
        model="gpt-4.1-mini",
        messages=[
            {"role": "user", "content": generate_character_prompt(user_input)}
        ],
        temperature=0.8
    )

    # 応答からテキスト取得
    output_text = response.choices[0].message.content
    # 保存
    if(character_index == 0):
        output_path = "backend_ai/data/character/A/settings.txt"
    elif(character_index == 1):
        output_path = "backend_ai/data/character/B/settings.txt"
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(output_text)
        
    print(f"✅ キャラシートを生成しました")
    return output_text