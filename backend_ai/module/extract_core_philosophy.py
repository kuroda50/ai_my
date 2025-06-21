from openai_client import client
import os

def extract_core_philosophy(answers: dict, character_index: str) -> str:
    prompt = (
        "以下はある人物のコンプレックスに関する回答です。\n"
        "この人物が何を恐れ、何を守ろうとしているかを推測し、"
        "その人物の根本的な行動哲学・思想を一文で要約してください。\n"
        "1. あなたが強く感じているコンプレックスは何ですか？ 具体的に書いてみましょう。"
        "* 例：人前で話すのが苦手、自分の容姿（顔、体型など）の一部、学歴、特定の能力が低いと感じる など"
        f"* 記入欄：{answers['q1_answer']}"

        "2. そのコンプレックスは、あなたの目にはどのように映っていますか？ （例：具体的な欠点、他人との比較点、理想とのギャップなど）2"
        f"* 記入欄：{answers['q2_answer']}"

        "3. いつ頃から、そのコンプレックスを感じ始めましたか？ きっかけとなる出来事があれば具体的に。"
        f"* 記入欄：{answers['q3_answer']}"
        
        "4. そのコンプレックスを感じる瞬間は、具体的にどのような状況ですか？ どのような場所で、誰といるとき、何をするときなど、詳しく描写してみましょう。"
        f"* 記入欄：{answers['q4_answer']}"

        "5. そのコンプレックスを感じたとき、あなたはどのような感情を抱きますか？ （例：恥ずかしい、情けない、悲しい、怒り、劣等感、不安など）"
        f"* 記入欄：{answers['q5_answer']}"

        "6. そのコンプレックスがあることで、あなたはどのような行動をとることが多いですか？ （例：特定の状況を避ける、自己主張をしない、完璧主義になる、無理をしてしまうなど）"
        f"* 記入欄：{answers['q6_answer']}"
        
        "7. そのコンプレックスは、他人との関係にどのような影響を与えていると感じますか？ （例：人との交流を避ける、本音を言えない、誤解されやすいなど）"
        f"* 記入欄：{answers['q7_answer']}"

        "8. もし仮に、そのコンプレックスがあなたに与えているポジティブな側面があるとしたら、何だと思いますか？ （例：努力する原動力になっている、謙虚になれる、他人の痛みに寄り添えるなど。難しくても考えてみてください。）"
        f"* 記入欄：{answers['q8_answer']}"

        "9. 今後、そのコンプレックスとどのように向き合っていきたいですか？ 具体的な目標や、試してみたいことがあれば記述してください。"
        f"* 記入欄：{answers['q9_answer']}"
        "\n【出力形式】\n- 思想: ～（30文字以内）\n- 補足: ～（簡単な解説）"
    )
    

    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.7
    )
        # 応答からテキスト取得
    output_text = response.choices[0].message.content
    
    # 保存
    output_dir = f"backend_ai/data/character/{character_index}"
    os.makedirs(output_dir, exist_ok=True)
    
    output_path = os.path.join(output_dir, "philosophy.txt")
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(output_text)
        
    print(f"✅ キャラシートを生成しました")
    return output_text