import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/local_storage.dart';
import 'a.dart';
import 'complex_form.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  int _selectedTab = 0;
  List<Map<String, dynamic>> events = [];
  List<Map<String, dynamic>> characters = [];
  List<Map<String, dynamic>> conversationLogs = [];
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 画面に戻ってきた時だけデータを再読み込み
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      final loadedEvents = await LocalStorage.getEvents();
      final loadedCharacters = await LocalStorage.getCharacters();
      final loadedConversationLogs = await LocalStorage.getConversationLogs();
      
      setState(() {
        events = loadedEvents;
        characters = loadedCharacters;
        conversationLogs = loadedConversationLogs;
      });
    } catch (e) {
      print('データ読み込みエラー: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF7043), // オレンジ背景
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          child: Stack(
            children: [
              // 本の影
              Positioned(
                left: 8,
                top: 8,
                right: -8,
                bottom: -8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              
              // 本の外側（ベージュの表紙）
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFD4B08A), // ベージュ色
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFB8965F),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    // メインのページ部分（左側70%）
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 20, 100, 20), // 右側に本の厚み分のスペース
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8F8), // 白いページ
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: _selectedTab == 0 
                            ? _buildEventCards() 
                            : _selectedTab == 1
                                ? _buildCharacterCards()
                                : _buildConversationCards(),
                      ),
                    ),
                    
                    // 本の右側の厚み部分
                    Positioned(
                      right: 20,
                      top: 20,
                      bottom: 20,
                      width: 80,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              const Color(0xFFE5C8A8),
                              const Color(0xFFD4B08A),
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 4,
                              offset: const Offset(-2, 0),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // ページの縞模様（本の厚み感）
                            ...List.generate(5, (index) {
                              return Positioned(
                                left: index * 12.0 + 10,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  width: 1,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    
                    // 栞（タブ）- ページと本の厚みの間から出ている
                    Positioned(
                      right: 0,
                      top: 60,
                      child: Column(
                        children: [
                          _buildBookmark(
                            text: 'イベント',
                            isSelected: _selectedTab == 0,
                            onTap: () => _selectTab(0),
                            color: const Color(0xFF8BC34A),
                          ),
                          const SizedBox(height: 8),
                          _buildBookmark(
                            text: 'キャラ',
                            isSelected: _selectedTab == 1,
                            onTap: () => _selectTab(1),
                            color: const Color(0xFF4CAF50),
                          ),
                          const SizedBox(height: 8),
                          _buildBookmark(
                            text: '会話ログ',
                            isSelected: _selectedTab == 2,
                            onTap: () => _selectTab(2),
                            color: const Color(0xFF26A69A),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectTab(int index) {
    setState(() {
      _selectedTab = index;
    });
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  Widget _buildBookmark({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          // タブの本体
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isSelected ? 100 : 90,
            height: 45,
            margin: EdgeInsets.only(
              right: isSelected ? 0 : 10, // 非選択時は本の中に少し隠れる
            ),
            decoration: BoxDecoration(
              color: isSelected ? color : color.withOpacity(0.8),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(-3, 2),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: const Offset(-1, 1),
                      ),
                    ],
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // グラデーション
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        color.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                ),
                // テキスト
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: isSelected ? 13 : 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 非選択時の奥行き感（タブが本の中に入っている感じ）
          if (!isSelected)
            Positioned(
              left: 0,
              child: Container(
                width: 20,
                height: 45,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEventCards() {
    return ListView.builder(
      itemCount: events.length + 1,
      itemBuilder: (context, index) {
        if (index == events.length) {
          return _buildNewEventCard();
        } else {
          final event = events[index];
          final basicData = event['basicData'] as Map<String, dynamic>? ?? {};
          final eventTitle = basicData['what'] ?? '';
          final eventDate = event['timestamp'] != null
              ? DateTime.parse(event['timestamp']).toString().substring(0, 16)
              : '';
          
          return _buildEventCard(
            title: eventTitle.isNotEmpty ? eventTitle : 'イベント ${index + 1}',
            date: eventDate,
            onTap: () {
              // イベント詳細表示
            },
          );
        }
      },
    );
  }

  Widget _buildCharacterCards() {
    return ListView.builder(
      itemCount: characters.length + 1,
      itemBuilder: (context, index) {
        if (index == characters.length) {
          return _buildNewCharacterCard();
        } else {
          final character = characters[index];
          final characterName = character['name'] ?? 'キャラクター ${index + 1}';
          final characterDate = character['timestamp'] != null
              ? DateTime.parse(character['timestamp']).toString().substring(0, 16)
              : '';
          
          return _buildCharacterCard(
            name: characterName,
            date: characterDate,
            onTap: () {
              // キャラクター詳細表示
            },
          );
        }
      },
    );
  }

  Widget _buildConversationCards() {
    if (conversationLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '会話ログ',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'まだ会話ログがありません\nキャラクター同士を近づけて会話を始めましょう',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: conversationLogs.length,
      itemBuilder: (context, index) {
        final log = conversationLogs[index];
        final participants = List<String>.from(log['participants'] ?? []);
        final timestamp = log['timestamp'] != null
            ? DateTime.parse(log['timestamp']).toString().substring(0, 16)
            : '';
        final eventTrigger = log['event_trigger'] as Map<String, dynamic>? ?? {};
        final eventDescription = eventTrigger['what'] ?? 'イベント';
        
        return _buildConversationCard(
          participants: participants,
          timestamp: timestamp,
          eventDescription: eventDescription,
          onTap: () => _showConversationDetail(log),
        );
      },
    );
  }

  Widget _buildEventCard({
    required String title,
    required String date,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _selectedTab == 0 ? _scaleAnimation.value : 1.0,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFFBDBDBD),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // カードの内容
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'イベント',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const Text(
                            'カード',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          if (title != 'イベント カード') ...[
                            const SizedBox(height: 8),
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (date.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              date,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ],
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

  Widget _buildCharacterCard({
    required String name,
    required String date,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _selectedTab == 1 ? _scaleAnimation.value : 1.0,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFFBDBDBD),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'キャラクター',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Text(
                        'カード',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (name != 'キャラクター カード') ...[
                        const SizedBox(height: 8),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (date.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNewEventCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () async {
          await context.push('/journal');
          // 画面から戻ってきた時にデータを再読み込み
          await _loadData();
        },
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF9E9E9E),
              style: BorderStyle.solid,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                color: Colors.grey[600],
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                '新しいイベント',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewCharacterCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () async {
          await context.push('/comp');
          // 画面から戻ってきた時にデータを再読み込み
          await _loadData();
        },
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF9E9E9E),
              style: BorderStyle.solid,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                color: Colors.grey[600],
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                '新しいキャラクター',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConversationCard({
    required List<String> participants,
    required String timestamp,
    required String eventDescription,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _selectedTab == 2 ? _scaleAnimation.value : 1.0,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFFBDBDBD),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.chat_bubble,
                        size: 32,
                        color: Colors.teal,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        participants.join(' × '),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        eventDescription,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      if (timestamp.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          timestamp,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showConversationDetail(Map<String, dynamic> log) {
    final participants = List<String>.from(log['participants'] ?? []);
    final messages = List<dynamic>.from(log['messages'] ?? []);
    final eventTrigger = log['event_trigger'] as Map<String, dynamic>? ?? {};
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${participants.join(' × ')} の会話'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (eventTrigger.isNotEmpty) ...[
                Text(
                  'きっかけ: ${eventTrigger['what'] ?? ''}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              ...messages.map((message) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  message.toString(),
                  style: const TextStyle(fontSize: 14),
                ),
              )).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}