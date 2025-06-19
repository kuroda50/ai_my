from openai_client import openai
from prompt.conversation_generation import generate_conversation_prompt

def generate_convos(character_definition: str) -> list:
    response = openai.ChatCompletion.create(
        model="gpt-4.1-mini",
        messages=[
            {"role": "user", "content": generate_conversation_prompt(character_definition)}
        ],
        temperature=0.8
    )

    # 応答からテキスト取得
    output_text = response.choices[0].message["content"]

    # 保存
    output_path = "test2/data/conersation/training_data.jsonl"
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(output_text)

    print(f"✅ 会話データを {output_path} に保存しました")
    return output_text
    