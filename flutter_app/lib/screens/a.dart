import 'package:flutter/material.dart';

class A extends StatefulWidget {
  const A({super.key});

  @override
  State<A> createState() => _AState();
}

class _AState extends State<A> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _whoController = TextEditingController();
  final _whatController = TextEditingController();
  final _whenController = TextEditingController();
  final _whereController = TextEditingController();
  final _whyController = TextEditingController();
  final _howController = TextEditingController();
  
  String _selectedEmotion = '';
  bool _showEmotionParameters = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  
  // 感情パラメーター
  double _joyLevel = 50.0;     // 喜
  double _angerLevel = 50.0;   // 怒
  double _sadnessLevel = 50.0; // 哀
  double _pleasureLevel = 50.0; // 楽
  
  final List<Map<String, dynamic>> _emotions = [
    {'name': '喜', 'color': Colors.yellow, 'icon': Icons.sentiment_very_satisfied},
    {'name': '怒', 'color': Colors.red, 'icon': Icons.sentiment_very_dissatisfied},
    {'name': '哀', 'color': Colors.blue, 'icon': Icons.sentiment_dissatisfied},
    {'name': '楽', 'color': Colors.green, 'icon': Icons.sentiment_satisfied},
  ];

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
    _whoController.dispose();
    _whatController.dispose();
    _whenController.dispose();
    _whereController.dispose();
    _whyController.dispose();
    _howController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('感情記録 - 5W1H'),
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
                    final isShowingFront = _flipAnimation.value < 0.5;
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(_flipAnimation.value * 3.14159),
                      child: isShowingFront ? _buildFrontCard() : _buildBackCard(),
                    );
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
              '出来事を整理してください',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuestionField(
                      label: 'Who (誰が)',
                      controller: _whoController,
                      hint: '関わった人物を記入してください',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 16),
                    _buildQuestionField(
                      label: 'What (何を)',
                      controller: _whatController,
                      hint: '何が起こったかを記入してください',
                      icon: Icons.event,
                    ),
                    const SizedBox(height: 16),
                    _buildQuestionField(
                      label: 'When (いつ)',
                      controller: _whenController,
                      hint: 'いつ起こったかを記入してください',
                      icon: Icons.access_time,
                    ),
                    const SizedBox(height: 16),
                    _buildQuestionField(
                      label: 'Where (どこで)',
                      controller: _whereController,
                      hint: 'どこで起こったかを記入してください',
                      icon: Icons.location_on,
                    ),
                    const SizedBox(height: 16),
                    _buildQuestionField(
                      label: 'Why (なぜ)',
                      controller: _whyController,
                      hint: 'なぜ起こったかを記入してください',
                      icon: Icons.help_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildQuestionField(
                      label: 'How (どのように)',
                      controller: _howController,
                      hint: 'どのように起こったかを記入してください',
                      icon: Icons.settings,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // ボタンをカード内に移動
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _checkAndFlipCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '感情パラメーター設定へ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackCard() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(3.14159),
      child: Card(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '感情パラメーターを調整してください',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildEmotionSlider(
                        label: '喜 (Joy)',
                        value: _joyLevel,
                        color: Colors.orange,
                        icon: Icons.sentiment_very_satisfied,
                        onChanged: (value) => setState(() => _joyLevel = value),
                      ),
                      const SizedBox(height: 24),
                      _buildEmotionSlider(
                        label: '怒 (Anger)',
                        value: _angerLevel,
                        color: Colors.red,
                        icon: Icons.sentiment_very_dissatisfied,
                        onChanged: (value) => setState(() => _angerLevel = value),
                      ),
                      const SizedBox(height: 24),
                      _buildEmotionSlider(
                        label: '哀 (Sadness)',
                        value: _sadnessLevel,
                        color: Colors.blue,
                        icon: Icons.sentiment_dissatisfied,
                        onChanged: (value) => setState(() => _sadnessLevel = value),
                      ),
                      const SizedBox(height: 24),
                      _buildEmotionSlider(
                        label: '楽 (Pleasure)',
                        value: _pleasureLevel,
                        color: Colors.green,
                        icon: Icons.sentiment_satisfied,
                        onChanged: (value) => setState(() => _pleasureLevel = value),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              // 保存ボタンをカード内に移動
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveRecord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '記録を保存',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmotionSlider({
    required String label,
    required double value,
    required Color color,
    required IconData icon,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${value.round()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              thumbColor: color,
              overlayColor: color.withOpacity(0.2),
              trackHeight: 6,
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  void _checkAndFlipCard() {
    if (_formKey.currentState!.validate() && _isAllFieldsFilled()) {
      setState(() {
        _showEmotionParameters = true;
      });
      _flipController.forward();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('すべての項目を入力してください'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  bool _isAllFieldsFilled() {
    return _whoController.text.isNotEmpty &&
           _whatController.text.isNotEmpty &&
           _whenController.text.isNotEmpty &&
           _whereController.text.isNotEmpty &&
           _whyController.text.isNotEmpty &&
           _howController.text.isNotEmpty;
  }

  Widget _buildQuestionField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  void _saveRecord() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('記録完了'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('感情記録を保存しました:'),
            const SizedBox(height: 8),
            Text('喜: ${_joyLevel.round()}'),
            Text('怒: ${_angerLevel.round()}'),
            Text('哀: ${_sadnessLevel.round()}'),
            Text('楽: ${_pleasureLevel.round()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetForm();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _selectedEmotion = '';
      _showEmotionParameters = false;
      _joyLevel = 50.0;
      _angerLevel = 50.0;
      _sadnessLevel = 50.0;
      _pleasureLevel = 50.0;
    });
    _flipController.reset();
    _whoController.clear();
    _whatController.clear();
    _whenController.clear();
    _whereController.clear();
    _whyController.clear();
    _howController.clear();
  }
}