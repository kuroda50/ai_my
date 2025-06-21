import 'package:flutter/material.dart';

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
  final bool isUser;
  final Map<String, String>? complexData;
  final String? aiCharacterSettings;
  final String? aiConversationData;
  final String? vectorStoreId;

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
    this.isUser = false,
    this.complexData,
    this.aiCharacterSettings,
    this.aiConversationData,
    this.vectorStoreId,
  });
}