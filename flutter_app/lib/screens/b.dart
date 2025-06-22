import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:flame/game.dart' as flame;
import 'drag_conversation_dialog.dart';
import '../models/person.dart';
import '../widgets/conversation_dialogs.dart';
import '../widgets/avatar_widget.dart';
import '../services/local_storage.dart';
import '../services/ai_service.dart';
import '../components/cafe_game.dart';

class B extends StatefulWidget {
  final Person? newSelf;
  
  const B({super.key, this.newSelf});

  @override
  State<B> createState() => _BState();
}

// パスを描画するカスタムペインター
class PathPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Color color;
  
  PathPainter({required this.start, required this.end, required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    
    final path = Path();
    path.moveTo(start.dx + 25, start.dy + 25); // キャラクターの中心から
    
    // 直線ではなく、少し湾曲したパスを描く
    final controlPoint = Offset(
      (start.dx + end.dx) / 2 + (Random().nextDouble() - 0.5) * 50,
      (start.dy + end.dy) / 2 + (Random().nextDouble() - 0.5) * 50,
    );
    
    path.quadraticBezierTo(
      controlPoint.dx,
      controlPoint.dy,
      end.dx + 25,
      end.dy + 25,
    );
    
    // 点線のパスを描画
    final dashPath = Path();
    final dashPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    double distance = 0;
    const dashWidth = 5;
    const dashSpace = 5;
    
    for (final metric in path.computeMetrics()) {
      while (distance < metric.length) {
        final extractPath = metric.extractPath(distance, distance + dashWidth);
        dashPath.addPath(extractPath, Offset.zero);
        distance += dashWidth + dashSpace;
      }
    }
    
    canvas.drawPath(dashPath, dashPaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _BState extends State<B> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _zoomController;
  late Animation<double> _zoomAnimation;
  late CafeGame _cafeGame;
  
  List<Person> people = [];
  Person? selectedPerson;
  Person? draggedPerson;
  bool isInConversation = false;
  List<Person> nearbyPeople = [];
  static const double proximityThreshold = 80.0;
  bool hasStartedApproaching = false;
  late AnimationController _approachController;
  Offset zoomCenter = Offset.zero;
  Timer? _conversationTimer;
  List<String> _currentConversation = [];
  bool _isAIConversationActive = false;
  Timer? _approachTimer;
  bool _isAutoApproaching = false;
  Person? _targetPerson;
  Person? _movingPerson;
  List<Person> _stoppedCharacters = [];
  
  final Random random = Random();
  Size screenSize = const Size(400, 800);

  // 最近接ペアのアプローチ状態をチェックするタイマー
  Timer? _closestPairCheckTimer;
  
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
    
    // CafeGameを初期化
    _cafeGame = CafeGame();
    _cafeGame.onCharactersNearby = (person1, person2) {
      if (!isInConversation && !hasStartedApproaching && !_isAIConversationActive) {
        hasStartedApproaching = true;
        _stopCharacters(person1, person2);
        _startAutoConversation(person1, person2);
      }
    };
    _cafeGame.onPersonTap = (person) => _onPersonTapped(person);
    _cafeGame.onDragStart = (person) {
      setState(() {
        draggedPerson = person;
      });
    };
    _cafeGame.onDragEnd = (person) {
      setState(() {
        draggedPerson = null;
        // ドラッグ終了時にtargetPositionを現在位置に更新
        person.targetPosition = person.currentPosition;
      });
    };
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        screenSize = MediaQuery.of(context).size;
        _cafeGame.setGameSize(screenSize);
        _initializePeople();
        _startAutoApproach();
        
        // 最近接ペアのアプローチ状態をチェックするタイマーを開始
        _startClosestPairCheckTimer();
      });
    });
  }
  
  // 最近接ペアのアプローチ状態を定期的にチェック
  void _startClosestPairCheckTimer() {
    _closestPairCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      // 会話中やアプローチ中でない場合、新たな最近接ペアを探す
      if (!isInConversation && !_isAIConversationActive && !_isAutoApproaching) {
        print('定期チェック: 新たな最近接ペアを探します');
        _startClosestPairApproach();
      } else {
        print('定期チェック: 既に会話中またはアプローチ中です');
      }
    });
  }

  void _initializePeople() async {
    people = [];
    
    // 新しい自分が渡された場合は追加
    if (widget.newSelf != null) {
      final newSelfPosition = _getRandomPosition();
      widget.newSelf!.currentPosition = newSelfPosition;
      widget.newSelf!.targetPosition = newSelfPosition;
      people.add(widget.newSelf!);
    } else {
      // ローカルストレージから保存されたキャラクターを読み込み
      await _loadSavedCharacters();
    }
  }

  Future<void> _loadSavedCharacters() async {
    try {
      final savedCharacters = await LocalStorage.getCharacters();
      
      for (int i = 0; i < savedCharacters.length; i++) {
        final characterData = savedCharacters[i];
        final randomPosition = _getRandomPosition();
        final character = Person(
          id: int.parse(characterData['id']),
          name: characterData['name'],
          color: Color(characterData['color'] ?? Colors.teal.value),
          currentPosition: randomPosition,
          targetPosition: randomPosition,
          speed: 1.0,
          direction: _getRandomDirection(),
          lastDirectionChange: 0,
          messages: List<String>.from(characterData['messages'] ?? []),
          isUser: true,
          complexData: Map<String, String>.from(characterData['complexData'] ?? {}),
          aiCharacterSettings: characterData['aiCharacterSettings'],
          aiConversationData: characterData['aiConversationData'],
          vectorStoreId: characterData['vectorStoreId'],
        );
        people.add(character);
      }
      
      setState(() {});
      
      // CafeGameにキャラクターを更新
      _cafeGame.updatePeople(people);
      
      // キャラクターが2人以上いる場合、一番近いペアを自動で近づかせる
      if (people.length >= 2) {
        // 少し遅延させてから最近接ペアのアプローチを開始
        // これにより、キャラクターの初期位置が正しく設定された後に処理が実行される
        Future.delayed(const Duration(milliseconds: 500), () {
          _startClosestPairApproach();
        });
      }
    } catch (e) {
      print('Error loading saved characters: $e');
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
    if (!mounted) return;
    
    // 近接検知のために人の位置を更新
    for (final person in people) {
      
      // 停止中のキャラクターは動かない
      if (_stoppedCharacters.contains(person)) {
        continue;
      }
      
      // ドラッグ中のキャラクターは自動移動しない
      if (draggedPerson != null && draggedPerson!.id == person.id) {
        continue;
      }
      
      if (_isAutoApproaching && _targetPerson != null && _movingPerson?.id == person.id) {
        // 自動アプローチ中の場合、ターゲットに向かって移動
        _moveTowardsTarget(person);
      } else {
        // 通常のランダム移動
        if (_animationController.value * 1000 % 2000 > person.lastDirectionChange + 500) {
          person.direction = _getRandomDirection();
          person.lastDirectionChange = (_animationController.value * 1000).toInt().toDouble();
        }
        
        // 位置を更新
        person.currentPosition = Offset(
          (person.currentPosition.dx + person.direction.dx * person.speed)
              .clamp(25.0, screenSize.width - 75.0),
          (person.currentPosition.dy + person.direction.dy * person.speed)
              .clamp(100.0, screenSize.height - 150.0),
        );
      }
    }
    
    // CafeGameにキャラクターの位置更新を通知
    _cafeGame.updatePeople(people);
    
    // 近接検知（setStateを呼ぶ可能性がある処理を分離）
    _scheduleProximityCheck();
  }

  void _scheduleProximityCheck() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkProximity();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _zoomController.dispose();
    _approachController.dispose();
    _conversationTimer?.cancel();
    _approachTimer?.cancel();
    _closestPairCheckTimer?.cancel();
    super.dispose();
  }

  void _checkProximity() {
    if (isInConversation) return;
    
    nearbyPeople.clear();
    
    // 全てのキャラクター同士の距離をチェック
    for (int i = 0; i < people.length; i++) {
      for (int j = i + 1; j < people.length; j++) {
        final person1 = people[i];
        final person2 = people[j];
        
        final distance = (person1.currentPosition - person2.currentPosition).distance;
        
        if (distance <= proximityThreshold) {
          print('距離チェック: ${person1.name} と ${person2.name} の距離: ${distance.toStringAsFixed(1)} <= ${proximityThreshold}');
          nearbyPeople.add(person1);
          nearbyPeople.add(person2);
          
          print('近接検知！${person1.name} と ${person2.name} が近づきました');
          
          // キャラクターを停止
          _stopCharacters(person1, person2);
          
          // 初回の近接時に会話を開始
          if (!hasStartedApproaching && !_isAIConversationActive) {
            hasStartedApproaching = true;
            print('会話を開始します: ${person1.name} と ${person2.name}');
            _startAutoConversation(person1, person2);
            break;
          }
        }
      }
    }
    
    // 近くに誰もいない場合はフラグをリセット
    if (nearbyPeople.isEmpty) {
      hasStartedApproaching = false;
      if (_isAIConversationActive) {
        _stopAutoConversation();
      }
      // 停止していたキャラクターを再開
      _resumeAllCharacters();
    }
  }

  void _startAutoApproach() {
    if (people.length < 2) return;
    
    _approachTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (isInConversation || _isAIConversationActive) return;
      
      // ランダムに2人のキャラクターを選択
      final availablePeople = people;
      if (availablePeople.length >= 2) {
        final person1 = availablePeople[random.nextInt(availablePeople.length)];
        Person? person2;
        do {
          person2 = availablePeople[random.nextInt(availablePeople.length)];
        } while (person2.id == person1.id);
        
        // person1をperson2に向かって移動させる
        _initiateApproach(person1, person2);
      }
    });
  }
  
  // 一番近い2人のキャラクターを見つけて自動的に近づかせる
  void _startClosestPairApproach() {
    if (people.length < 2) return;
    print('一番近いキャラクターペアを探しています...');
    
    // 既に会話中または自動アプローチ中の場合は何もしない
    if (isInConversation || _isAIConversationActive || _isAutoApproaching) {
      print('既に会話中または自動アプローチ中のため、最近接ペアアプローチをスキップします');
      return;
    }
    
    // 全てのキャラクターペアの距離を計算
    double minDistance = double.infinity;
    Person? closestPerson1;
    Person? closestPerson2;
    
    for (int i = 0; i < people.length; i++) {
      for (int j = i + 1; j < people.length; j++) {
        final person1 = people[i];
        final person2 = people[j];
        
        // 同じキャラクターは除外
        if (person1.id == person2.id) continue;
        
        final distance = (person1.currentPosition - person2.currentPosition).distance;
        
        // 既に十分近い場合は会話を開始
        if (distance <= proximityThreshold * 1.5) {
          print('既に十分近いキャラクターペアを発見: ${person1.name} と ${person2.name}, 距離: $distance');
          _stopCharacters(person1, person2);
          _startAutoConversation(person1, person2);
          return;
        }
        
        // より近いペアを見つけた場合は更新
        if (distance < minDistance) {
          minDistance = distance;
          closestPerson1 = person1;
          closestPerson2 = person2;
        }
      }
    }
    
    // 最も近いペアが見つかった場合、アプローチを開始
    if (closestPerson1 != null && closestPerson2 != null) {
      print('最も近いキャラクターペア: ${closestPerson1.name} と ${closestPerson2.name}, 距離: $minDistance');
      
      // どちらのキャラクターを動かすかランダムに決定
      final shouldMoveFirst = random.nextBool();
      final movingPerson = shouldMoveFirst ? closestPerson1 : closestPerson2;
      final targetPerson = shouldMoveFirst ? closestPerson2 : closestPerson1;
      
      // アプローチを開始
      _initiateApproach(movingPerson, targetPerson);
      
      // アプローチ開始を通知
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${movingPerson.name}が${targetPerson.name}に近づいています...'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _initiateApproach(Person movingPerson, Person targetPerson) {
    if (_isAutoApproaching) return;
    
    setState(() {
      _isAutoApproaching = true;
      _targetPerson = targetPerson;
      _movingPerson = movingPerson;
    });
    
    print('${movingPerson.name} が ${targetPerson.name} に近づいています...');
  }

  void _moveTowardsTarget(Person movingPerson) {
    if (_targetPerson == null) return;
    
    final target = _targetPerson!.currentPosition;
    final current = movingPerson.currentPosition;
    final distance = (target - current).distance;
    
    if (distance <= proximityThreshold) {
      // 目標に到着したので、自動アプローチを停止
      print('${movingPerson.name} が ${_targetPerson!.name} に到着しました');
      
      // 両方のキャラクターを停止
      _stopCharacters(movingPerson, _targetPerson!);
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isAutoApproaching = false;
            _targetPerson = null;
            _movingPerson = null;
          });
        }
      });
      return;
    }
    
    // 基本的なターゲットに向かう方向ベクトルを計算
    Offset direction = Offset(
      (target.dx - current.dx) / distance,
      (target.dy - current.dy) / distance,
    );
    
    // 他のキャラクターとの衝突回避
    direction = _avoidCollisions(movingPerson, direction);
    
    // カフェの装飾物（テーブル、植物）との衝突回避
    direction = _avoidObstacles(current, direction);
    
    // 移動速度を少し上げる
    final moveSpeed = movingPerson.speed * 1.5;
    
    // 新しい位置を計算
    final newPosition = Offset(
      (current.dx + direction.dx * moveSpeed)
          .clamp(25.0, screenSize.width - 75.0),
      (current.dy + direction.dy * moveSpeed)
          .clamp(100.0, screenSize.height - 150.0),
    );
    
    movingPerson.currentPosition = newPosition;
  }

  Offset _avoidCollisions(Person movingPerson, Offset originalDirection) {
    Offset avoidanceDirection = Offset.zero;
    const avoidanceRadius = 60.0;
    
    for (final otherPerson in people) {
      if (otherPerson.id == movingPerson.id) continue;
      
      final otherPosition = otherPerson.currentPosition;
      final currentPosition = movingPerson.currentPosition;
      final distance = (otherPosition - currentPosition).distance;
      
      if (distance < avoidanceRadius && distance > 0) {
        // 他のキャラクターから離れる方向を計算
        final avoidDirection = Offset(
          (currentPosition.dx - otherPosition.dx) / distance,
          (currentPosition.dy - otherPosition.dy) / distance,
        );
        
        // 距離に応じて回避力を調整
        final avoidanceForce = (avoidanceRadius - distance) / avoidanceRadius;
        avoidanceDirection = Offset(
          avoidanceDirection.dx + avoidDirection.dx * avoidanceForce,
          avoidanceDirection.dy + avoidDirection.dy * avoidanceForce,
        );
      }
    }
    
    // 元の方向と回避方向を合成
    final combinedDirection = Offset(
      originalDirection.dx + avoidanceDirection.dx * 0.5,
      originalDirection.dy + avoidanceDirection.dy * 0.5,
    );
    
    // 正規化
    final length = combinedDirection.distance;
    if (length > 0) {
      return Offset(
        combinedDirection.dx / length,
        combinedDirection.dy / length,
      );
    }
    
    return originalDirection;
  }

  Offset _avoidObstacles(Offset currentPosition, Offset originalDirection) {
    // カフェの装飾物の位置（_buildCafeBackgroundと同じ位置）
    final obstacles = [
      Offset(80, 230),   // テーブル1
      Offset(screenSize.width - 110, 330), // テーブル2
      Offset(180, screenSize.height - 170), // テーブル3
      Offset(screenSize.width - 70, 130),   // 植物1
      Offset(screenSize.width - 70, screenSize.height - 120), // 植物2
    ];
    
    Offset avoidanceDirection = Offset.zero;
    const avoidanceRadius = 70.0;
    
    for (final obstacle in obstacles) {
      final distance = (obstacle - currentPosition).distance;
      
      if (distance < avoidanceRadius && distance > 0) {
        // 障害物から離れる方向を計算
        final avoidDirection = Offset(
          (currentPosition.dx - obstacle.dx) / distance,
          (currentPosition.dy - obstacle.dy) / distance,
        );
        
        // 距離に応じて回避力を調整
        final avoidanceForce = (avoidanceRadius - distance) / avoidanceRadius;
        avoidanceDirection = Offset(
          avoidanceDirection.dx + avoidDirection.dx * avoidanceForce,
          avoidanceDirection.dy + avoidDirection.dy * avoidanceForce,
        );
      }
    }
    
    // 元の方向と回避方向を合成
    final combinedDirection = Offset(
      originalDirection.dx + avoidanceDirection.dx * 0.3,
      originalDirection.dy + avoidanceDirection.dy * 0.3,
    );
    
    // 正規化
    final length = combinedDirection.distance;
    if (length > 0) {
      return Offset(
        combinedDirection.dx / length,
        combinedDirection.dy / length,
      );
    }
    
    return originalDirection;
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
        actions: [
          IconButton(
            onPressed: _testConversation,
            icon: const Icon(Icons.chat),
            tooltip: 'テスト会話',
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([_animationController, _zoomAnimation]),
        builder: (context, child) {
          // ビルド後に位置更新を実行
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updatePeoplePositions();
          });
          
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
                  // Flameベースのカフェ背景とキャラクター
                  flame.GameWidget<CafeGame>.controlled(gameFactory: () => _cafeGame),
                  // 近接している人をハイライト
                  ...nearbyPeople.map((person) => _buildNearbyHighlight(person)).toList(),
                  // ズーム中の人をハイライト
                  if (selectedPerson != null)
                    _buildHighlightedPerson(selectedPerson!),
                  // AI会話表示
                  if (_isAIConversationActive)
                    _buildConversationOverlay(),
                  // 自動アプローチ中の矢印表示
                  if (_isAutoApproaching && _movingPerson != null && _targetPerson != null)
                    _buildApproachArrow(),
                  // 停止中のキャラクター表示
                  ..._stoppedCharacters.map((person) => _buildStoppedIndicator(person)).toList(),
                  
                  // 会話準備中のキャラクター表示
                  ..._conversationReadyCharacters.map((person) => _buildConversationReadyIndicator(person)).toList(),
                ],
              ),
            ),
          );
        },
      ),
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

  Future<void> _startAutoConversation(Person person1, Person person2) async {
    if (_isAIConversationActive) return;
    
    print('=== AI会話開始処理 ===');
    print('キャラクター1: ${person1.name}, vectorStoreId: ${person1.vectorStoreId}');
    print('キャラクター2: ${person2.name}, vectorStoreId: ${person2.vectorStoreId}');
    
    setState(() {
      _isAIConversationActive = true;
      _currentConversation.clear();
      _currentEvent = null; // 初期化
    });

    // 会話開始の表示
    print('二人のキャラクターが出会いました: ${person1.name} と ${person2.name}');
    
    // キャラクターを識別
    Person? profileAI; // プロフィールAI（ID: 1000番台）
    Person? complexAI; // コンプレックスAI（ID: 2000番台）
    
    // 各キャラクターを識別
    for (final person in [person1, person2]) {
      if (1000 <= person.id && person.id < 2000) {
        profileAI = person;
      } else if (2000 <= person.id && person.id < 3000) {
        complexAI = person;
      }
    }
    
    // 会話パターンを決定
    if (profileAI != null && complexAI != null) {
      // プロフィールAIとコンプレックスAIの会話
      print('プロフィールAI vs コンプレックスAI 会話開始: ${profileAI.name} vs ${complexAI.name}');
      await _startProfileVsComplexConversation(profileAI, complexAI);
      return;
    } else {
      // それ以外の場合はデモ会話
      print('通常の会話を開始します。');
      _startDemoConversation(person1, person2);
      return;
    }
  }

  Future<void> _startProfileVsComplexConversation(Person profileAI, Person complexAI) async {
    print('プロフィールAI vs コンプレックスAI 会話開始: ${profileAI.name} vs ${complexAI.name}');
    
    // キャラクターの詳細情報を取得
    final character1Data = {
      'id': profileAI.id,
      'name': profileAI.name,
      'complexData': profileAI.complexData,
      'basicData': {}, // プロフィールAIには基本プロフィールデータを設定
      'aiCharacterSettings': profileAI.aiCharacterSettings,
      'vectorStoreId': profileAI.vectorStoreId,
    };
    
    final character2Data = {
      'id': complexAI.id,
      'name': complexAI.name,
      'complexData': complexAI.complexData,
      'aiCharacterSettings': complexAI.aiCharacterSettings,
      'vectorStoreId': complexAI.vectorStoreId,
    };
    
    print('キャラクター1データ: $character1Data');
    print('キャラクター2データ: $character2Data');
    
    // vectorStoreIdを持つキャラクターを検索
    final vectorStoreIds = <String>[];
    if (profileAI.vectorStoreId != null && profileAI.vectorStoreId!.isNotEmpty) {
      vectorStoreIds.add(profileAI.vectorStoreId!);
      print('プロフィールAI vectorStoreId追加: ${profileAI.vectorStoreId}');
    }
    if (complexAI.vectorStoreId != null && complexAI.vectorStoreId!.isNotEmpty) {
      vectorStoreIds.add(complexAI.vectorStoreId!);
      print('コンプレックスAI vectorStoreId追加: ${complexAI.vectorStoreId}');
    }

    print('vectorStoreIds数: ${vectorStoreIds.length}');

    if (vectorStoreIds.length >= 2) {
      // 最新のイベントを取得
      final latestEvent = await _getLatestEvent();
      print('取得したイベント: $latestEvent');
      
      // プロフィールAI vs コンプレックスAIの会話では、イベントの主語をプロフィールAIに変更
      final modifiedEvent = Map<String, String>.from(latestEvent);
      modifiedEvent['who'] = profileAI.name; // 主語をプロフィールAIに変更
      print('修正後のイベント: $modifiedEvent');
      
      // イベント情報を保存
      setState(() {
        _currentEvent = modifiedEvent;
      });
      
      try {
        print('AIService.startAIConversationを呼び出します...');
        
        // プロフィールAI vs コンプレックスAI 会話APIを呼び出す
        final conversationResult = await AIService.startAIConversation(
          vectorStoreIds, 
          modifiedEvent,
          characterData: [character1Data, character2Data]
        );
        
        print('API応答: $conversationResult');
        
        if (conversationResult != null && conversationResult['messages'] != null) {
          final messages = conversationResult['messages'] as List<dynamic>;
          print('受信したメッセージ数: ${messages.length}');
          
          // 会話ログを保存
          await _saveConversationLog(profileAI, complexAI, messages, modifiedEvent);
          
          // 会話を段階的に表示
          _startConversationDisplay(messages);
        } else {
          print('会話結果がnullまたはメッセージが空です');
          // フォールバック: デモ会話を表示
          _startDemoConversation(profileAI, complexAI);
        }
      } catch (e) {
        print('AI会話エラー: $e');
        // フォールバック: デモ会話を表示
        _startDemoConversation(profileAI, complexAI);
      }
    } else {
      print('vectorStoreIdが不足しています。デモ会話を開始します。');
      // フォールバック: デモ会話を表示
      _startDemoConversation(profileAI, complexAI);
    }
  }

  void _startDemoConversation(Person person1, Person person2) {
    print('デモ会話を開始します');
    final demoMessages = [
      '${person1.name}: こんにちは！',
      '${person2.name}: こんにちは！元気ですか？',
      '${person1.name}: はい、とても元気です。今日はいい天気ですね。',
      '${person2.name}: そうですね。こんな日は気分が良いです。',
      '${person1.name}: また今度お話ししましょう！',
      '${person2.name}: ぜひ！楽しかったです。'
    ];
    
    _startConversationDisplay(demoMessages);
  }

  void _startConversationDisplay(List<dynamic> messages) {
    print('会話表示を開始します。メッセージ数: ${messages.length}');
    int messageIndex = 0;
    
    // 最初のメッセージをすぐに表示
    if (messages.isNotEmpty) {
      setState(() {
        _currentConversation.add(messages[0].toString());
      });
      messageIndex = 1;
      print('最初のメッセージを表示: ${messages[0]}');
    }
    
    _conversationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (messageIndex < messages.length) {
        setState(() {
          _currentConversation.add(messages[messageIndex].toString());
        });
        print('メッセージ追加 [${messageIndex}]: ${messages[messageIndex]}');
        messageIndex++;
      } else {
        timer.cancel();
        print('全メッセージ表示完了。5秒後に会話を終了します。');
        // 会話終了後、少し待ってから状態をリセット
        Timer(const Duration(seconds: 5), () {
          _stopAutoConversation();
        });
      }
    });
  }

  void _stopAutoConversation() {
    print('AI会話を停止します');
    setState(() {
      _isAIConversationActive = false;
      _currentConversation.clear();
      _currentEvent = null; // イベント情報をクリア
    });
    _conversationTimer?.cancel();
    
    // 会話終了時にキャラクターの移動を再開
    _resumeAllCharacters();
  }

  // 会話開始前のアニメーション用変数
  List<Person> _conversationReadyCharacters = [];
  
  void _stopCharacters(Person person1, Person person2) {
    print('キャラクターを停止: ${person1.name}, ${person2.name}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        if (!_stoppedCharacters.contains(person1)) {
          _stoppedCharacters.add(person1);
        }
        if (!_stoppedCharacters.contains(person2)) {
          _stoppedCharacters.add(person2);
        }
        
        // 会話準備中のキャラクターとしてマーク
        _conversationReadyCharacters = [person1, person2];
        
        // 少し遅延してから会話を開始（アニメーションを見せるため）
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted && _conversationReadyCharacters.isNotEmpty) {
            _conversationReadyCharacters = [];
            setState(() {});
          }
        });
      });
    });
  }

  void _resumeAllCharacters() {
    if (_stoppedCharacters.isNotEmpty) {
      print('全キャラクターの移動を再開');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _stoppedCharacters.clear();
        });
      });
    }
  }

  Future<Map<String, String>> _getLatestEvent() async {
    try {
      // LocalStorageからイベントを取得
      final events = await LocalStorage.getEvents();
      
      if (events.isEmpty) {
        // イベントがない場合はデフォルトイベントを返す
        return {
          'who': '友達',
          'what': '新しいカフェを見つけた',
          'when': '昨日',
          'where': '駅前',
          'why': '美味しいコーヒーが飲みたくて',
          'how': '偶然通りかかって'
        };
      }
      
      // 最新のイベントを取得（リストの最後のアイテム）
      final latestEvent = events.last;
      final basicData = latestEvent['basicData'] as Map<String, dynamic>;
      
      // Map<String, String>に変換して返す
      return {
        'who': basicData['who'] as String,
        'what': basicData['what'] as String,
        'when': basicData['when'] as String,
        'where': basicData['where'] as String,
        'why': basicData['why'] as String,
        'how': basicData['how'] as String,
      };
    } catch (e) {
      print('イベント取得エラー: $e');
      // エラーが発生した場合はデフォルトイベントを返す
      return {
        'who': '友達',
        'what': '新しいカフェを見つけた',
        'when': '昨日',
        'where': '駅前',
        'why': '美味しいコーヒーが飲みたくて',
        'how': '偶然通りかかって'
      };
    }
  }

  Future<void> _saveConversationLog(
    Person person1, 
    Person person2, 
    List<dynamic> messages, 
    Map<String, String> event
  ) async {
    final conversationData = {
      'participants': [person1.name, person2.name],
      'messages': messages,
      'event_trigger': event,
    };
    
    await LocalStorage.saveConversationLog(conversationData);
  }

  void _testConversation() {
    print('テスト会話をトリガーします');
    if (people.length >= 2) {
      final person1 = people[0];
      final person2 = people[1];
      _startAutoConversation(person1, person2);
    } else {
      print('キャラクターが足りません');
    }
  }

  // イベント情報を保存する変数
  Map<String, String>? _currentEvent;

  Widget _buildConversationOverlay() {
    print('会話オーバーレイを構築中。会話アクティブ: $_isAIConversationActive, メッセージ数: ${_currentConversation.length}');
    
    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.chat_bubble, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'AI会話',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _stopAutoConversation,
                  icon: const Icon(Icons.close, size: 20),
                ),
              ],
            ),
            if (_currentEvent != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'イベント: ${_currentEvent!['what']}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_currentEvent!['who']}が${_currentEvent!['when']}、${_currentEvent!['where']}で${_currentEvent!['why']}、${_currentEvent!['how']}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _currentConversation.isEmpty 
                    ? [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '会話を準備中...',
                            style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                          ),
                        )
                      ]
                    : _currentConversation.map((message) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            message,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApproachArrow() {
    if (_movingPerson == null || _targetPerson == null) return Container();
    
    final start = _movingPerson!.currentPosition;
    final end = _targetPerson!.currentPosition;
    
    return Stack(
      children: [
        // 移動パスを表示
        CustomPaint(
          size: Size(screenSize.width, screenSize.height),
          painter: PathPainter(
            start: start,
            end: end,
            color: Colors.blue.withOpacity(0.4),
          ),
        ),
        
        // 接近中のラベル
        Positioned(
          left: start.dx + 25,
          top: start.dy - 30,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_targetPerson!.name}に接近中',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 12,
                ),
              ],
            ),
          ),
        ),
        
        // ターゲットの周りに目標地点を表示
        Positioned(
          left: end.dx - 30,
          top: end.dy - 30,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.blue.withOpacity(0.6),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStoppedIndicator(Person person) {
    return Positioned(
      left: person.currentPosition.dx + 25,
      top: person.currentPosition.dy - 40,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.pause,
              color: Colors.white,
              size: 10,
            ),
            const SizedBox(width: 3),
            Text(
              '停止中',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 会話準備中のキャラクターの周りに表示するインジケーター
  Widget _buildConversationReadyIndicator(Person person) {
    return Positioned(
      left: person.currentPosition.dx - 5,
      top: person.currentPosition.dy - 5,
      child: Stack(
        children: [
          // 脈動するアニメーション効果
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.5, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.yellow.withOpacity(value * 0.8),
                    width: 3,
                  ),
                ),
              );
            },
          ),
          
          // 会話アイコン
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.yellow,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chat_bubble,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


