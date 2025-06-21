from openai_client import client



def ai_chat_between_characters(vector_store_ids: list[str], event: dict) -> None:
    """
    AIキャラクターAとBの間で会話をシミュレートする関数（履歴を明示的に保持）
    """
    print("=== AI同士の会話を開始します ===\n")


    # 会話履歴を保持
    system_prompt_a = {
        "role": "system",
        "content": """あなたはキャラクターAです。
            以下の「思想」に基づいて、キャラクターAとして自然に話してください。
            キャラになりきって、友達に話しかけるように砕けた口調で、自然に答えてください。
            - 思想: 学歴に囚われず自分の価値を見出す
            - 補足: 学歴の劣等感から他者を避けがちだが、学歴以外の部分で努力し、自分自身の価値を高めようとしている。""",
    }
    system_prompt_b = {
        "role": "system",
        "content": """あなたはキャラクターBです。
            以下の「思想」に基づいて、キャラクターBとして自然に話してください。
            キャラになりきって、友達に話しかけるように砕けた口調で、自然に答えてください。
            - 思想: 自由を追求し、自己に正直に生きる
            - 補足: 彼/彼女は社会の期待に縛られることを恐れ、自分の自然な感情や欲望に忠実であることを重視しています。""",
    }

    messages_a = [system_prompt_a, {"role": "user", "content": format_event(event)}]
    messages_b = [system_prompt_b, {"role": "assistant", "content": format_event(event)}]
    print("最初のイベント: ",format_event(event))

    for i in range(3):
        # Aの応答を生成

        print(f"\n[Turn {i+1}-A] キャラA:")
        response_a = client.chat.completions.create(
            model="gpt-4o",
            messages=messages_a,
            tools=[
                {
                    "type": "function",
                    "function": {"name": "file_search"},
                    "vector_store_ids": [vector_store_ids[0]],
                    "max_num_results": 5,
                }
            ],
        )

        output_a = response_a.choices[0].message.content
        print(output_a)
        messages_a.append({"role": "assistant", "content": output_a})
        messages_b.append({"role": "user", "content": output_a})


        # Bの応答を生成
        print(f"\n[Turn {i+1}-B] キャラB:")
        response_b = client.chat.completions.create(
            model="gpt-4o",
            messages=messages_b,
            tools=[
                {
                    "type": "function",
                    "function": {"name": "file_search"},
                    "vector_store_ids": [vector_store_ids[1]],
                    "max_num_results": 5,
                }
            ],
        )

        output_b = response_b.choices[0].message.content
        print(output_b)
        messages_a.append({"role": "assistant", "content": output_b})
        messages_b.append({"role": "user", "content": output_b})

    print("\n=== 会話終了 ===")
    print(messages_a)
    return messages_a


def format_event(event: dict) -> str:
    """
    5W1H形式のイベントを自然な日本語のシチュエーション文に変換する
    例：{'who': '俺', 'what': '財布忘れた', 'when': '昼のラーメン屋', ...}
    """
    who = event.get("who", "誰か")
    what = event.get("what", "")
    when = event.get("when", "")
    where = event.get("where", "")
    why = event.get("why", "")
    how = event.get("how", "")

    message = f"{when}、{where}で{who}が{what}。{why}。{how}"
    return message.strip("。") + "。どう思う？"


# def ai_chat_between_characters(vector_store_ids: list[str], event: dict) -> None:
#     """
#     AIキャラクターAとBの間で会話をシミュレートする関数
#     """
#     print("=== AI同士の会話を開始します ===\n")

#     # 初期イベント文をセット
#     message = format_event(event)
#     messages = []
#     messages[0] = format_event(event)
#     print(f"初期イベント: {messages[0]}\n")
#     previous_response_id = None

#     # キャラの交互ターン（最初→A→B→A…）
#     for i in range(4):
#         print(f"\n[Turn {i+1}-A] キャラA:")
#         response_a = client.responses.create(
#             model="gpt-4o-mini",
#             input="""あなたはキャラクターAです。
#                     以下の「思想」に基づいて、キャラクターAとして自然に話してください。
#                     キャラになりきって、友達に話しかけるように砕けた口調で、自然に答えてください。
#                     - 思想: 学歴に囚われず自分の価値を見出す
#                     - 補足: 学歴の劣等感から他者を避けがちだが、学歴以外の部分で努力し、自分自身の価値を高めようとしている。
#                     相手のセリフ: """
#             + messages[2 * i],
#             tools=[
#                 {
#                     "type": "file_search",
#                     "vector_store_ids": [vector_store_ids[0]],
#                     "max_num_results": 5,
#                 }
#             ],
#             include=["file_search_call.results"],
#             previous_response_id=previous_response_id,
#         )
#         message = response_a.output_text
#         print(message)
#         previous_response_id = response_a.id

#         print(f"\n[Turn {i+1}-B] キャラB:")
#         response_b = client.responses.create(
#             model="gpt-4o-mini",
#             input="""あなたはキャラクターBです。
#                     以下の「思想」に基づいて、キャラクターBとして自然に話してください。
#                     キャラになりきって、友達に話しかけるように砕けた口調で、自然に答えてください。
#                     - 思想: 自由を追求し、自己に正直に生きる
#                     - 補足: 彼/彼女は社会の期待に縛られることを恐れ、自分の自然な感情や欲望に忠実であることを重視しています。そのため、自分に合った環境を求め、強制される状況からは逃げる傾向があります。
#                     出力単語数は80～120語程度にしてください。
#                     相手のセリフ: """
#             + messages[2 * i + 1],
#             tools=[
#                 {
#                     "type": "file_search",
#                     "vector_store_ids": [vector_store_ids[1]],
#                     "max_num_results": 5,
#                 }
#             ],
#             include=["file_search_call.results"],
#             previous_response_id=previous_response_id,
#         )
#         message = response_b.output_text
#         print(message)
#         previous_response_id = response_b.id

#     print("\n=== 会話終了 ===")

