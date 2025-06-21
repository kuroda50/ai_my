import 'package:flutter/material.dart';
import 'complex_form.dart';
import '../widgets/question_field.dart';
import '../services/local_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _genderController = TextEditingController();
  final _ageController = TextEditingController();
  final _appearanceController = TextEditingController();
  final _firstPersonController = TextEditingController();
  final _personalityController = TextEditingController();
  final _backgroundController = TextEditingController();
  final _goalController = TextEditingController();
  final _conversationStyleController = TextEditingController();
  final _idealImageController = TextEditingController();

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
    _genderController.dispose();
    _ageController.dispose();
    _appearanceController.dispose();
    _firstPersonController.dispose();
    _personalityController.dispose();
    _backgroundController.dispose();
    _goalController.dispose();
    _conversationStyleController.dispose();
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
                    QuestionField(
                      label: '性別',
                      controller: _genderController,
                      hint: '男性/女性/その他',
                      icon: Icons.wc,
                    ),
                    const SizedBox(height: 16),
                    QuestionField(
                      label: '年齢',
                      controller: _ageController,
                      hint: '例:25歳',
                      icon: Icons.cake,
                    ),
                    const SizedBox(height: 16),
                    QuestionField(
                      label: '外見・服装',
                      controller: _appearanceController,
                      hint: '例:背が高い・黒いTシャツとジーンズ',
                      icon: Icons.face,
                    ),
                    const SizedBox(height: 16),
                    QuestionField(
                      label: '一人称・口癖',
                      controller: _firstPersonController,
                      hint: '例:朕/俺/私・別に/一応/でも',
                      icon: Icons.record_voice_over,
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
                    QuestionField(
                      label: '話し方・会話スタイル',
                      controller: _conversationStyleController,
                      hint: '例:フランク/丁寧/論理的・相手に合わせる/自分のペースで話す',
                      icon: Icons.forum,
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

  void _saveRecord() {
    // 5W1Hのデータを収集
    final basicData = {
      'name': _nameController.text,
      'gender': _genderController.text,
      'age': _ageController.text,
      'appearance': _appearanceController.text,
      'firstPerson': _firstPersonController.text,
      'personality': _personalityController.text,
      'background': _backgroundController.text,
      'goal': _goalController.text,
      'conversationStyle': _conversationStyleController.text,
      'idealImage': _idealImageController.text,
    };

    // イベントデータをローカルストレージに保存
    _saveEventToLocal(basicData);

    // ホーム画面に戻る
    Navigator.of(context).pop();
  }

  void _saveEventToLocal(Map<String, String> basicData) async {
    try {
      await LocalStorage.saveEvent({
        'basicData': basicData,
      });

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
}