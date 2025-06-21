from openai_client import client
from prompt.conversation_generation import generate_conversation_prompt
import os

def generate_character_conversation(character_definition: str,character_index: int, character_philosophy: str) -> list:
    response = client.chat.completions.create(
        model="gpt-4.1-mini",
        messages=[
            {"role": "user", "content": generate_conversation_prompt(character_definition, character_philosophy)}
        ],
        temperature=0.8
    )

    # 応答からテキスト取得
    output_text = response.choices[0].message.content

    # 保存
    output_dir = f"backend_ai/data/character/{character_index}"
    os.makedirs(output_dir, exist_ok=True)
    
    output_path = os.path.join(output_dir, "conversation.txt")
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(output_text)

    print(f"✅ 会話データを {output_path} に保存しました")
    return output_text
    