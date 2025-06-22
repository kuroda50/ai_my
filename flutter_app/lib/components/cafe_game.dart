import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../models/person.dart';

class CafeGame extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection {
  late CafeInterior cafeInterior;
  List<PersonSprite> personSprites = [];
  List<Person> people = [];
  Function(Person, Person)? onCharactersNearby;
  Function(Person)? onPersonTap;
  Function(Person)? onDragStart;
  Function(Person)? onDragEnd;
  Size? gameSize;
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // カフェの内装を作成
    cafeInterior = CafeInterior();
    add(cafeInterior);
  }
  
  void setGameSize(Size size) {
    gameSize = size;
    // カフェ内装のサイズも更新
    cafeInterior.updateSize(size);
  }
  
  void updatePeople(List<Person> newPeople) {
    // 既存のPersonSpriteを削除
    for (final sprite in personSprites) {
      sprite.removeFromParent();
    }
    personSprites.clear();
    
    people = newPeople;
    
    // 新しいPersonSpriteを追加
    for (final person in people) {
      final personSprite = PersonSprite(person);
      personSprite.onTapCallback = onPersonTap;
      personSprite.onDragStartCallback = onDragStart;
      personSprite.onDragEndCallback = onDragEnd;
      personSprite.onDragUpdateCallback = (person, position) {
        _checkProximityForDrag(person);
      };
      personSprites.add(personSprite);
      add(personSprite);
    }
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // キャラクター同士の距離をチェック
    _checkProximity();
  }
  
  void _checkProximity() {
    const double proximityThreshold = 80.0;
    
    for (int i = 0; i < people.length; i++) {
      for (int j = i + 1; j < people.length; j++) {
        final person1 = people[i];
        final person2 = people[j];
        
        final distance = (person1.currentPosition - person2.currentPosition).distance;
        
        if (distance <= proximityThreshold) {
          onCharactersNearby?.call(person1, person2);
        }
      }
    }
  }
  
  void _checkProximityForDrag(Person draggedUser) {
    const double proximityThreshold = 80.0;
    
    for (final person in people) {
      if (person.id != draggedUser.id) {
        final distance = (draggedUser.currentPosition - person.currentPosition).distance;
        if (distance <= proximityThreshold) {
          onCharactersNearby?.call(draggedUser, person);
          break;
        }
      }
    }
  }
}

class CafeInterior extends Component {
  Size screenSize = const Size(400, 800);
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    _setupInterior();
  }
  
  void updateSize(Size newSize) {
    screenSize = newSize;
    // 既存の子コンポーネントをクリア
    removeAll(children.toList());
    // 新しいサイズで再構築
    _setupInterior();
  }
  
  void _setupInterior() {
    // カフェの床
    final floor = RectangleComponent(
      size: Vector2(screenSize.width, screenSize.height),
      paint: Paint()..color = const Color(0xFF8B4513).withOpacity(0.3),
    );
    add(floor);
    
    // カフェテーブル
    _addCafeTables();
    
    // カウンター
    _addCounter();
    
    // 植物
    _addPlants();
    
    // 窓
    _addWindows();
    
    // 装飾品
    _addDecorations();
  }
  
  void _addCafeTables() {
    final tablePositions = [
      Vector2(screenSize.width * 0.2, screenSize.height * 0.25),
      Vector2(screenSize.width * 0.7, screenSize.height * 0.19),
      Vector2(screenSize.width * 0.375, screenSize.height * 0.44),
      Vector2(screenSize.width * 0.8, screenSize.height * 0.4),
      Vector2(screenSize.width * 0.175, screenSize.height * 0.625),
      Vector2(screenSize.width * 0.625, screenSize.height * 0.6),
    ];
    
    for (final position in tablePositions) {
      // テーブル本体
      final table = CircleComponent(
        radius: 25,
        paint: Paint()..color = const Color(0xFF654321),
        position: position,
      );
      add(table);
      
      // テーブルの縁
      final tableBorder = CircleComponent(
        radius: 27,
        paint: Paint()
          ..color = const Color(0xFF8B4513)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
        position: position,
      );
      add(tableBorder);
      
      // 椅子を4つ配置
      _addChairsAroundTable(position, 35);
    }
  }
  
  void _addChairsAroundTable(Vector2 tableCenter, double distance) {
    final chairPositions = [
      tableCenter + Vector2(distance, 0),      // 右
      tableCenter + Vector2(-distance, 0),     // 左
      tableCenter + Vector2(0, distance),      // 下
      tableCenter + Vector2(0, -distance),     // 上
    ];
    
    for (final position in chairPositions) {
      final chair = CircleComponent(
        radius: 12,
        paint: Paint()..color = const Color(0xFF8B4513),
        position: position,
      );
      add(chair);
      
      // 椅子の背もたれ
      final chairBack = RectangleComponent(
        size: Vector2(20, 8),
        paint: Paint()..color = const Color(0xFF654321),
        position: position - Vector2(10, 4),
      );
      add(chairBack);
    }
  }
  
  void _addCounter() {
    final counterWidth = screenSize.width * 0.375;
    final counterHeight = screenSize.height * 0.05;
    final counterX = screenSize.width * 0.05;
    final counterY = screenSize.height * 0.125;
    
    // メインカウンター
    final counter = RectangleComponent(
      size: Vector2(counterWidth, counterHeight),
      paint: Paint()..color = const Color(0xFF8B4513),
      position: Vector2(counterX, counterY),
    );
    add(counter);
    
    // カウンタートップ
    final counterTop = RectangleComponent(
      size: Vector2(counterWidth, counterHeight * 0.2),
      paint: Paint()..color = const Color(0xFFD2B48C),
      position: Vector2(counterX, counterY - counterHeight * 0.125),
    );
    add(counterTop);
    
    // コーヒーマシン
    final coffeeMachine = RectangleComponent(
      size: Vector2(counterWidth * 0.2, counterHeight * 0.625),
      paint: Paint()..color = const Color(0xFF2F2F2F),
      position: Vector2(counterX + counterWidth * 0.133, counterY + counterHeight * 0.125),
    );
    add(coffeeMachine);
    
    // レジ
    final cashRegister = RectangleComponent(
      size: Vector2(counterWidth * 0.167, counterHeight * 0.5),
      paint: Paint()..color = const Color(0xFF333333),
      position: Vector2(counterX + counterWidth * 0.667, counterY + counterHeight * 0.2),
    );
    add(cashRegister);
  }
  
  void _addPlants() {
    final plantPositions = [
      Vector2(screenSize.width * 0.875, screenSize.height * 0.15),
      Vector2(screenSize.width * 0.075, screenSize.height * 0.3125),
      Vector2(screenSize.width * 0.875, screenSize.height * 0.5),
      Vector2(screenSize.width * 0.125, screenSize.height * 0.75),
    ];
    
    for (final position in plantPositions) {
      // 植木鉢
      final pot = RectangleComponent(
        size: Vector2(20, 15),
        paint: Paint()..color = const Color(0xFF8B4513),
        position: position,
      );
      add(pot);
      
      // 植物
      final plant = CircleComponent(
        radius: 15,
        paint: Paint()..color = const Color(0xFF228B22),
        position: position + Vector2(10, -10),
      );
      add(plant);
    }
  }
  
  void _addWindows() {
    final windowWidth = screenSize.width * 0.02;
    final windowHeight = screenSize.height * 0.15;
    
    // 左の窓
    final leftWindow = RectangleComponent(
      size: Vector2(windowWidth, windowHeight),
      paint: Paint()..color = const Color(0xFF87CEEB).withOpacity(0.7),
      position: Vector2(0, screenSize.height * 0.25),
    );
    add(leftWindow);
    
    // 右の窓
    final rightWindow = RectangleComponent(
      size: Vector2(windowWidth, windowHeight),
      paint: Paint()..color = const Color(0xFF87CEEB).withOpacity(0.7),
      position: Vector2(screenSize.width - windowWidth, screenSize.height * 0.25),
    );
    add(rightWindow);
    
    // 窓枠
    for (final window in [leftWindow, rightWindow]) {
      final frame = RectangleComponent(
        size: window.size + Vector2(4, 4),
        paint: Paint()
          ..color = const Color(0xFF654321)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
        position: window.position - Vector2(2, 2),
      );
      add(frame);
    }
  }
  
  void _addDecorations() {
    // 天井のライト
    final lightPositions = [
      Vector2(screenSize.width * 0.375, screenSize.height * 0.1),
      Vector2(screenSize.width * 0.625, screenSize.height * 0.1),
      Vector2(screenSize.width * 0.25, screenSize.height * 0.35),
      Vector2(screenSize.width * 0.75, screenSize.height * 0.35),
      Vector2(screenSize.width * 0.5, screenSize.height * 0.5625),
    ];
    
    for (final position in lightPositions) {
      final light = CircleComponent(
        radius: 8,
        paint: Paint()..color = const Color(0xFFFFFACD),
        position: position,
      );
      add(light);
      
      // ライトの影響範囲（ほのかな光）
      final lightGlow = CircleComponent(
        radius: 25,
        paint: Paint()..color = const Color(0xFFFFFACD).withOpacity(0.1),
        position: position,
      );
      add(lightGlow);
    }
    
    // 壁の絵画
    final paintings = [
      Vector2(screenSize.width * 0.05, screenSize.height * 0.225),
      Vector2(screenSize.width * 0.8, screenSize.height * 0.225),
      Vector2(screenSize.width * 0.5, screenSize.height * 0.0625),
    ];
    
    for (final position in paintings) {
      final painting = RectangleComponent(
        size: Vector2(30, 25),
        paint: Paint()..color = const Color(0xFF4B0082),
        position: position,
      );
      add(painting);
      
      // 額縁
      final frame = RectangleComponent(
        size: Vector2(32, 27),
        paint: Paint()
          ..color = const Color(0xFFFFD700)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
        position: position - Vector2(1, 1),
      );
      add(frame);
    }
    
    // メニューボード
    final menuBoard = RectangleComponent(
      size: Vector2(screenSize.width * 0.1, screenSize.height * 0.075),
      paint: Paint()..color = const Color(0xFF2F2F2F),
      position: Vector2(screenSize.width * 0.45, screenSize.height * 0.125),
    );
    add(menuBoard);
  }
}

class PersonSprite extends PositionComponent with TapCallbacks, DragCallbacks {
  final Person person;
  late CircleComponent avatar;
  late TextComponent nameText;
  Function(Person)? onTapCallback;
  Function(Person)? onDragStartCallback;
  Function(Person, Vector2)? onDragUpdateCallback;
  Function(Person)? onDragEndCallback;
  bool isDragging = false;
  
  PersonSprite(this.person);
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    position = Vector2(person.currentPosition.dx, person.currentPosition.dy);
    size = Vector2(50, 50);
    anchor = Anchor.center;
    
    // アバター
    avatar = CircleComponent(
      radius: 25,
      paint: Paint()..color = person.color,
      anchor: Anchor.center,
    );
    add(avatar);
    
    // 名前テキスト
    nameText = TextComponent(
      text: person.name,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(0, 35),
    );
    add(nameText);
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (!isDragging) {
      // Personの位置に同期（ドラッグ中でない場合のみ）
      position = Vector2(person.currentPosition.dx, person.currentPosition.dy);
    }
  }
  
  @override
  bool onTapDown(TapDownEvent event) {
    onTapCallback?.call(person);
    return true;
  }
  
  @override
  bool onDragStart(DragStartEvent event) {
    isDragging = true;
    onDragStartCallback?.call(person);
    return true;
  }
  
  @override
  bool onDragUpdate(DragUpdateEvent event) {
    if (isDragging) {
      // 新しい位置を計算し、画面境界内に制限
      final newPosition = position + event.localDelta;
      final gameSize = findGame()?.size ?? Vector2.zero();
      
      // 画面境界内に制限（キャラクターサイズを考慮）
      final clampedPosition = Vector2(
        newPosition.x.clamp(25.0, gameSize.x - 75.0),
        newPosition.y.clamp(100.0, gameSize.y - 150.0),
      );
      
      position = clampedPosition;
      // Personの位置も更新
      person.currentPosition = Offset(position.x, position.y);
      onDragUpdateCallback?.call(person, position);
    }
    return true;
  }
  
  @override
  bool onDragEnd(DragEndEvent event) {
    isDragging = false;
    onDragEndCallback?.call(person);
    return true;
  }
}