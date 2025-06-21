import 'package:flutter/material.dart';
import 'dart:math';

class B extends StatefulWidget {
  const B({super.key});

  @override
  State<B> createState() => _BState();
}

class _BState extends State<B> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _zoomController;
  late Animation<double> _zoomAnimation;
  
  List<Person> people = [];
  Person? selectedPerson;
  bool isInConversation = false;
  List<Person> nearbyPeople = [];
  static const double proximityThreshold = 80.0;
  bool hasStartedApproaching = false;
  late AnimationController _approachController;
  
  final Random random = Random();
  Size screenSize = const Size(400, 800);

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _zoomController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _approachController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _zoomAnimation = Tween<double>(
      begin: 1.0,
      end: 3.0,
    ).animate(CurvedAnimation(
      parent: _zoomController,
      curve: Curves.easeInOut,
    ));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        screenSize = MediaQuery.of(context).size;
        _initializePeople();
      });
    });
  }

  void _initializePeople() {
    people = [
      Person(
        id: 1,
        name: '田中さん',
        color: Colors.blue,
        currentPosition: Offset(100, 200),
        targetPosition: Offset(100, 200),
        speed: 0.8 + random.nextDouble() * 0.4,
        direction: _getRandomDirection(),
        lastDirectionChange: 0,
        messages: ['こんにちは！佐藤さん', '今日はいい天気ですね', '新しいプロジェクトの件、どう思いますか？'],
      ),
      Person(
        id: 2,
        name: '佐藤さん',
        color: Colors.red,
        currentPosition: Offset(300, 400),
        targetPosition: Offset(300, 400),
        speed: 0.8 + random.nextDouble() * 0.4,
        direction: _getRandomDirection(),
        lastDirectionChange: 0,
        messages: ['田中さん、お疲れ様です', 'そうですね、とてもいい天気です', 'とても興味深いアイデアだと思います'],
      ),
      Person(
        id: 3,
        name: '山田さん',
        color: Colors.green,
        currentPosition: Offset(200, 300),
        targetPosition: Offset(200, 300),
        speed: 0.8 + random.nextDouble() * 0.4,
        direction: _getRandomDirection(),
        lastDirectionChange: 0,
        messages: ['元気ですか？', '週末の予定はありますか？', '新しいレストランを発見しました'],
      ),
      Person(
        id: 4,
        name: '鈴木さん',
        color: Colors.purple,
        currentPosition: Offset(250, 500),
        targetPosition: Offset(250, 500),
        speed: 0.8 + random.nextDouble() * 0.4,
        direction: _getRandomDirection(),
        lastDirectionChange: 0,
        messages: ['いいアイデアがあります', '一緒に頑張りましょう', 'ランチはもう食べましたか？'],
      ),
    ];
    
    // 3秒後に田中さんが佐藤さんに近づくアニメーションを開始
    Future.delayed(Duration(seconds: 2), () {
      if (!hasStartedApproaching && mounted) {
        _startApproaching();
      }
    });
  }

  Offset _getRandomPosition() {
    return Offset(
      50 + random.nextDouble() * (screenSize.width - 100),
      150 + random.nextDouble() * (screenSize.height - 300),
    );
  }

  Offset _getRandomDirection() {
    final angle = random.nextDouble() * 2 * pi;
    return Offset(cos(angle), sin(angle));
  }

  void _startApproaching() {
    if (hasStartedApproaching || isInConversation) return;
    
    hasStartedApproaching = true;
    final person1 = people.firstWhere((p) => p.id == 1); // 田中さん
    final person2 = people.firstWhere((p) => p.id == 2); // 佐藤さん
    
    final startPos = person1.currentPosition;
    final endPos = Offset(
      person2.currentPosition.dx - 70,
      person2.currentPosition.dy,
    );
    
    _approachController.addListener(() {
      if (mounted && !isInConversation) {
        setState(() {
          person1.currentPosition = Offset.lerp(startPos, endPos, _approachController.value)!;
        });
        
        // 近接検知
        final distance = (person1.currentPosition - person2.currentPosition).distance;
        if (distance <= proximityThreshold && !isInConversation) {
          _startNearbyConversation(person1, person2);
        }
      }
    });
    
    _approachController.forward();
  }

  void _updatePeoplePositions() {
    // 静的な位置を保持するため、アニメーション処理は削除
    return;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _zoomController.dispose();
    _approachController.dispose();
    super.dispose();
  }

  void _checkProximity() {
    // 近接検知ロジックは_startApproachingメソッド内で処理
    return;
  }

  void _startNearbyConversation(Person person1, Person person2) {
    setState(() {
      selectedPerson = person1;
      isInConversation = true;
    });
    
    _zoomController.forward().then((_) {
      _showNearbyConversationDialog(person1, person2);
    });
  }

  void _onPersonTapped(Person person) {
    if (isInConversation) return;
    
    setState(() {
      selectedPerson = person;
      isInConversation = true;
    });
    
    _zoomController.forward().then((_) {
      _showConversationDialog(person);
    });
  }

  void _showNearbyConversationDialog(Person person1, Person person2) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => NearbyConversationDialog(
        person1: person1,
        person2: person2,
        onClose: () {
          _zoomController.reverse().then((_) {
            setState(() {
              selectedPerson = null;
              isInConversation = false;
              nearbyPeople.clear();
            });
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showConversationDialog(Person person) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConversationDialog(
        person: person,
        onClose: () {
          _zoomController.reverse().then((_) {
            setState(() {
              selectedPerson = null;
              isInConversation = false;
            });
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('街の人々'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([_animationController, _zoomAnimation]),
        builder: (context, child) {
          _updatePeoplePositions();
          
          return Transform.scale(
            scale: selectedPerson != null ? _zoomAnimation.value : 1.0,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFD2B48C), // カフェ風の茶色
                    Color(0xFFF5DEB3), // 暖かいベージュ
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // カフェの背景装飾
                  _buildCafeBackground(),
                  // 歩いている人々
                  ...people.map((person) => _buildWalkingPerson(person)).toList(),
                  // 近接している人をハイライト
                  ...nearbyPeople.map((person) => _buildNearbyHighlight(person)).toList(),
                  // ズーム中の人をハイライト
                  if (selectedPerson != null)
                    _buildHighlightedPerson(selectedPerson!),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCafeBackground() {
    return Stack(
      children: [
        // テーブル
        Positioned(
          top: 200,
          left: 50,
          child: _buildTable(),
        ),
        Positioned(
          top: 300,
          right: 80,
          child: _buildTable(),
        ),
        Positioned(
          bottom: 200,
          left: 150,
          child: _buildTable(),
        ),
        // 植物
        Positioned(
          top: 100,
          right: 50,
          child: _buildPlant(),
        ),
        Positioned(
          bottom: 150,
          right: 50,
          child: _buildPlant(),
        ),
      ],
    );
  }

  Widget _buildTable() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Color(0xFF8B4513),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
    );
  }

  Widget _buildPlant() {
    return Container(
      width: 40,
      height: 60,
      decoration: BoxDecoration(
        color: Color(0xFF228B22),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Icon(
          Icons.local_florist,
          color: Colors.green[800],
          size: 24,
        ),
      ),
    );
  }

  Widget _buildWalkingPerson(Person person) {
    return Positioned(
      left: person.currentPosition.dx,
      top: person.currentPosition.dy,
      child: GestureDetector(
        onTap: () => _onPersonTapped(person),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..scale(selectedPerson?.id == person.id ? 1.2 : 1.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 人のアイコン
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: person.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 5),
              // 名前
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: person.color.withOpacity(0.5)),
                ),
                child: Text(
                  person.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: person.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNearbyHighlight(Person person) {
    return Positioned(
      left: person.currentPosition.dx - 5,
      top: person.currentPosition.dy - 5,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.orange.withOpacity(0.7),
            width: 3,
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedPerson(Person person) {
    return Positioned(
      left: person.currentPosition.dx - 10,
      top: person.currentPosition.dy - 10,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.yellow,
            width: 4,
          ),
        ),
      ),
    );
  }
}

class Person {
  final int id;
  final String name;
  final Color color;
  Offset currentPosition;
  Offset targetPosition;
  double speed;
  Offset direction;
  double lastDirectionChange;
  final List<String> messages;

  Person({
    required this.id,
    required this.name,
    required this.color,
    required this.currentPosition,
    required this.targetPosition,
    required this.speed,
    required this.direction,
    required this.lastDirectionChange,
    required this.messages,
  });
}

class NearbyConversationDialog extends StatefulWidget {
  final Person person1;
  final Person person2;
  final VoidCallback onClose;

  const NearbyConversationDialog({
    super.key,
    required this.person1,
    required this.person2,
    required this.onClose,
  });

  @override
  State<NearbyConversationDialog> createState() => _NearbyConversationDialogState();
}

class _NearbyConversationDialogState extends State<NearbyConversationDialog>
    with TickerProviderStateMixin {
  late AnimationController _dialogController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  
  List<String> conversation = [];
  int currentMessageIndex = 0;

  @override
  void initState() {
    super.initState();
    
    _dialogController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _dialogController,
      curve: Curves.elasticOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _dialogController,
      curve: Curves.easeOut,
    ));
    
    _dialogController.forward();
    _startNearbyConversation();
  }

  void _startNearbyConversation() {
    conversation.add('${widget.person1.name}と${widget.person2.name}が近づいて会話を始めました...');
    setState(() {});
    
    _showConversationSequence();
  }
  
  void _showConversationSequence() {
    final allMessages = <String>[];
    
    // 会話のシーケンスを作成
    for (int i = 0; i < widget.person1.messages.length && i < widget.person2.messages.length; i++) {
      allMessages.add('${widget.person1.name}: ${widget.person1.messages[i]}');
      allMessages.add('${widget.person2.name}: ${widget.person2.messages[i]}');
    }
    
    // メッセージを順番に表示
    for (int i = 0; i < allMessages.length; i++) {
      Future.delayed(Duration(milliseconds: 1500 * (i + 1)), () {
        if (mounted) {
          setState(() {
            conversation.add(allMessages[i]);
          });
        }
      });
    }
  }

  // ユーザー入力機能を削除

  @override
  void dispose() {
    _dialogController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dialogController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [widget.person1.color, widget.person2.color],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.people,
                              color: widget.person1.color,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${widget.person1.name} & ${widget.person2.name}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: widget.onClose,
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: conversation.length,
                                itemBuilder: (context, index) {
                                  final message = conversation[index];
                                  final isPerson1 = message.startsWith(widget.person1.name);
                                  final isPerson2 = message.startsWith(widget.person2.name);
                                  
                                  Color messageColor = Colors.grey;
                                  if (isPerson1) messageColor = widget.person1.color;
                                  if (isPerson2) messageColor = widget.person2.color;
                                  
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      mainAxisAlignment: isPerson2
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: messageColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: messageColor.withOpacity(0.3),
                                              ),
                                            ),
                                            child: Text(
                                              message,
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ConversationDialog extends StatefulWidget {
  final Person person;
  final VoidCallback onClose;

  const ConversationDialog({
    super.key,
    required this.person,
    required this.onClose,
  });

  @override
  State<ConversationDialog> createState() => _ConversationDialogState();
}

class _ConversationDialogState extends State<ConversationDialog>
    with TickerProviderStateMixin {
  late AnimationController _dialogController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  
  int currentMessageIndex = 0;
  List<String> conversation = [];
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    
    _dialogController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _dialogController,
      curve: Curves.elasticOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _dialogController,
      curve: Curves.easeOut,
    ));
    
    _dialogController.forward();
    _startConversation();
    
    // フォーカスを入力フィールドに設定
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  void _startConversation() {
    conversation.add('${widget.person.name}: ${widget.person.messages[0]}');
    setState(() {});
  }

  void _addResponse(String response) {
    if (response.trim().isEmpty) return;
    
    setState(() {
      conversation.add('あなた: $response');
      currentMessageIndex++;
      
      if (currentMessageIndex < widget.person.messages.length) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              conversation.add('${widget.person.name}: ${widget.person.messages[currentMessageIndex]}');
            });
          }
        });
      }
    });
    
    _textController.clear();
  }

  void _sendMessage() {
    final message = _textController.text.trim();
    if (message.isNotEmpty) {
      _addResponse(message);
    }
  }

  @override
  void dispose() {
    _dialogController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dialogController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ヘッダー
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: widget.person.color,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              color: widget.person.color,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            widget.person.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: widget.onClose,
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    // 会話エリア
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: conversation.length,
                                itemBuilder: (context, index) {
                                  final message = conversation[index];
                                  final isUser = message.startsWith('あなた:');
                                  
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      mainAxisAlignment: isUser
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: isUser
                                                  ? Colors.blue.withOpacity(0.1)
                                                  : Colors.grey.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isUser
                                                    ? Colors.blue.withOpacity(0.3)
                                                    : widget.person.color.withOpacity(0.3),
                                              ),
                                            ),
                                            child: Text(
                                              message,
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            // メッセージ入力エリア
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _textController,
                                      focusNode: _focusNode,
                                      decoration: InputDecoration(
                                        hintText: 'メッセージを入力してください...',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(24),
                                          borderSide: BorderSide(
                                            color: widget.person.color.withOpacity(0.3),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(24),
                                          borderSide: BorderSide(
                                            color: widget.person.color,
                                            width: 2,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey.withOpacity(0.1),
                                      ),
                                      maxLines: null,
                                      textInputAction: TextInputAction.send,
                                      onSubmitted: (_) => _sendMessage(),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: widget.person.color,
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      onPressed: _sendMessage,
                                      icon: const Icon(
                                        Icons.send,
                                        color: Colors.white,
                                      ),
                                      iconSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}