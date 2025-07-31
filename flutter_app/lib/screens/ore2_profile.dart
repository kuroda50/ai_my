import 'package:flutter/material.dart';
import 'complex_form.dart';
import '../widgets/question_field.dart';
import '../widgets/simple_select_field.dart';
import '../widgets/age_slider_field.dart';
import '../services/local_storage.dart';
import '../services/ai_service.dart';
import '../models/person.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _appearanceController = TextEditingController();
  final _personalityController = TextEditingController();
  final _backgroundController = TextEditingController();
  final _goalController = TextEditingController();
  final _idealImageController = TextEditingController();

  // 簡単入力用の状態変数
  String? _selectedGender;
  int _selectedAge = 25;
  String? _selectedFirstPerson;
  String? _selectedConversationStyle;

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _flipController.dispose();
    _nameController.dispose();
    _appearanceController.dispose();
    _personalityController.dispose();
    _backgroundController.dispose();
    _goalController.dispose();
    _idealImageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('自分のプロフィール-profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // カードコンテナ
              Expanded(
                child: AnimatedBuilder(
                  animation: _flipAnimation,
                  builder: (context, child) {
                    return _buildFrontCard();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrontCard() {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '自分のプロフィールを記入して下さい',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    QuestionField(
                      label: '名前(your name)',
                      controller: _nameController,
                      hint: '例:発掘  太郎',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 16),
                    SimpleSelectField(
                      label: '性別',
                      icon: Icons.wc,
                      options: const ['男性', '女性', 'その他'],
                      selectedValue: _selectedGender,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    AgeSliderField(
                      label: '年齢',
                      icon: Icons.cake,
                      initialAge: _selectedAge,
                      onChanged: (int age) {
                        setState(() {
                          _selectedAge = age;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    QuestionField(
                      label: '外見・服装',
                      controller: _appearanceController,
                      hint: '例:背が高い・黒いTシャツとジーンズ',
                      icon: Icons.face,
                    ),
                    const SizedBox(height: 16),
                    SimpleSelectField(
                      label: '一人称',
                      icon: Icons.record_voice_over,
                      options: const ['俺', '私', '僕', '自分', 'わたし', 'ワイ'],
                      selectedValue: _selectedFirstPerson,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedFirstPerson = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    QuestionField(
                      label: '性格・価値観',
                      controller: _personalityController,
                      hint: '例:負けず嫌い/優しい・挑戦/貢献',
                      icon: Icons.psychology,
                    ),
                    const SizedBox(height: 16),
                    QuestionField(
                      label: '背景・現在の状況',
                      controller: _backgroundController,
                      hint: '例:大学生・就職活動中',
                      icon: Icons.history_edu,
                    ),
                    const SizedBox(height: 16),
                    QuestionField(
                      label: '目標・モチベーション',
                      controller: _goalController,
                      hint: '例:起業/世界一周旅行・金銭的報酬や地位報酬(外発的モチベーション)/趣味に没頭や人の役に立つ(内発的モチベーション)',
                      icon: Icons.flag,
                    ),
                    const SizedBox(height: 16),
                    SimpleSelectField(
                      label: '話し方・会話スタイル',
                      icon: Icons.forum,
                      options: const ['フランク', '丁寧', '論理的', 'ユーモラス', '落ち着いている', '熱血'],
                      selectedValue: _selectedConversationStyle,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedConversationStyle = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    QuestionField(
                      label: '他者との関係性(理想像)',
                      controller: _idealImageController,
                      hint: '例:友好的/協力的・信頼関係を築く/競争心を持つ',
                      icon: Icons.star,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            // ボタンをカード内に移動
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveRecord,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'プロフィールを保存',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveRecord() async {
    // プロフィールデータを収集
    final basicData = {
      'name': _nameController.text,
      'gender': _selectedGender ?? '',
      'age': '${_selectedAge}歳',
      'appearance': _appearanceController.text,
      'firstPerson': _selectedFirstPerson ?? '',
      'personality': _personalityController.text,
      'background': _backgroundController.text,
      'goal': _goalController.text,
      'conversationStyle': _selectedConversationStyle ?? '',
      'idealImage': _idealImageController.text,
    };

    // プロフィール情報をローカルストレージに保存
    await _saveEventToLocal(basicData);

    // プロフィール情報からAIキャラクターを生成
    await _generateProfileAI(basicData);

    // ホーム画面に戻る
    Navigator.of(context).pop();
  }

  Future<void> _saveEventToLocal(Map<String, String> basicData) async {
    try {
      // プロフィール情報として保存（イベントではなく）
      await LocalStorage.saveProfile(basicData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('プロフィールが保存されました'),
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

  Future<void> _generateProfileAI(Map<String, String> basicData) async {
    try {
      // バックエンドの状態をチェック
      final backendAvailable = await AIService.checkBackendStatus();
      if (!backendAvailable) {
        _showErrorDialog('バックエンドサーバーに接続できません。\nhttp://localhost:5000 でbackend_aiが起動していることを確認してください。');
        return;
      }

      // プロフィール情報から専用のAIキャラクターを生成
      final aiResponse = await AIService.generateProfileCharacter(basicData);

      if (aiResponse != null && aiResponse['status'] == 'success') {
        // AI生成されたキャラクターデータを抽出
        final characterSettings = aiResponse['character_settings'] as String;
        final conversationData = aiResponse['conversation_data'] as String;
        final vectorStoreId = aiResponse['vector_store_id'] as String;

        // キャラクター名を設定から抽出
        final nameMatch = RegExp(r'名前.*?：\s*(.+?)(?:\n|$)', multiLine: true).firstMatch(characterSettings);
        final characterName = nameMatch?.group(1)?.trim() ?? basicData['name'] ?? 'プロフィールAI';

        // 会話データからメッセージを解析
        final messages = _parseConversationMessages(conversationData);

        // プロフィール由来のAIキャラクターを作成
        final profileAI = Person(
          id: 1000, // プロフィールAI用の固定ID
          name: characterName,
          color: Colors.blue,
          currentPosition: const Offset(150, 300),
          targetPosition: const Offset(150, 300),
          speed: 1.0,
          direction: const Offset(1, 0),
          lastDirectionChange: 0,
          messages: messages,
          isUser: true,
          complexData: null, // プロフィールAIにはコンプレックスデータなし
          aiCharacterSettings: characterSettings,
          aiConversationData: conversationData,
          vectorStoreId: vectorStoreId,
        );

        // プロフィールAIをローカルストレージに保存
        await LocalStorage.saveCharacter(profileAI);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('プロフィールAIが生成されました'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showErrorDialog('プロフィールAIの生成に失敗しました。');
      }
    } catch (e) {
      _showErrorDialog('プロフィールAI生成エラー: $e');
    }
  }

  List<String> _parseConversationMessages(String conversationData) {
    final messages = <String>[];
    
    // 会話例からメッセージを抽出
    final regex = RegExp(r'キャラ名?[：:]\s*(.+?)(?=\n|ユーザー|$)', multiLine: true);
    final matches = regex.allMatches(conversationData);
    
    for (final match in matches) {
      final message = match.group(1)?.trim();
      if (message != null && message.isNotEmpty) {
        messages.add(message);
      }
    }
    
    if (messages.isEmpty) {
      // パース失敗時のフォールバックメッセージ
      messages.addAll([
        'こんにちは、私はあなたのプロフィールから生まれたAIです。',
        'あなたの価値観や目標を共有しています。',
        '一緒に成長していきましょう。',
      ]);
    }
    
    return messages;
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
}