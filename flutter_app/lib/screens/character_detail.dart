import 'package:flutter/material.dart';
import '../models/person.dart';

class CharacterDetailScreen extends StatelessWidget {
  final Map<String, dynamic> characterData;

  const CharacterDetailScreen({
    super.key,
    required this.characterData,
  });

  @override
  Widget build(BuildContext context) {
    final name = characterData['name'] ?? 'Unknown';
    final id = characterData['id'] ?? '';
    final parsedId = int.tryParse(id.toString()) ?? 0;
    final timestamp = DateTime.parse(characterData['timestamp']);
    final color = Color(characterData['color'] ?? Colors.teal.value);
    final messages = (characterData['messages'] as List?)?.cast<String>() ?? [];
    final aiCharacterSettings = characterData['aiCharacterSettings'] ?? '';
    final aiConversationData = characterData['aiConversationData'] ?? '';
    final vectorStoreId = characterData['vectorStoreId'] ?? '';
    final complexData = characterData['complexData'] as Map<String, dynamic>?;
    
    // キャラクターの種類を判別
    String characterType;
    IconData characterIcon;
    Color characterTypeColor;
    
    if (parsedId == 0) {
      characterType = 'ユーザー（あなた）';
      characterIcon = Icons.person;
      characterTypeColor = Colors.orange;
    } else if (1000 <= parsedId && parsedId < 2000) {
      characterType = 'プロフィールAI';
      characterIcon = Icons.psychology;
      characterTypeColor = Colors.blue;
    } else if (2000 <= parsedId && parsedId < 3000) {
      characterType = 'コンプレックスAI';
      characterIcon = Icons.sentiment_dissatisfied;
      characterTypeColor = Colors.purple;
    } else {
      characterType = 'その他';
      characterIcon = Icons.help;
      characterTypeColor = Colors.grey;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('$name の詳細'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // キャラクター基本情報
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: color,
                      radius: 40,
                      child: Icon(characterIcon, color: Colors.white, size: 40),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: characterTypeColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: characterTypeColor.withOpacity(0.5)),
                            ),
                            child: Text(
                              characterType,
                              style: TextStyle(
                                color: characterTypeColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: $id',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '作成日: ${timestamp.year}/${timestamp.month}/${timestamp.day} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'メッセージ数: ${messages.length}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            // AIキャラクター設定
            if (aiCharacterSettings.isNotEmpty) ...[
              _buildSectionCard(
                title: 'AIキャラクター設定',
                icon: Icons.settings,
                content: aiCharacterSettings,
              ),
              const SizedBox(height: 16),
            ],

            // 会話データ
            if (aiConversationData.isNotEmpty) ...[
              _buildSectionCard(
                title: '会話例',
                icon: Icons.chat_bubble,
                content: aiConversationData,
              ),
              const SizedBox(height: 16),
            ],

            // コンプレックスデータ（コンプレックスAIの場合）
            if (complexData != null && complexData.isNotEmpty) ...[
              _buildComplexDataCard(complexData),
              const SizedBox(height: 16),
            ],

            // メッセージリスト
            if (messages.isNotEmpty) ...[
              _buildMessagesCard(messages),
              const SizedBox(height: 16),
            ],

            // 技術情報
            if (vectorStoreId.isNotEmpty) ...[
              _buildTechnicalInfoCard(vectorStoreId),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                content,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplexDataCard(Map<String, dynamic> complexData) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.psychology, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'コンプレックス情報',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...complexData.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        entry.value.toString(),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesCard(List<String> messages) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.message, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'メッセージリスト',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${index + 1}.',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          messages[index],
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicalInfoCard(String vectorStoreId) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.storage, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  '技術情報',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vector Store ID:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vectorStoreId,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}