from flask import Flask, request, jsonify
from flask_cors import CORS
from module.generate_character_conversation  import generate_character_conversation
from module.generate_character_settings  import generate_character_settings
from module.vector_store  import create_vector_store
from module.upload_content  import upload_txt_file
from module.ai_chat  import ai_chat

app = Flask(__name__)
CORS(app)

'''リクエストボディは以下のJSON形式
{
    "character_index": 0,
    "q0_answer": "aaa",
    "q1_answer": "bbb",
    "q2_answer": "ccc",
    "q3_answer": "ddd",
    "q4_answer": "eee",
    "q5_answer": "fff"
}
'''
@app.route("/generate_character", methods=["POST"])
def generate_character():
    print("generate_characterが呼ばれたよ")
    user_input = request.get_json()
    character_index = user_input.get("character_index", 0)
    character_settings =generate_character_settings(user_input, character_index)
    print("キャラシート:", character_settings)
    conversation_data = generate_character_conversation(character_settings, character_index)
    print("会話データ:", conversation_data)
    # ベクトルストアを作成する
    vector_store_details = create_vector_store("character_${character_index}")
    vector_store_id = vector_store_details.get("id", "")
    # ベクトルストアにデータをアップロードする
    if(character_index == 0):
        text_file_path = ["backend_ai/data/character/A/settings.txt", 
                          "backend_ai/data/character/A/conversation.txt"]
    elif(character_index == 1):
        text_file_path = ["backend_ai/data/character/B/settings.txt", 
                          "backend_ai/data/character/B/conversation.txt"]
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
    "character_id: ["character1", "character2"]
}
'''
@app.route("/ai_chat", methods=["POST"])
def call_ai_chat():
    print("ai_chatが呼ばれたよ")
    data = request.get_json()
    ai_chat(data)
    
    response_data = {
        "status": "success",
        "message": "AI chat response generated successfully."
    }
    return jsonify(response_data), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)