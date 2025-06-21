import 'package:flutter/material.dart';
import '../models/person.dart';

class NearbyConversationDialog extends StatefulWidget {
  final Person person1;
  final Person person2;
  final VoidCallback onClose;

  const NearbyConversationDialog({
    super.key,
    required this.person1,
    required this.person2,
    required this.onClose,
  });

  @override
  State<NearbyConversationDialog> createState() => _NearbyConversationDialogState();
}

class _NearbyConversationDialogState extends State<NearbyConversationDialog>
    with TickerProviderStateMixin {
  late AnimationController _dialogController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  
  List<String> conversation = [];
  int currentMessageIndex = 0;

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
    _startNearbyConversation();
  }

  void _startNearbyConversation() {
    conversation.add('${widget.person1.name}と${widget.person2.name}が近づいて会話を始めました...');
    setState(() {});
    
    _showConversationSequence();
  }
  
  void _showConversationSequence() {
    final allMessages = <String>[];
    
    // 会話のシーケンスを作成
    for (int i = 0; i < widget.person1.messages.length && i < widget.person2.messages.length; i++) {
      allMessages.add('${widget.person1.name}: ${widget.person1.messages[i]}');
      allMessages.add('${widget.person2.name}: ${widget.person2.messages[i]}');
    }
    
    // メッセージを順番に表示
    for (int i = 0; i < allMessages.length; i++) {
      Future.delayed(Duration(milliseconds: 1500 * (i + 1)), () {
        if (mounted) {
          setState(() {
            conversation.add(allMessages[i]);
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _dialogController.dispose();
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
                constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
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
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [widget.person1.color, widget.person2.color],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.people,
                              color: widget.person1.color,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${widget.person1.name} & ${widget.person2.name}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: widget.onClose,
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: conversation.length,
                                itemBuilder: (context, index) {
                                  final message = conversation[index];
                                  final isPerson1 = message.startsWith(widget.person1.name);
                                  final isPerson2 = message.startsWith(widget.person2.name);
                                  
                                  Color messageColor = Colors.grey;
                                  if (isPerson1) messageColor = widget.person1.color;
                                  if (isPerson2) messageColor = widget.person2.color;
                                  
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      mainAxisAlignment: isPerson2
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: messageColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: messageColor.withOpacity(0.3),
                                              ),
                                            ),
                                            child: Text(
                                              message,
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
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

class ConversationDialog extends StatefulWidget {
  final Person person;
  final VoidCallback onClose;

  const ConversationDialog({
    super.key,
    required this.person,
    required this.onClose,
  });

  @override
  State<ConversationDialog> createState() => _ConversationDialogState();
}

class _ConversationDialogState extends State<ConversationDialog>
    with TickerProviderStateMixin {
  late AnimationController _dialogController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  
  int currentMessageIndex = 0;
  List<String> conversation = [];
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

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
    
    // フォーカスを入力フィールドに設定
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  void _startConversation() {
    conversation.add('${widget.person.name}: ${widget.person.messages[0]}');
    setState(() {});
  }

  void _addResponse(String response) {
    if (response.trim().isEmpty) return;
    
    setState(() {
      conversation.add('あなた: $response');
      currentMessageIndex++;
      
      if (currentMessageIndex < widget.person.messages.length) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              conversation.add('${widget.person.name}: ${widget.person.messages[currentMessageIndex]}');
            });
          }
        });
      }
    });
    
    _textController.clear();
  }

  void _sendMessage() {
    final message = _textController.text.trim();
    if (message.isNotEmpty) {
      _addResponse(message);
    }
  }

  @override
  void dispose() {
    _dialogController.dispose();
    _textController.dispose();
    _focusNode.dispose();
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
                constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
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
                    // ヘッダー
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: widget.person.color,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              color: widget.person.color,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            widget.person.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: widget.onClose,
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    // 会話エリア
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: conversation.length,
                                itemBuilder: (context, index) {
                                  final message = conversation[index];
                                  final isUser = message.startsWith('あなた:');
                                  
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
                                                  : Colors.grey.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isUser
                                                    ? Colors.blue.withOpacity(0.3)
                                                    : widget.person.color.withOpacity(0.3),
                                              ),
                                            ),
                                            child: Text(
                                              message,
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            // メッセージ入力エリア
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _textController,
                                      focusNode: _focusNode,
                                      decoration: InputDecoration(
                                        hintText: 'メッセージを入力してください...',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(24),
                                          borderSide: BorderSide(
                                            color: widget.person.color.withOpacity(0.3),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(24),
                                          borderSide: BorderSide(
                                            color: widget.person.color,
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
                                      color: widget.person.color,
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      onPressed: _sendMessage,
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