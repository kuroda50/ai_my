import json

def collect_input():
    # ここにユーザの入力を集める処理を実装
    # デモではすでにユーザが入力済みと想定

    json_open = open('test2/data/input/answers.json', 'r', encoding="utf-8")
    json_load = json.load(json_open)

    return json_load