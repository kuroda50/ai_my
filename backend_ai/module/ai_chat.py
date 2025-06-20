from openai_client import client
from prompt.character_generation import generate_character_prompt

def ai_chat(user_input: dict) -> str:
    
    response = client.chat.completions.create(
        model="gpt-4.1-mini",
        messages=[
            {"role": "user", "content": generate_character_prompt(user_input)}
        ],
        temperature=0.8
    )

    # 応答からテキスト取得
    output_text = response.choices[0].message["content"]
    # 保存
    output_path = "backend_ai/data/character/character.txt"
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(output_text)
        
    print(f"✅ キャラシートを生成しました")
    return output_text