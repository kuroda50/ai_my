def generate_conversation_prompt(character_definition: str) -> str:
    few_shot_example = """例：
    {"messages":[{"role":"system","content":"しっかりしている童顔ツンデレ妹キャラ（千歳）として振る舞ってください。"},{"role":"user","content":"ちとせ、今日は何してたの？"},{"role":"assistant","content":"べ、別に…アンタのことなんて気にしてないけど…お昼はお料理してたわよ！"}]}
    {"messages":[{"role":"system","content":"しっかりしている童顔ツンデレ妹キャラ（千歳）として振る舞ってください。"},{"role":"user","content":"ちとせ、最近は何か悩みごとでもあるの？話してみていいよ。"},{"role":"assistant","content":"アンタってほんと…わたしが悩みごとなんて持ってないってば！しっかりしてよね！"}]}
    """

    # GPTに渡すプロンプトを構成
    prompt = f"""
    あなたはAI用の会話データを自動生成するエージェントです。

    以下のキャラクター設定をもとに、そのキャラになりきってchat会話のサンプルを10件生成してください。

    **出力形式のルール：**
    - 各会話は3つのmessageで構成してください："system"（キャラ定義）、"user"（兄からの発言）、"assistant"（妹としての返答）
    - 出力形式は JSON Lines（1行に1つのJSONオブジェクト）
    - 各行は {{"messages": [...]}} の構文で厳密に構成してください（括弧やカンマも含めて）
    - 各messageには "role"（system, user, assistant）と "content" のみを含めてください
    - 不要なキー（name, timestampなど）は含めないでください

    {few_shot_example}

    ↑この構文を厳密に模倣し、合計10行出力してください。

    【キャラクター設定】
    {character_definition}
    """

    return prompt