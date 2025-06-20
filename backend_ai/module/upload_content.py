from dotenv import load_dotenv
from openai import OpenAI
import os

load_dotenv()
client = OpenAI()

def upload_txt_file(filepaths: list, vector_store_id: str):
    """
    複数のローカルテキストファイルをベクトルストアにアップロードする関数
    Args:
        filepaths (list): アップロード対象のファイルパスのリスト
        vector_store_id (str): 対象ベクトルストアID
    Returns:
        list: 各ファイルのアップロード結果
    """
    results = []

    for path in filepaths:
        filename = os.path.basename(path)

        try:
            with open(path, "rb") as f:
                file = client.files.create(
                    file=(filename, f),
                    purpose="assistants"
                )

            metadata = {
                "filename": filename,
                "path": path
            }

            client.vector_stores.files.create(
                vector_store_id=vector_store_id,
                file_id=file.id,
                attributes=metadata
            )

            print(f"✅ Uploaded: {filename}")
            results.append({"file": filename, "status": "success"})

        except Exception as e:
            print(f"❌ Error with {filename}: {str(e)}")
            results.append({"file": filename, "status": "failed", "error": str(e)})

    return results

