import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Test extends StatelessWidget {
  const Test({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('テスト画面')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('テスト画面です'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                sendCharacterRequest();
              },
              child: Text("ボタン"),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> sendCharacterRequest() async {
  // 送信するデータ
  final Map<String, dynamic> requestData = {
    "vector_store_id": ["vs_6854d5b3c3588191baf34659567e1953", "vs_685561c83bcc81918ad73a93950cb461"]
  };

  // APIのURL（ローカル環境でエミュレータを使う場合は要注意）
  final uri = Uri.parse("http://localhost:5000/ai_chat");

  try {
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      print("✅ 成功: ${response.body}");
    } else {
      print("❌ エラー: ${response.statusCode}, ${response.body}");
    }
  } catch (e) {
    print("❌ 通信エラー: $e");
  }
}
