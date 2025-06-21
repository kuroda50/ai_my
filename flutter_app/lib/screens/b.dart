import 'package:flutter/material.dart';
import 'dart:math';
import 'drag_conversation_dialog.dart';
import '../models/person.dart';
import '../widgets/conversation_dialogs.dart';
import '../widgets/avatar_widget.dart';

class B extends StatefulWidget {
  final Person? newSelf;
  
  const B({super.key, this.newSelf});

  @override
  State<B> createState() => _BState();
}

class _BState extends State<B> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _zoomController;
  late Animation<double> _zoomAnimation;
  
  List<Person> people = [];
  Person? selectedPerson;
  Person? draggedPerson;
  bool isInConversation = false;
  List<Person> nearbyPeople = [];
  static const double proximityThreshold = 80.0;
  bool hasStartedApproaching = false;
  late AnimationController _approachController;
  Offset zoomCenter = Offset.zero;
  
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
        id: 0,
        name: 'あなた',
        color: Colors.orange,
        currentPosition: Offset(screenSize.width * 0.3, screenSize.height * 0.5),
        targetPosition: Offset(screenSize.width * 0.3, screenSize.height * 0.5),
        speed: 1.0,
        direction: _getRandomDirection(),
        lastDirectionChange: 0,
        messages: ['こんにちは', 'よろしくお願いします', '今日はいい天気ですね'],
        isUser: true,
      ),
    ];
    
    // 新しい自分が渡された場合は追加
    if (widget.newSelf != null) {
      people.add(widget.newSelf!);
    }
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
    // 他の人物がいないため、自動アプローチ機能は無効化
    return;
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
        title: const Text('自分との対話'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([_animationController, _zoomAnimation]),
        builder: (context, child) {
          _updatePeoplePositions();
          
          return Transform(
            alignment: selectedPerson != null 
                ? Alignment(
                    (zoomCenter.dx - screenSize.width / 2) / (screenSize.width / 2),
                    (zoomCenter.dy - screenSize.height / 2) / (screenSize.height / 2),
                  )
                : Alignment.center,
            transform: Matrix4.identity()..scale(selectedPerson != null ? _zoomAnimation.value : 1.0),
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
    return AvatarWidget(
      person: person,
      isSelected: selectedPerson?.id == person.id,
      isDragged: draggedPerson?.id == person.id,
      onTap: () => _onPersonTapped(person),
      onPanStart: person.isUser && person.id == 0 ? (details) {
        setState(() {
          draggedPerson = person;
        });
      } : null,
      onPanUpdate: person.isUser && person.id == 0 ? (details) {
        if (draggedPerson == person) {
          setState(() {
            person.currentPosition = Offset(
              (person.currentPosition.dx + details.delta.dx).clamp(0.0, screenSize.width - 50),
              (person.currentPosition.dy + details.delta.dy).clamp(0.0, screenSize.height - 100),
            );
          });
          _checkProximityForDrag(person);
        }
      } : null,
      onPanEnd: person.isUser && person.id == 0 ? (details) {
        setState(() {
          draggedPerson = null;
        });
      } : null,
    );
  }

  void _checkProximityForDrag(Person draggedUser) {
    for (final person in people) {
      if (person.id != draggedUser.id) {
        final distance = (draggedUser.currentPosition - person.currentPosition).distance;
        if (distance <= proximityThreshold && !isInConversation) {
          _startDragConversation(draggedUser, person);
          break;
        }
      }
    }
  }

  void _startDragConversation(Person user, Person otherPerson) {
    setState(() {
      selectedPerson = user;
      isInConversation = true;
      // 2つのアバターの中点をズームセンターに設定
      zoomCenter = Offset(
        (user.currentPosition.dx + otherPerson.currentPosition.dx) / 2,
        (user.currentPosition.dy + otherPerson.currentPosition.dy) / 2,
      );
    });
    
    _zoomController.forward().then((_) {
      _showDragConversationDialog(user, otherPerson);
    });
  }

  void _showDragConversationDialog(Person user, Person otherPerson) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DragConversationDialog(
        user: user,
        otherPerson: otherPerson,
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


