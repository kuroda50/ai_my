import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'b.dart';
import '../models/person.dart';
import '../services/ai_service.dart';
import '../services/local_storage.dart';

class ComplexForm extends StatefulWidget {
  final Map<String, String> basicData;
  final Map<String, double> emotionData;

  const ComplexForm({
    super.key,
    required this.basicData,
    required this.emotionData,
  });

  @override
  State<ComplexForm> createState() => _ComplexFormState();
}

class _ComplexFormState extends State<ComplexForm> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  final List<TextEditingController> _controllers = List.generate(9, (index) => TextEditingController());
  
  bool _isGeneratingCharacter = false;

  final List<Map<String, String>> _questions = [
    {
      'title': 'あなたが強く感じているコンプレックスは何ですか？',
      'subtitle': '具体的に書いてみましょう。',
      'example': '例：人前で話すのが苦手、自分の容姿（顔、体型など）の一部、学歴、特定の能力が低いと感じる など',
      'icon': 'Icons.psychology',
    },
    {
      'title': 'そのコンプレックスは、あなたの目にはどのように映っていますか？',
      'subtitle': '',
      'example': '例：具体的な欠点、他人との比較点、理想とのギャップなど',
      'icon': 'Icons.visibility',
    },
    {
      'title': 'いつ頃から、そのコンプレックスを感じ始めましたか？',
      'subtitle': 'きっかけとなる出来事があれば具体的に。',
      'example': '',
      'icon': 'Icons.schedule',
    },
    {
      'title': 'そのコンプレックスを感じる瞬間は、具体的にどのような状況ですか？',
      'subtitle': 'どのような場所で、誰といるとき、何をするときなど、詳しく描写してみましょう。',
      'example': '',
      'icon': 'Icons.place',
    },
    {
      'title': 'そのコンプレックスを感じたとき、あなたはどのような感情を抱きますか？',
      'subtitle': '',
      'example': '例：恥ずかしい、情けない、悲しい、怒り、劣等感、不安など',
      'icon': 'Icons.sentiment_dissatisfied',
    },
    {
      'title': 'そのコンプレックスがあることで、あなたはどのような行動をとることが多いですか？',
      'subtitle': '',
      'example': '例：特定の状況を避ける、自己主張をしない、完璧主義になる、無理をしてしまうなど',
      'icon': 'Icons.directions_walk',
    },
    {
      'title': 'そのコンプレックスは、他人との関係にどのような影響を与えていると感じますか？',
      'subtitle': '',
      'example': '例：人との交流を避ける、本音を言えない、誤解されやすいなど',
      'icon': 'Icons.people',
    },
    {
      'title': 'もし仮に、そのコンプレックスがあなたに与えているポジティブな側面があるとしたら、何だと思いますか？',
      'subtitle': '難しくても考えてみてください。',
      'example': '例：努力する原動力になっている、謙虚になれる、他人の痛みに寄り添えるなど',
      'icon': 'Icons.lightbulb',
    },
    {
      'title': '今後、そのコンプレックスとどのように向き合っていきたいですか？',
      'subtitle': '具体的な目標や、試してみたいことがあれば記述してください。',
      'example': '',
      'icon': 'Icons.flag',
    },
  ];

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'Icons.psychology':
        return Icons.psychology;
      case 'Icons.visibility':
        return Icons.visibility;
      case 'Icons.schedule':
        return Icons.schedule;
      case 'Icons.place':
        return Icons.place;
      case 'Icons.sentiment_dissatisfied':
        return Icons.sentiment_dissatisfied;
      case 'Icons.directions_walk':
        return Icons.directions_walk;
      case 'Icons.people':
        return Icons.people;
      case 'Icons.lightbulb':
        return Icons.lightbulb;
      case 'Icons.flag':
        return Icons.flag;
      default:
        return Icons.help_outline;
    }
  }

  bool _isAllFieldsFilled() {
    return _controllers.every((controller) => controller.text.isNotEmpty);
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _isAllFieldsFilled()) {
      setState(() {
        _isGeneratingCharacter = true;
      });

      // コンプレックスデータを収集
      final complexData = <String, String>{};
      for (int i = 0; i < _questions.length; i++) {
        complexData['question_${i + 1}'] = _controllers[i].text;
      }

      try {
        // Check backend status first
        final backendAvailable = await AIService.checkBackendStatus();
        if (!backendAvailable) {
          _showErrorDialog('バックエンドサーバーに接続できません。\nhttp://localhost:5000 でbackend_aiが起動していることを確認してください。');
          return;
        }

        // Generate AI character using backend_ai
        final aiResponse = await AIService.generateCharacter(
          widget.basicData,
          widget.emotionData,
          complexData,
        );

        if (aiResponse != null && aiResponse['status'] == 'success') {
          // Extract AI-generated character data
          final characterSettings = aiResponse['character_settings'] as String;
          final conversationData = aiResponse['conversation_data'] as String;
          final vectorStoreId = aiResponse['vector_store_id'] as String;

          // Parse character name from settings (simple extraction)
          final nameMatch = RegExp(r'名前.*?：\s*(.+?)(?:\n|$)', multiLine: true).firstMatch(characterSettings);
          final characterName = nameMatch?.group(1)?.trim() ?? 'AIキャラクター';

          // Create messages from conversation data
          final messages = _parseConversationMessages(conversationData);

          // Create new AI-generated character
          final newSelf = Person(
            id: 999,
            name: characterName,
            color: Colors.teal,
            currentPosition: const Offset(250, 300),
            targetPosition: const Offset(250, 300),
            speed: 1.0,
            direction: const Offset(1, 0),
            lastDirectionChange: 0,
            messages: messages,
            isUser: true,
            complexData: complexData,
            aiCharacterSettings: characterSettings,
            aiConversationData: conversationData,
            vectorStoreId: vectorStoreId,
          );

          // Save character to local storage
          _saveCharacterToLocal(newSelf);

          // Navigate back to home page
          if (context.mounted) {
            context.go('/home');
          }
        } else {
          if (context.mounted) {
            _showErrorDialog('AIキャラクターの生成に失敗しました。もう一度お試しください。');
          }
        }
      } catch (e) {
        if (context.mounted) {
          _showErrorDialog('エラーが発生しました: $e');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isGeneratingCharacter = false;
          });
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('すべての項目を入力してください'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  List<String> _parseConversationMessages(String conversationData) {
    final messages = <String>[];
    
    // Extract messages from conversation examples
    final regex = RegExp(r'キャラ名?[：:]\s*(.+?)(?=\n|ユーザー|$)', multiLine: true);
    final matches = regex.allMatches(conversationData);
    
    for (final match in matches) {
      final message = match.group(1)?.trim();
      if (message != null && message.isNotEmpty) {
        messages.add(message);
      }
    }
    
    if (messages.isEmpty) {
      // Fallback messages if parsing fails
      messages.addAll([
        'こんにちは、私はあなたの新しい一面です。',
        'コンプレックスと向き合うことで成長できました。',
        '一緒に未来に向かって歩んでいきましょう。',
      ]);
    }
    
    return messages;
  }

  void _saveCharacterToLocal(Person character) async {
    try {
      await LocalStorage.saveCharacter(character);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('キャラクターが保存されました'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('保存に失敗しました: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('エラー'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('コンプレックス分析フォーム'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // プログレスインジケーター
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'コンプレックスについて深く考えてみましょう',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 0.0, // 後で進捗に応じて更新可能
                    backgroundColor: Colors.grey.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            // 質問リスト
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    final question = _questions[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 質問番号とアイコン
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    _getIcon(question['icon']!),
                                    color: Theme.of(context).primaryColor,
                                    size: 28,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // 質問タイトル
                              Text(
                                question['title']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (question['subtitle']!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  question['subtitle']!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                              if (question['example']!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.blue.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    question['example']!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              // 入力フィールド
                              TextFormField(
                                controller: _controllers[index],
                                decoration: InputDecoration(
                                  hintText: '記入欄：',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.all(16),
                                  filled: true,
                                  fillColor: Colors.grey.withOpacity(0.05),
                                ),
                                maxLines: 4,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'この項目は必須です';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // 送信ボタン
            Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isGeneratingCharacter ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: _isGeneratingCharacter
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'AIキャラクターを生成中...',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      : const Text(
                          'AIキャラクターを生成',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}