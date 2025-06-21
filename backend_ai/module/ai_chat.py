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

    # 初期イベント文をセット
    # message = (
    #     "ある日、シェアオフィスに新しく入ってきた同僚が、私と同じように『社会の枠に合わない』と感じている人だったんだ。"
    #     "その人の自由で飾らない姿や、ちょっとした気配りで周囲と調和しようとする感じに、なんかすごく影響受けた。"
    #     "あと、この前参加した『みんな違っていい』っていうテーマのワークショップでも、自分の特性を恥じるより大事にしていいんだって思えるようになって。"
    #     "……君は、こういうのどう思う？"
    # )
    message = "ごはん美味しかった。あ、財布忘れちゃった。どうしよ"
    previous_response_id = None

    # キャラの交互ターン（0→A, 1→B）
    for i in range(4):
        print(f"\n[Turn {i+1}-A] キャラA:")
        response_a = client.responses.create(
            model="gpt-4o-mini",
            input="""あなたはキャラクターAです。
                    以下の「思想」に基づいて、キャラクターAとして自然に話してください。
                    キャラになりきって、友達に話しかけるように砕けた口調で、自然に答えてください。
                    - 思想: 学歴に囚われず自分の価値を見出す
                    - 補足: 学歴の劣等感から他者を避けがちだが、学歴以外の部分で努力し、自分自身の価値を高めようとしている。
                    相手のセリフ: """ + message,
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

        print(f"\n[Turn {i+1}-B] キャラB:")
        response_b = client.responses.create(
            model="gpt-4o-mini",
            input="""あなたはキャラクターBです。
                    以下の「思想」に基づいて、キャラクターBとして自然に話してください。
                    キャラになりきって、友達に話しかけるように砕けた口調で、自然に答えてください。
                    - 思想: 自由を追求し、自己に正直に生きる
                    - 補足: 彼/彼女は社会の期待に縛られることを恐れ、自分の自然な感情や欲望に忠実であることを重視しています。そのため、自分に合った環境を求め、強制される状況からは逃げる傾向があります。
                    出力単語数は80～120語程度にしてください。
                    相手のセリフ: """ + message,
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