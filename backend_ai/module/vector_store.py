from dotenv import load_dotenv
from openai import OpenAI

load_dotenv()
client = OpenAI()

def create_vector_store(store_name: str) -> dict:
    """Vector Store を作成
    Args:
        store_name (str): Vector store name
    Returns:
        dict: 作成したvector storeの情報
    """
    try:
        vector_store = client.vector_stores.create(name=store_name)
        details = {
            "id": vector_store.id,
            "name": vector_store.name,
            "created_at": vector_store.created_at,
            "file_count": vector_store.file_counts.completed
        }
        print("Vector storeを作成しました:", details)
        return details
    except Exception as e:
        print(f"vector storeを作成中にエラーが発生しました: {e}")
        return {}