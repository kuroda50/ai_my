import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/person.dart';

class LocalStorage {
  static const String _eventsKey = 'events';
  static const String _charactersKey = 'characters';

  // Event関連
  static Future<void> saveEvent(Map<String, dynamic> eventData) async {
    final prefs = await SharedPreferences.getInstance();
    final events = await getEvents();
    
    final event = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'timestamp': DateTime.now().toIso8601String(),
      'basicData': eventData['basicData'],
      'emotionData': eventData['emotionData'],
    };
    
    events.add(event);
    await prefs.setString(_eventsKey, jsonEncode(events));
  }

  static Future<List<Map<String, dynamic>>> getEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getString(_eventsKey);
    
    if (eventsJson == null) return [];
    
    final eventsList = jsonDecode(eventsJson) as List;
    return eventsList.cast<Map<String, dynamic>>();
  }

  static Future<void> deleteEvent(String eventId) async {
    final prefs = await SharedPreferences.getInstance();
    final events = await getEvents();
    
    events.removeWhere((event) => event['id'] == eventId);
    await prefs.setString(_eventsKey, jsonEncode(events));
  }

  // Character関連
  static Future<void> saveCharacter(Person character) async {
    final prefs = await SharedPreferences.getInstance();
    final characters = await getCharacters();
    
    final characterData = {
      'id': character.id.toString(),
      'name': character.name,
      'color': character.color.value,
      'timestamp': DateTime.now().toIso8601String(),
      'messages': character.messages,
      'complexData': character.complexData,
      'aiCharacterSettings': character.aiCharacterSettings,
      'aiConversationData': character.aiConversationData,
      'vectorStoreId': character.vectorStoreId,
    };
    
    characters.add(characterData);
    await prefs.setString(_charactersKey, jsonEncode(characters));
  }

  static Future<List<Map<String, dynamic>>> getCharacters() async {
    final prefs = await SharedPreferences.getInstance();
    final charactersJson = prefs.getString(_charactersKey);
    
    if (charactersJson == null) return [];
    
    final charactersList = jsonDecode(charactersJson) as List;
    return charactersList.cast<Map<String, dynamic>>();
  }

  static Future<void> deleteCharacter(String characterId) async {
    final prefs = await SharedPreferences.getInstance();
    final characters = await getCharacters();
    
    characters.removeWhere((character) => character['id'] == characterId);
    await prefs.setString(_charactersKey, jsonEncode(characters));
  }

  // データクリア
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_eventsKey);
    await prefs.remove(_charactersKey);
  }
}