from flask import Flask, request, jsonify
from flask_cors import CORS
from module.generate_character_conversation  import generate_character_conversation
from module.generate_character_settings  import generate_character_settings
from module.vector_store  import create_vector_store
from module.upload_content  import upload_txt_file
from module.ai_chat  import ai_chat_between_characters
from module.get_next_character_index import get_next_character_index
from module.extract_core_philosophy import extract_core_philosophy

app = Flask(__name__)
CORS(app)

'''リクエストボディは以下のJSON形式
{
    "q1_answer": "aaa",
    "q2_answer": "bbb",
    "q3_answer": "ccc",
    "q4_answer": "ddd",
    "q5_answer": "eee",
    "q6_answer": "fff",
    "q7_answer": "fff",
    "q8_answer": "fff",
    "q9_answer": "fff",
}
'''
@app.route("/generate_character", methods=["POST"])
def generate_character():
    print("generate_characterが呼ばれたよ")
    user_input = request.get_json()
    character_index = get_next_character_index()
    
    # 思想抽出
    character_philosophy = extract_core_philosophy(user_input, character_index)
    print("キャラクターの思想:", character_philosophy)
    
    # キャラ生成
    character_settings =generate_character_settings(user_input, character_index, character_philosophy)
    print("キャラシート:", character_settings)
    
    # 会話例を生成すると、没個性になったので削除
    # 会話生成
    conversation_data = generate_character_conversation(character_settings, character_index, character_philosophy)
    print("会話データ:", conversation_data)
    
    # ベクトルストアを作成する
    vector_store_details = create_vector_store(f"character_${character_index}")
    vector_store_id = vector_store_details.get("id", "")
    # ベクトルストアにデータをアップロードする
    text_file_path = [f"backend_ai/data/character/{character_index}/settings.txt", 
                    f"backend_ai/data/character/{character_index}/conversation.txt",
                    f"backend_ai/data/character/{character_index}/philosophy.txt",]
    upload_txt_file(text_file_path, vector_store_id)
    
    response_data = {
        "character_settings": character_settings,
        "conversation_data": conversation_data,
        "vector_store_id": vector_store_id,
        "status": "success",
    }
    return jsonify(response_data), 200

'''リクエストボディは以下のJSON形式
{
    "vector_store_id: ["vs_A_id", "vs_B_id"]
}
'''
@app.route("/ai_chat", methods=["POST"])
def call_ai_chat():
    print("ai_chatが呼ばれたよ")
    data = request.get_json()
    vector_store_id = data.get("vector_store_id", [])
    ai_chat_between_characters(vector_store_id)
    
    response_data = {
        "status": "success",
        "message": "AI chat response generated successfully."
    }
    return jsonify(response_data), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001, debug=True)