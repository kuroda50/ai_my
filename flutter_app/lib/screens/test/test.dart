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
        "event": {
        "when": "今日の朝",
        "where": "大学の教室",
        "who": "僕",
        "what": "教授に怒られた",
        "why": "授業中にYoutubeを見ていたから",
        "how": "みんなの前で軽く注意された",
    },
    "vector_store_id": ["vs_685658ee59e48191aba78339dfbbfe14", "vs_68564c49c6a4819190414d44ddaedeea"]
  };
  // APIのURL（ローカル環境でエミュレータを使う場合は要注意）

  // final uri = Uri.parse("http://192.168.26.105:5001/generate_character");
  final uri = Uri.parse("http://192.168.0.248:5001/ai_chat");


  // final Map<String, dynamic> requestData = {
  //   "q1_answer": "社会に適合できない。",
  //   "q2_answer": "人にすごく迷惑をかけてしまう",
  //   "q3_answer": "うーん。高校生くらいかなあ。授業中にずっと座って拘束されるのが苦手。静かに目立たないようにするのが苦手",
  //   "q4_answer": "最近は感じてない。自由な環境だからかなり楽になったと思う。ただ追いつめられると、かなりきつい。授業などで座ることを強要されたり、静かに当たり障りのないことをしないといけな状況は苦手",
  //   "q5_answer": "恐怖。今すぐ苦痛から解放されたい、と強く感じる",
  //   "q6_answer": "天邪鬼。やってもやらなくてもいいという状況が一番好き。追い詰められたら逃げる。バイトをバックレたりする",
  //   "q7_answer": "ちょっと変な人だと思われてるとは思う。今の環境はすごく楽なので、特に問題ないが、無難な相槌を打つのが苦手",
  //   "q8_answer": "自分にとても正直だから、すぐ行動できる。やりたいと思ったらとことんやれる  ",
  //   "q9_answer": "治せるなら治したいな。でも、できるだけ快適な環境に居続けて、自分の好きなことをしていたい。",
  // };
  // final uri = Uri.parse("http://localhost:5000/generate_character");


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
