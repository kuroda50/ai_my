import 'package:flutter/material.dart';
import '../models/person.dart';
import '../services/ai_service.dart';
import '../services/local_storage.dart';

class AIConversationDialog extends StatefulWidget {
  final Person user;
  final Person aiCharacter;
  final VoidCallback onClose;

  const AIConversationDialog({
    super.key,
    required this.user,
    required this.aiCharacter,
    required this.onClose,
  });

  @override
  State<AIConversationDialog> createState() => _AIConversationDialogState();
}

class _AIConversationDialogState extends State<AIConversationDialog>
    with TickerProviderStateMixin {
  late AnimationController _dialogController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  
  List<Map<String, String>> conversation = [];
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _isAIResponding = false;

  @override
  void initState() {
    super.initState();
    
    _dialogController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _dialogController,
      curve: Curves.elasticOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _dialogController,
      curve: Curves.easeOut,
    ));
    
    _dialogController.forward();
    _startConversation();
    
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  void _startConversation() {
    // Get the latest event to use as conversation starter
    _getLatestEvent().then((event) {
      if (event != null) {
        final greeting = _generateGreeting(event);
        setState(() {
          conversation.add({
            'sender': widget.aiCharacter.name,
            'message': greeting,
            'isUser': 'false',
          });
        });
      } else {
        _startConversationWithoutEvent();
      }
    });
  }

  void _startConversationWithoutEvent() {
    String greeting;
    if (widget.aiCharacter.messages.isNotEmpty) {
      greeting = _cleanMessage(widget.aiCharacter.messages.first);
    } else {
      greeting = 'こんにちは、私はあなたの新しい一面です。何について話したいですか？';
    }
    
    setState(() {
      conversation.add({
        'sender': widget.aiCharacter.name,
        'message': greeting,
        'isUser': 'false',
      });
    });
  }

  void _addMessage(String message, bool isUser) {
    setState(() {
      conversation.add({
        'sender': isUser ? widget.user.name : widget.aiCharacter.name,
        'message': message,
        'isUser': isUser.toString(),
      });
    });
    
    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final message = _textController.text.trim();
    if (message.isEmpty || _isAIResponding) return;

    // Add user message
    _addMessage(message, true);
    _textController.clear();

    // Show AI typing indicator
    setState(() {
      _isAIResponding = true;
    });

    try {
      // Call the AI service to get response
      final response = await AIService.startAIConversation(
        [widget.aiCharacter.vectorStoreId!],
        {
          'what': message,
          'where': 'カフェ',
          'when': '今',
          'who': widget.user.name,
          'why': '会話を続けるため',
          'how': '自然な対話を通じて'
        }
      );
      
      if (response != null && response['messages'] != null) {
        final messages = List<Map<String, dynamic>>.from(response['messages']);
        
        // Only display assistant messages (filter out system and user messages)
        for (final messageData in messages) {
          if (messageData['role'] == 'assistant' && messageData['content'] != null) {
            final cleanContent = _cleanMessage(messageData['content']);
            if (mounted) {
              _addMessage(cleanContent, false);
            }
            // Add a small delay between messages for better UX
            await Future.delayed(const Duration(milliseconds: 500));
          }
        }
      }
    } catch (e) {
      print('Error in AI conversation: $e');
      if (mounted) {
        _addMessage('すみません、少し調子が悪いみたいです。もう一度お話しできますか？', false);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAIResponding = false;
        });
      }
    }
  }

  Future<String> _generateAIResponse(String userMessage) async {
    // Get latest event for context-aware responses
    final latestEvent = await _getLatestEvent();
    
    // For demonstration, we'll use context-aware responses based on the character and event
    // In a real implementation, this would call the backend_ai RAG endpoint
    
    final responses = _getContextualResponses(userMessage, latestEvent);
    return responses[DateTime.now().millisecondsSinceEpoch % responses.length];
  }

  List<String> _getContextualResponses(String userMessage, Map<String, dynamic>? event) {
    final message = userMessage.toLowerCase();
    
    // Use character settings and complex data to provide contextual responses
    final characterData = widget.aiCharacter.aiCharacterSettings ?? '';
    final complexData = widget.aiCharacter.complexData ?? {};
    
    // Event-specific responses
    if (event != null) {
      final eventDescription = event['basicData']?['what'] ?? '';
      final eventWhere = event['basicData']?['where'] ?? '';
      final eventWhen = event['basicData']?['when'] ?? '';
      
      if (message.contains(eventDescription.toLowerCase()) || 
          message.contains('そのこと') || 
          message.contains('それ')) {
        return [
          '「$eventDescription」について、もう少し詳しく聞かせてもらえますか？',
          '「$eventDescription」の時の気持ち、とてもよく分かります。',
          '「$eventDescription」を通じて、何か新しい発見はありましたか？',
          '「$eventDescription」について、一緒に考えてみましょう。',
        ];
      }
      
      if (message.contains('場所') || message.contains('どこ')) {
        return [
          '「$eventWhere」での出来事でしたね。その場所での印象はどうでしたか？',
          '「$eventWhere」は特別な場所だったんですか？',
          '「$eventWhere」での経験、大切にしたいですね。',
        ];
      }
      
      if (message.contains('時') || message.contains('いつ')) {
        return [
          '「$eventWhen」の時の気持ち、今でも覚えていますか？',
          '「$eventWhen」の経験が、今のあなたに影響を与えているかもしれませんね。',
          '「$eventWhen」のことを振り返ってみて、どう感じますか？',
        ];
      }
    }
    
    if (message.contains('コンプレックス') || message.contains('悩み')) {
      return [
        'そのコンプレックスについて、もう少し詳しく聞かせてもらえますか？',
        '私も同じような悩みを抱えていたことがあります。一緒に考えてみましょう。',
        'その気持ち、とてもよく分かります。どんな時に特に強く感じますか？',
      ];
    }
    
    if (message.contains('どう思う') || message.contains('意見')) {
      return [
        '私は、あなたがとても頑張っていると思います。',
        'その状況なら、きっと誰でも同じように感じると思います。',
        'あなたの気持ちに寄り添いたいと思います。',
      ];
    }
    
    if (message.contains('ありがとう') || message.contains('感謝')) {
      return [
        'どういたしまして。お話しできて私も嬉しいです。',
        'こちらこそ、素直な気持ちを聞かせてくれてありがとうございます。',
        '一緒に成長していけそうですね。',
      ];
    }
    
    // Default responses based on character
    return [
      'そうですね、その気持ちとてもよく分かります。',
      'もう少し詳しく教えてもらえますか？',
      '私も同じような経験があります。',
      'その時のあなたの気持ちを聞かせてください。',
      '一緒に考えてみましょう。',
    ];
  }

  String _cleanMessage(String message) {
    // Remove role, user, assistant prefixes and clean up the message
    String cleaned = message;
    
    // Remove common prefixes
    cleaned = cleaned.replaceAll(RegExp(r'^(role|user|assistant|system):\s*', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'^<[^>]+>:\s*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'^\[[^\]]+\]:\s*'), '');
    
    // Remove extra whitespace
    cleaned = cleaned.trim();
    
    return cleaned;
  }

  Future<Map<String, dynamic>?> _getLatestEvent() async {
    try {
      final events = await LocalStorage.getEvents();
      if (events.isNotEmpty) {
        // 最新のイベントを取得（timestampでソート）
        events.sort((a, b) {
          final aTime = DateTime.parse(a['timestamp'] ?? '1970-01-01');
          final bTime = DateTime.parse(b['timestamp'] ?? '1970-01-01');
          return bTime.compareTo(aTime); // 降順（最新が先頭）
        });
        return events.first;
      }
    } catch (e) {
      print('Error getting latest event: $e');
    }
    return null;
  }

  String _generateGreeting(Map<String, dynamic> event) {
    final eventDescription = event['basicData']?['what'] ?? '最近の出来事';
    return 'こんにちは！最近の「$eventDescription」について、どう思いますか？一緒に話してみませんか？';
  }

  @override
  void dispose() {
    _dialogController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dialogController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with character info
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [widget.user.color, widget.aiCharacter.color],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: widget.user.color,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 3),
                                      ),
                                      child: const Icon(Icons.face, color: Colors.white, size: 30),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      widget.user.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Text(
                                'AI対話',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: widget.aiCharacter.color,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 3),
                                      ),
                                      child: const Icon(Icons.psychology, color: Colors.white, size: 30),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      widget.aiCharacter.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: widget.onClose,
                                icon: const Icon(Icons.close, color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Conversation area
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                controller: _scrollController,
                                itemCount: conversation.length + (_isAIResponding ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == conversation.length && _isAIResponding) {
                                    // Typing indicator
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: widget.aiCharacter.color.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation(widget.aiCharacter.color),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                const Text('考えています...'),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  
                                  final message = conversation[index];
                                  final isUser = message['isUser'] == 'true';
                                  
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      mainAxisAlignment: isUser
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: isUser
                                                  ? Colors.blue.withOpacity(0.1)
                                                  : widget.aiCharacter.color.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isUser
                                                    ? Colors.blue.withOpacity(0.3)
                                                    : widget.aiCharacter.color.withOpacity(0.3),
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: isUser
                                                  ? CrossAxisAlignment.end
                                                  : CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  message['sender']!,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: isUser ? Colors.blue : widget.aiCharacter.color,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  _cleanMessage(message['message']!),
                                                  style: const TextStyle(fontSize: 14),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Input area
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _textController,
                                      focusNode: _focusNode,
                                      enabled: !_isAIResponding,
                                      decoration: InputDecoration(
                                        hintText: _isAIResponding 
                                            ? 'AIが考えています...' 
                                            : 'メッセージを入力してください...',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(24),
                                          borderSide: BorderSide(
                                            color: widget.aiCharacter.color.withOpacity(0.3),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(24),
                                          borderSide: BorderSide(
                                            color: widget.aiCharacter.color,
                                            width: 2,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey.withOpacity(0.1),
                                      ),
                                      maxLines: null,
                                      textInputAction: TextInputAction.send,
                                      onSubmitted: (_) => _sendMessage(),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: _isAIResponding 
                                          ? Colors.grey 
                                          : widget.aiCharacter.color,
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      onPressed: _isAIResponding ? null : _sendMessage,
                                      icon: const Icon(
                                        Icons.send,
                                        color: Colors.white,
                                      ),
                                      iconSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}