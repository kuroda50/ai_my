import os

def get_next_character_index(base_path="backend_ai/data/character"):
    os.makedirs(base_path, exist_ok=True)
    existing_indices = [
        int(name) for name in os.listdir(base_path)
        if os.path.isdir(os.path.join(base_path, name)) and name.isdigit()
    ]
    return max(existing_indices, default=-1) + 1  # 初回は0から開始
