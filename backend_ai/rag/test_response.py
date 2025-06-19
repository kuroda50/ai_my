from dotenv import load_dotenv
from openai import OpenAI

load_dotenv()
client = OpenAI()

messages = []  # 会話履歴保持用
count = 0

while True:
    print("---")
    input_message = input(f"[{count}]あなた: ")
    if input_message.lower() == "終了":
        break

    # ユーザー発言を履歴に追加
    messages.append({"role": "user", "content": input_message})

    # AIに会話履歴を渡す
    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=messages
    )

    # AIの返答を取得し履歴に追加
    ai_message = response.choices[0].message.content
    print(f"[{count}]AI: {ai_message}")
    messages.append({"role": "assistant", "content": ai_message})

    count += 1

