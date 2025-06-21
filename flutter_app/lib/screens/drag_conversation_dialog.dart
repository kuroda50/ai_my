import 'package:flutter/material.dart';
import '../models/person.dart';
import '../widgets/ai_conversation_dialog.dart';

class DragConversationDialog extends StatefulWidget {
  final Person user;
  final Person otherPerson;
  final VoidCallback onClose;

  const DragConversationDialog({
    super.key,
    required this.user,
    required this.otherPerson,
    required this.onClose,
  });

  @override
  State<DragConversationDialog> createState() => _DragConversationDialogState();
}

class _DragConversationDialogState extends State<DragConversationDialog>
    with TickerProviderStateMixin {
  late AnimationController _dialogController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  
  List<String> conversation = [];
  int currentMessageIndex = 0;
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
    
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  void _startConversation() {
    // Check if this is an AI-generated character with vector store
    if (widget.otherPerson.isUser && 
        widget.otherPerson.aiCharacterSettings != null && 
        widget.otherPerson.vectorStoreId != null) {
      // Close this dialog and open AI conversation dialog
      widget.onClose();
      _showAIConversationDialog();
      return;
    }
    
    if (widget.otherPerson.isUser && widget.otherPerson.complexData != null) {
      // 新しい自分との会話の場合
      conversation.add('${widget.otherPerson.name}: こんにちは、私はあなたの新しい一面です。');
      conversation.add('${widget.otherPerson.name}: 私の抱えているコンプレックスについて話しましょう。');
    } else {
      // 通常の会話
      conversation.add('${widget.otherPerson.name}: ${widget.otherPerson.messages[0]}');
    }
    setState(() {});
  }

  void _showAIConversationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AIConversationDialog(
        user: widget.user,
        aiCharacter: widget.otherPerson,
        onClose: () {
          Navigator.of(context).pop();
          // Return to the main screen
          widget.onClose();
        },
      ),
    );
  }

  void _addResponse(String response) {
    if (response.trim().isEmpty) return;
    
    setState(() {
      conversation.add('${widget.user.name}: $response');
      currentMessageIndex++;
      
      // 新しい自分との会話の場合は特別な応答
      if (widget.otherPerson.isUser && widget.otherPerson.complexData != null) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              final responses = [
                'そうですね、私たちはお互いを理解し合うことが大切です。',
                'このコンプレックスは私たちの成長の糧になると思います。',
                '一緒に向き合っていきましょう。',
              ];
              final randomResponse = responses[currentMessageIndex % responses.length];
              conversation.add('${widget.otherPerson.name}: $randomResponse');
            });
          }
        });
      } else if (currentMessageIndex < widget.otherPerson.messages.length) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              conversation.add('${widget.otherPerson.name}: ${widget.otherPerson.messages[currentMessageIndex]}');
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
                    // アバター表示エリア
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [widget.user.color, widget.otherPerson.color],
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
                              // 左側：現在の自分
                              Expanded(
                                child: Column(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: widget.user.color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 4,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.face,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        widget.user.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: widget.user.color,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // 中央：VS表示
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  '対話',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // 右側：新しい自分
                              Expanded(
                                child: Column(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: widget.otherPerson.color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 4,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        widget.otherPerson.isUser ? Icons.psychology : Icons.person,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        widget.otherPerson.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: widget.otherPerson.color,
                                        ),
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
                                  final isUser = message.startsWith(widget.user.name);
                                  
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
                                                  : widget.otherPerson.color.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isUser
                                                    ? Colors.blue.withOpacity(0.3)
                                                    : widget.otherPerson.color.withOpacity(0.3),
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
                                            color: widget.otherPerson.color.withOpacity(0.3),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(24),
                                          borderSide: BorderSide(
                                            color: widget.otherPerson.color,
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
                                      color: widget.otherPerson.color,
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