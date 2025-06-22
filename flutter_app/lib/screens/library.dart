import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/local_storage.dart';
import '../models/person.dart';
import 'dart:ui';
import 'b.dart';
import 'character_detail.dart';

class Library extends StatefulWidget {
  const Library({super.key});

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> _characters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final events = await LocalStorage.getEvents();
      final characters = await LocalStorage.getCharacters();

      setState(() {
        _events = events;
        _characters = characters;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('データの読み込みに失敗しました: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('記録ライブラリ'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.event_note), text: 'イベント'),
            Tab(icon: Icon(Icons.people), text: 'キャラクター'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildEventsTab(),
                _buildCharactersTab(),
              ],
            ),
    );
  }

  Widget _buildEventsTab() {
    if (_events.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'まだイベントが記録されていません',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        final basicData = event['basicData'] as Map<String, dynamic>;
        final emotionData = event['emotionData'] as Map<String, dynamic>;
        final timestamp = DateTime.parse(event['timestamp']);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${timestamp.year}/${timestamp.month}/${timestamp.day} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteEvent(event['id']),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  basicData['what'] ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildBasicDataRow('誰が', basicData['who']),
                _buildBasicDataRow('いつ', basicData['when']),
                _buildBasicDataRow('どこで', basicData['where']),
                _buildBasicDataRow('なぜ', basicData['why']),
                _buildBasicDataRow('どのように', basicData['how']),
                const SizedBox(height: 12),
                const Text(
                  '感情レベル',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildEmotionBar('喜', emotionData['joy']?.toDouble() ?? 0, Colors.orange),
                _buildEmotionBar('怒', emotionData['anger']?.toDouble() ?? 0, Colors.red),
                _buildEmotionBar('哀', emotionData['sadness']?.toDouble() ?? 0, Colors.blue),
                _buildEmotionBar('楽', emotionData['pleasure']?.toDouble() ?? 0, Colors.green),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBasicDataRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value ?? ''),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionBar(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: Colors.grey.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 30,
            child: Text(
              '${value.toInt()}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharactersTab() {
    if (_characters.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'まだキャラクターが作成されていません',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _characters.length,
      itemBuilder: (context, index) {
        final character = _characters[index];
        final timestamp = DateTime.parse(character['timestamp']);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Color(character['color'] ?? Colors.teal.value),
              radius: 30,
              child: const Icon(Icons.person, color: Colors.white, size: 32),
            ),
            title: Text(
              character['name'] ?? 'Unknown',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '作成日: ${timestamp.year}/${timestamp.month}/${timestamp.day}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  'メッセージ数: ${(character['messages'] as List?)?.length ?? 0}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.info, color: Colors.green),
                  onPressed: () => _openCharacterDetail(character),
                  tooltip: '詳細を見る',
                ),
                IconButton(
                  icon: const Icon(Icons.chat, color: Colors.blue),
                  onPressed: () => _openCharacterChat(character),
                  tooltip: '会話を開始',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteCharacter(character['id']),
                  tooltip: '削除',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openCharacterDetail(Map<String, dynamic> characterData) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CharacterDetailScreen(
          characterData: characterData,
        ),
      ),
    );
  }

  void _openCharacterChat(Map<String, dynamic> characterData) {
    // カフェ画面に遷移（bottomNavigationで保存されたキャラクター全体を表示）
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => B()),
    );
  }

  void _deleteEvent(String eventId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: const Text('このイベントを削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await LocalStorage.deleteEvent(eventId);
              _loadData();
            },
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteCharacter(String characterId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: const Text('このキャラクターを削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await LocalStorage.deleteCharacter(characterId);
              _loadData();
            },
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}