import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String baseUrl = 'http://localhost:5001';
  
  // Flutter app data to backend_ai API format conversion
  static Map<String, String> _convertToBackendFormat(
    Map<String, String> basicData,
    Map<String, double> emotionData,
    Map<String, String> complexData,
  ) {
    // Convert Flutter app data to match backend_ai's expected format
    final age = "20代"; // Default age, could be extracted from basicData
    final gender = "女性"; // Backend expects female characters
    final situation = "学生"; // Default situation
    
    return {
      "character_index": "0", // Always use 0 for first character
      "q0_answer": "$age、$gender、$situation、現在の状況: ${basicData['what'] ?? ''}",
      "q1_answer": "${complexData['question_1'] ?? ''}。感情的には${_getEmotionDescription(emotionData)}を感じている。",
      "q2_answer": "${complexData['question_4'] ?? ''}。${basicData['where'] ?? ''}のような場所で${basicData['when'] ?? ''}に困ることがある。",
      "q3_answer": "${complexData['question_6'] ?? ''}。${basicData['why'] ?? ''}という理由で向き合うことを試みた。",
      "q4_answer": "${complexData['question_2'] ?? ''}。${basicData['who'] ?? ''}のような人と関わる時に${complexData['question_7'] ?? ''}",
      "q5_answer": "${complexData['question_9'] ?? ''}。${basicData['how'] ?? ''}のような方法で成長していきたい。"
    };
  }
  
  static String _getEmotionDescription(Map<String, double> emotionData) {
    final emotions = <String>[];
    
    if (emotionData['joy']! > 60) emotions.add('喜び');
    if (emotionData['anger']! > 60) emotions.add('怒り');
    if (emotionData['sadness']! > 60) emotions.add('悲しみ');
    if (emotionData['pleasure']! > 60) emotions.add('楽しさ');
    
    if (emotions.isEmpty) return '複雑な気持ち';
    return emotions.join('と');
  }
  
  // Generate character using backend_ai API
  static Future<Map<String, dynamic>?> generateCharacter(
    Map<String, String> basicData,
    Map<String, double> emotionData,
    Map<String, String> complexData,
  ) async {
    try {
      final requestData = _convertToBackendFormat(basicData, emotionData, complexData);
      
      final response = await http.post(
        Uri.parse('$baseUrl/generate_character'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData;
      } else {
        print('Error generating character: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception during character generation: $e');
      return null;
    }
  }
  
  // Start AI chat
  static Future<Map<String, dynamic>?> startAIChat(List<String> characterIds) async {
    try {
      final requestData = {
        "character_id": characterIds,
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/ai_chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData;
      } else {
        print('Error starting AI chat: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception during AI chat: $e');
      return null;
    }
  }
  
  // Check if backend is available
  static Future<bool> checkBackendStatus() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      return response.statusCode == 200 || response.statusCode == 404; // 404 is OK for Flask root
    } catch (e) {
      print('Backend connection error: $e');
      return false;
    }
  }
}