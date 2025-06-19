from openai_client import openai
from prompt.character_generation import generate_character_prompt

def generate_character(user_input: dict) -> str:
    
    response = openai.ChatCompletion.create(
        model="gpt-4.1-mini",
        messages=[
            {"role": "user", "content": generate_character_prompt(user_input)}
        ],
        temperature=0.8
    )

    # 応答からテキスト取得
    output_text = response.choices[0].message["content"]
    # 保存
    output_path = "test2/data/character/character.txt"
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(output_text)
        
    print(f"✅ キャラシートを生成しました")
    return output_text