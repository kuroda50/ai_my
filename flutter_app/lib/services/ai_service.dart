import 'dart:convert';
import 'dart:async';
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
    
    // 安全に値を取得するヘルパー関数
    String safeGet(Map<String, String> data, String key, String defaultValue) {
      if (data == null || data.isEmpty) return defaultValue;
      final value = data[key];
      return value?.isNotEmpty == true ? value! : defaultValue;
    }
    
    // 安全に感情データを取得するヘルパー関数
    String safeGetEmotion(Map<String, double> emotionData) {
      if (emotionData == null || emotionData.isEmpty) return '複雑な気持ち';
      return _getEmotionDescription(emotionData);
    }
    
    // デバッグ情報
    print('Debug: Converting data...');
    print('Debug: basicData is empty: ${basicData.isEmpty}');
    print('Debug: emotionData is empty: ${emotionData.isEmpty}');
    print('Debug: complexData is empty: ${complexData.isEmpty}');
    
    return {
      "character_index": "0", // Always use 0 for first character
      "q0_answer": "$age、$gender、$situation、現在の状況: ${safeGet(basicData, 'what', 'コンプレックスについて考え中')}",
      "q1_answer": "${safeGet(complexData, 'question_1', 'コンプレックスについて考え中')}。感情的には${safeGetEmotion(emotionData)}を感じている。",
      "q2_answer": "${safeGet(complexData, 'question_2', 'コンプレックスの見方について')}。${safeGet(basicData, 'where', '日常生活')}のような場所で${safeGet(basicData, 'when', '人前で話す時')}に困ることがある。",
      "q3_answer": "${safeGet(complexData, 'question_3', 'コンプレックスを感じ始めた時期')}。${safeGet(basicData, 'why', '自己改善のため')}という理由で向き合うことを試みた。",
      "q4_answer": "${safeGet(complexData, 'question_4', 'コンプレックスを感じる状況')}。${safeGet(basicData, 'who', '周りの人')}のような人と関わる時に${safeGet(complexData, 'question_5', '緊張してしまう')}",
      "q5_answer": "${safeGet(complexData, 'question_5', 'コンプレックスを感じた時の感情')}。${safeGet(basicData, 'how', '少しずつ改善していく')}のような方法で成長していきたい。",
      "q6_answer": safeGet(complexData, 'question_6', 'コンプレックスによる行動パターン'),
      "q7_answer": safeGet(complexData, 'question_7', 'コンプレックスが人間関係に与える影響'),
      "q8_answer": safeGet(complexData, 'question_8', 'コンプレックスのポジティブな側面'),
      "q9_answer": safeGet(complexData, 'question_9', 'コンプレックスとの向き合い方')
    };
  }
  
  static String _getEmotionDescription(Map<String, double> emotionData) {
    if (emotionData == null || emotionData.isEmpty) {
      return '複雑な気持ち';
    }
    
    final emotions = <String>[];
    
    if (emotionData['joy'] != null && emotionData['joy']! > 60) emotions.add('喜び');
    if (emotionData['anger'] != null && emotionData['anger']! > 60) emotions.add('怒り');
    if (emotionData['sadness'] != null && emotionData['sadness']! > 60) emotions.add('悲しみ');
    if (emotionData['pleasure'] != null && emotionData['pleasure']! > 60) emotions.add('楽しさ');
    
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
      print('Debug: Starting character generation...');
      print('Debug: basicData keys = ${basicData.keys.toList()}');
      print('Debug: emotionData keys = ${emotionData.keys.toList()}');
      print('Debug: complexData keys = ${complexData.keys.toList()}');
      
      final requestData = _convertToBackendFormat(basicData, emotionData, complexData);
      print('Debug: requestData created successfully');
      
      // デバッグ情報を出力
      print('Debug: basicData = $basicData');
      print('Debug: emotionData = $emotionData');
      print('Debug: complexData = $complexData');
      print('Debug: requestData = $requestData');
      
      print('Debug: Sending HTTP request to $baseUrl/generate_character');
      final response = await http.post(
        Uri.parse('$baseUrl/generate_character'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );
      print('Debug: HTTP response received: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('Debug: Parsing response body...');
        try {
          final responseData = jsonDecode(response.body);
          print('Debug: Response parsed successfully');
          print('Debug: Response data type = ${responseData.runtimeType}');
          print('Debug: Response data keys = ${responseData is Map ? responseData.keys.toList() : 'Not a Map'}');
          
          // null値チェックを追加
          if (responseData is Map) {
            // 必要なキーが存在し、nullでないことを確認
            final characterSettings = responseData['character_settings']?.toString() ?? '';
            final conversationData = responseData['conversation_data']?.toString() ?? '';
            final vectorStoreId = responseData['vector_store_id']?.toString() ?? '';
            final status = responseData['status']?.toString() ?? '';
            
            print('Debug: characterSettings is null: ${responseData['character_settings'] == null}');
            print('Debug: conversationData is null: ${responseData['conversation_data'] == null}');
            print('Debug: vectorStoreId is null: ${responseData['vector_store_id'] == null}');
            
            // 安全なデータを返す
            return {
              'character_settings': characterSettings,
              'conversation_data': conversationData,
              'vector_store_id': vectorStoreId,
              'status': status,
            };
          }
          
          return responseData;
        } catch (jsonError) {
          print('Error parsing JSON response: $jsonError');
          print('Response body: ${response.body}');
          return null;
        }
      } else {
        print('Error generating character: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception during character generation: $e');
      // StackTraceの安全な処理
      try {
        final stackTrace = StackTrace.current;
        print('Stack trace: $stackTrace');
      } catch (stackError) {
        print('Could not get stack trace: $stackError');
      }
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
  
  // Start AI conversation between characters
  static Future<Map<String, dynamic>?> startAIConversation(
    List<String> vectorStoreIds, 
    Map<String, String> event
  ) async {
    try {
      print('AIService: AI会話リクエストを開始');
      print('AIService: vectorStoreIds = $vectorStoreIds');
      print('AIService: event = $event');
      print('AIService: baseUrl = $baseUrl');
      
      final requestData = {
        "vector_store_ids": vectorStoreIds,
        "event": event,
      };
      
      print('AIService: リクエストデータ = $requestData');
      
      final response = await http.post(
        Uri.parse('$baseUrl/ai_conversation'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      ).timeout(const Duration(seconds: 30));
      
      print('AIService: レスポンス受信 - ステータス: ${response.statusCode}');
      print('AIService: レスポンスボディ: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('AIService: レスポンス解析成功');
        return responseData;
      } else {
        print('AIService: エラー - ステータス: ${response.statusCode}');
        print('AIService: エラーレスポンス: ${response.body}');
        
        // フォールバック用のダミーデータを返す
        return {
          'status': 'fallback',
          'messages': [
            'システム: バックエンドサーバーに接続できませんでした',
            'システム: デモ会話を表示します'
          ]
        };
      }
    } catch (e) {
      print('AIService: 例外発生 - $e');
      
      // フォールバック用のダミーデータを返す
      return {
        'status': 'fallback',
        'messages': [
          'システム: 接続エラーが発生しました',
          'システム: デモ会話を表示します'
        ]
      };
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