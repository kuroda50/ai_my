from dotenv import load_dotenv
from openai import OpenAI

# .env
load_dotenv()

# OpenAI client
client = OpenAI()

# Vector Store ID
VECTOR_STORE_ID = "vs_6853b7ee203c81919e2ba157763f3eab"

count = 0
previous_response_id = None
while True:

    # 会話を入力
    print("---")
    input_message = input(f"[{count}]あなた: ")
    if input_message.lower() == "終了":
        break

    # 生成AIが回答を生成
    response = client.responses.create(
        model="gpt-4o-mini",
        input="fileを参照しながらそのキャラになりきって発言してください\nユーザーの発言：" + input_message,
        tools=[{
            "type": "file_search",
            "vector_store_ids": [VECTOR_STORE_ID],
            "max_num_results": 5
        }],
        include=["file_search_call.results"],
        previous_response_id=previous_response_id
    )

    # Extract annotations from the response
    annotations = None
    if len(response.output) > 1:
        annotations = response.output[1].content[0].annotations

    # Get top-k retrieved filenames
    retrieved_files = set([result.filename for result in annotations]) if annotations else None

    print(f'Files used: {retrieved_files}')
    print(f"[{count}]AI:\n")
    print(response.output_text)

    # 会話履歴を更新
    previous_response_id = response.id
    count += 1