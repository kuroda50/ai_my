from dotenv import load_dotenv
from openai import OpenAI
import os

# .env
load_dotenv()

# OpenAI client
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

def ai_chat_between_characters(vector_store_ids: list[str]) -> None:
    """
    AIキャラクターAとBの間で会話をシミュレートする関数
    """
    print("=== AI同士の会話を開始します ===\n")

    # 初期入力
    message = "こんにちは"
    previous_response_id = None

    # キャラの交互ターン（0→A, 1→B）
    for i in range(5):
        # キャラAの発言
        print(f"\n[Turn {i+1}-A] キャラA:")
        response_a = client.responses.create(
            model="gpt-4o-mini",
            input="以下の発言にキャラAとして応答してください。\n相手の発言：" + message,
            tools=[{
                "type": "file_search",
                "vector_store_ids": [vector_store_ids[0]],
                "max_num_results": 5
            }],
            include=["file_search_call.results"],
            previous_response_id=previous_response_id
        )
        message = response_a.output_text
        print(message)
        previous_response_id = response_a.id

        # キャラBの発言
        print(f"\n[Turn {i+1}-B] キャラB:")
        response_b = client.responses.create(
            model="gpt-4o-mini",
            input="以下の発言にキャラBとして応答してください。\n相手の発言：" + message,
            tools=[{
                "type": "file_search",
                "vector_store_ids": [vector_store_ids[1]],
                "max_num_results": 5
            }],
            include=["file_search_call.results"],
            previous_response_id=previous_response_id
        )
        message = response_b.output_text
        print(message)
        previous_response_id = response_b.id

    print("\n=== 会話終了 ===")




# from dotenv import load_dotenv
# from openai import OpenAI

# # .env
# load_dotenv()

# # OpenAI client
# client = OpenAI()

# # Vector Store ID
# VECTOR_STORE_ID = "vs_6853b7ee203c81919e2ba157763f3eab"

# def ai_chat(vector_store_id: str):
#     """
#     AIどうしのチャットを生成する関数
#     """
    
#     # 会話履歴の初期化
#     count = 0
#     previous_response_id = None

#     for i in range(10):  # 2キャラクターの会話をシミュレート
#         # 会話を入力
#         print("---")
#         input_message = input(f"[{count}]あなた: ")
#         if input_message.lower() == "終了":
#             break

#         # 生成AIが回答を生成
#         response = client.responses.create(
#             model="gpt-4o-mini",
#             input="fileを参照しながらそのキャラになりきって発言してください\nユーザーの発言：" + input_message,
#             tools=[{
#                 "type": "file_search",
#                 "vector_store_ids": [vector_store_id],
#                 "max_num_results": 5
#             }],
#             include=["file_search_call.results"],
#             previous_response_id=previous_response_id
#         )

#         # Extract annotations from the response
#         annotations = None
#         if len(response.output) > 1:
#             annotations = response.output[1].content[0].annotations

#         # Get top-k retrieved filenames
#         retrieved_files = set([result.filename for result in annotations]) if annotations else None

#         print(f'Files used: {retrieved_files}')
#         print(f"[{count}]AI:\n")
#         print(response.output_text)

#         # 会話履歴を更新
#         previous_response_id = response.id
#         count += 1