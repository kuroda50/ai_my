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
    "character_index": 0,
    "q0_answer": "20歳、男、大学生",
    "q1_answer":
        "死にたいと思うことが多くて悩んでる。将来生きていける気がしない。働いて稼げる予感がしない。スマホやゲームで一時的な快楽を得ようと、ずっと続けてしまう。やらないといけないことがあるのに、やってない状態が続いて苦しくなる",
    "q2_answer": "やるべきことがやれない。休日を有効活用できない。休み方がわからない",
    "q3_answer": "あまりないかも。刹那的な快楽を得ようとずっとスマホやゲームをしているから、考える暇がない",
    "q4_answer": "やるやる言いながら何もやってない人",
    "q5_answer": "寮に入って、人と話す機会が多い状況になるとかかなあ？",
  };

  // APIのURL（ローカル環境でエミュレータを使う場合は要注意）
  final uri = Uri.parse("http://192.168.26.105:5000/generate_character");

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
