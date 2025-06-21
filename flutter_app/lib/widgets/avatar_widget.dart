import 'package:flutter/material.dart';
import '../models/person.dart';

class AvatarWidget extends StatelessWidget {
  final Person person;
  final bool isSelected;
  final bool isDragged;
  final VoidCallback onTap;
  final GestureDragStartCallback? onPanStart;
  final GestureDragUpdateCallback? onPanUpdate;
  final GestureDragEndCallback? onPanEnd;

  const AvatarWidget({
    super.key,
    required this.person,
    required this.isSelected,
    required this.isDragged,
    required this.onTap,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: person.currentPosition.dx,
      top: person.currentPosition.dy,
      child: GestureDetector(
        onTap: onTap,
        onPanStart: onPanStart,
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..scale(isSelected ? 1.2 : (isDragged ? 1.1 : 1.0)),
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
                    color: person.isUser ? Colors.yellow : Colors.white,
                    width: person.isUser ? 4 : 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  person.isUser ? Icons.face : Icons.person,
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
              // ID 0の「あなた」だけドラッグアイコンを表示
              if (person.isUser && person.id == 0)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.drag_indicator,
                    color: Colors.grey.withOpacity(0.7),
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}