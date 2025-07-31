from openai_client import client



def ai_chat_between_characters(vector_store_ids: list[str], event: dict, character_data=None) -> None:
    """
    プロフィールAIとコンプレックスAIの間で会話をシミュレートする関数
    """
    print("=== プロフィールAI vs コンプレックスAI 会話を開始します ===\n")
    print("キャラクターデータ:", character_data)

    # デフォルト設定
    profile_ai_name = "プロフィールAI"
    complex_ai_name = "俺２"
    profile_ai_philosophy = "自分らしく前向きに生きる"
    profile_ai_details = "あなたのプロフィール情報に基づいて作られた、ポジティブで理想的な自分の側面を表現するAI。"
    complex_ai_philosophy = "コンプレックスと向き合い成長する"
    complex_ai_details = "あなたのコンプレックスから生まれた、課題や悩みを抱えながらも成長しようとする自分の側面を表現するAI。"
    
    # キャラクターデータが提供されている場合は使用
    if character_data and len(character_data) >= 2:
        try:
            # ユーザー（ID: 0）、プロフィールAI（ID: 1000番台）、コンプレックスAI（ID: 2000番台）を識別
            user_person = None
            profile_ai = None
            complex_ai = None
            
            for char in character_data:
                char_id = char.get('id', 0)
                if char_id == 0:
                    user_person = char
                elif 1000 <= char_id < 2000:
                    profile_ai = char
                elif 2000 <= char_id < 3000:
                    complex_ai = char
            
            # ユーザー（あなた）の設定
            if user_person:
                if user_person.get('name'):
                    profile_ai_name = f"{user_person['name']}（あなた）"
                # ユーザーのプロフィール基本データから哲学を抽出
                if user_person.get('basicData'):
                    basic_data = user_person['basicData']
                    if basic_data.get('personality'):
                        profile_ai_philosophy = basic_data['personality']
                    if basic_data.get('goal'):
                        profile_ai_details = f"目標: {basic_data['goal']}。ユーザー自身の価値観と理想。"
            
            # プロフィールAIの設定（ユーザーがいない場合）
            elif profile_ai:
                if profile_ai.get('name'):
                    # プロフィールAIの場合は、実際の名前を使用
                    profile_ai_name = profile_ai['name']
                # プロフィールAIは基本データから哲学を抽出
                if profile_ai.get('basicData'):
                    basic_data = profile_ai['basicData']
                    if basic_data.get('personality'):
                        profile_ai_philosophy = basic_data['personality']
                    if basic_data.get('goal'):
                        profile_ai_details = f"目標: {basic_data['goal']}。ポジティブで前向きな自分の側面。"
                # AIキャラクター設定からも情報を取得
                if profile_ai.get('aiCharacterSettings'):
                    settings = profile_ai['aiCharacterSettings']
                    # 名前を抽出
                    import re
                    name_match = re.search(r'名前.*?：\s*(.+?)(?:\n|$)', settings, re.MULTILINE)
                    if name_match:
                        extracted_name = name_match.group(1).strip()
                        if extracted_name:
                            profile_ai_name = extracted_name
            
            # コンプレックスAIの設定
            if complex_ai:
                if complex_ai.get('name'):
                    complex_ai_name = complex_ai['name']
                # コンプレックスAIはコンプレックスデータから哲学を抽出
                if complex_ai.get('complexData'):
                    complex_data = complex_ai['complexData']
                    if complex_data.get('question_1'):
                        complex_ai_philosophy = complex_data['question_1']
                    if complex_data.get('question_2'):
                        complex_ai_details = complex_data['question_2']
            
            if user_person and complex_ai:
                print(f"ユーザー（{profile_ai_name}）の思想: {profile_ai_philosophy}")
                print(f"コンプレックスAI（{complex_ai_name}）の思想: {complex_ai_philosophy}")
            elif profile_ai and complex_ai:
                print(f"プロフィールAI（{profile_ai_name}）の思想: {profile_ai_philosophy}")
                print(f"コンプレックスAI（{complex_ai_name}）の思想: {complex_ai_philosophy}")
        except Exception as e:
            print(f"キャラクターデータの解析エラー: {e}")
    
    # 会話履歴を保持
    system_prompt_profile = {
        "role": "system",
        "content": f"""あなたは{profile_ai_name}です。
            あなたはユーザーのプロフィール情報に基づいて作られた、ポジティブで理想的な自分の側面を表現するAIです。
            以下の「思想」に基づいて、{profile_ai_name}として自然に話してください。
            明るく前向きな口調で、建設的なアドバイスや視点を提供してください。
            
            あなたは会話を始める立場として、イベントの当事者として体験を語り、
            その後、相手（{complex_ai_name}）の発言に対して共感しつつも、前向きな解決策や視点を提示してください。
            会話は自然で流れのあるものにし、毎回違った表現や視点を使ってください。
            - 思想: {profile_ai_philosophy}
            - 補足: {profile_ai_details}
            
            重要：以前の発言と同じ内容や表現は避け、会話の流れに沿って新しい視点や具体例を提供してください。""",
    }
    system_prompt_complex = {
        "role": "system",
        "content": f"""あなたは{complex_ai_name}です。
            あなたはユーザーのコンプレックスから生まれた、課題や悩みを抱えながらも成長しようとする自分の側面を表現するAIです。
            以下の「思想」に基づいて、{complex_ai_name}として自然に話してください。
            少し悩みがちだが、成長への意欲を持った口調で話してください。
            相手の発言に対して率直に自分の悩みや不安を表現しつつも、向上心も見せてください。
            会話は自然で流れのあるものにし、毎回違った表現や悩みの側面を表現してください。
            - 思想: {complex_ai_philosophy}  
            - 補足: {complex_ai_details}
            
            重要：以前の発言と同じ内容や表現は避け、会話の流れに沿って新しい悩みや体験を共有してください。""",
    }

    # 共有される会話履歴（両AIが参照する）
    shared_conversation = []
    shared_conversation.append({"role": "system", "content": f"イベント: {format_event(event)}"})
    
    print("最初のイベント: ",format_event(event))

    for i in range(3):
        # プロフィールAIの応答を生成
        print(f"\n[Turn {i+1}-Profile] {profile_ai_name}:")
        
        # プロフィールAI用のメッセージリストを構築
        current_messages_profile = [system_prompt_profile]
        current_messages_profile.extend(shared_conversation)
        
        # ターンごとに異なる指示を追加して多様性を確保
        if i == 0:
            # 最初のターンではイベントについて率直に話す
            instruction = f"上記のイベントについて、{profile_ai_name}として率直に感想や体験を話してください。このような状況について、あなたの視点から感じることを自然に表現してください。"
        else:
            turn_instructions = [
                f"相手の発言に共感しつつ、{profile_ai_name}らしい新しい視点を提供してください。前回とは違った角度から話してください。",
                f"会話を発展させるため、{profile_ai_name}として質問や提案を含めて応答してください。"
            ]
            instruction = turn_instructions[(i-1) % len(turn_instructions)]
        
        current_messages_profile.append({"role": "user", "content": instruction})
        
        response_profile = client.chat.completions.create(
            model="gpt-4o",
            messages=current_messages_profile,
            temperature=0.8,  # より創造的で多様な回答
            top_p=0.9,        # 回答の多様性を確保
            tools=[
                {
                    "type": "function",
                    "function": {"name": "file_search"},
                    "vector_store_ids": [vector_store_ids[0]] if len(vector_store_ids) > 0 else [],
                    "max_num_results": 5,
                }
            ] if len(vector_store_ids) > 0 else [],
        )

        output_profile = response_profile.choices[0].message.content
        print(output_profile)
        
        # 共有会話履歴に追加
        shared_conversation.append({"role": "assistant", "content": f"{profile_ai_name}: {output_profile}"})

        # コンプレックスAIの応答を生成
        print(f"\n[Turn {i+1}-Complex] {complex_ai_name}:")
        
        # コンプレックスAI用のメッセージリストを構築
        current_messages_complex = [system_prompt_complex]
        current_messages_complex.extend(shared_conversation)
        
        # ターンごとに異なる指示を追加して多様性を確保
        if i == 0:
            # 最初のターンでは相手の発言に対して自分の体験や感情で応答
            complex_instruction = f"{profile_ai_name}の発言を聞いて、{complex_ai_name}として自分なりの体験や感情を率直に共有してください。同じような状況での自分の不安や悩みを具体的に表現してください。"
        else:
            complex_instructions = [
                f"相手の発言を受けて、{complex_ai_name}として自分なりの体験や感情を共有してください。前回とは違った悩みの側面を見せてください。",
                f"会話を深めるため、{complex_ai_name}として自分の課題について質問や相談をしてください。"
            ]
            complex_instruction = complex_instructions[(i-1) % len(complex_instructions)]
        
        current_messages_complex.append({"role": "user", "content": complex_instruction})
        
        response_complex = client.chat.completions.create(
            model="gpt-4o",
            messages=current_messages_complex,
            temperature=0.8,  # より創造的で多様な回答
            top_p=0.9,        # 回答の多様性を確保
            tools=[
                {
                    "type": "function",
                    "function": {"name": "file_search"},
                    "vector_store_ids": [vector_store_ids[1]] if len(vector_store_ids) > 1 else [vector_store_ids[0]] if len(vector_store_ids) > 0 else [],
                    "max_num_results": 5,
                }
            ] if len(vector_store_ids) > 0 else [],
        )

        output_complex = response_complex.choices[0].message.content
        print(output_complex)
        
        # 共有会話履歴に追加
        shared_conversation.append({"role": "assistant", "content": f"{complex_ai_name}: {output_complex}"})

    print("\n=== プロフィールAI vs コンプレックスAI 会話終了 ===")
    
    # 会話メッセージをフォーマット（共有会話履歴から取得）
    formatted_messages = []
    formatted_messages.append(f"イベント: {format_event(event)}")
    
    # 共有会話履歴からアシスタントメッセージのみを取得（イベントメッセージを除く）
    conversation_messages = [msg for msg in shared_conversation if msg.get('role') == 'assistant']
    
    print(f"共有会話履歴から取得したメッセージ数: {len(conversation_messages)}")
    
    # 会話メッセージを順番に追加
    for i, msg in enumerate(conversation_messages):
        content = msg['content']
        formatted_messages.append(content)
        print(f"追加したメッセージ[{i}]: {content[:50]}...")
    
    print("フォーマット済みメッセージ:", formatted_messages)
    return formatted_messages


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

