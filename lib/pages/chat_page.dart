import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/my_message_bubble.dart';
import '../services/database/database_provider.dart';
import '../services/auth/auth_service.dart';  // Import AuthService

class ChatPage extends StatefulWidget {
  final String conversationId;
  final String recipientName;

  const ChatPage({
    super.key,
    required this.conversationId,
    required this.recipientName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load messages for this conversation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DatabaseProvider>(context, listen: false)
          .loadMessageinConversation(widget.conversationId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    // Extract the recipient ID from the conversation ID
    final parts = widget.conversationId.split("_");
    final currentUserId = AuthService().getCurrentUid();
    final recipientId = parts[0] == currentUserId ? parts[1] : parts[0];

    await Provider.of<DatabaseProvider>(context, listen: false)
        .sendMessage(recipientId, _messageController.text.trim());

    _messageController.clear();

    // Scroll to the bottom after sending a message
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = AuthService().getCurrentUid();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipientName),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // TODO: Show conversation info
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: Consumer<DatabaseProvider>(
              builder: (context, databaseProvider, child) {
                final messages = databaseProvider.allMessages;

                if (messages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet'),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true, // Display latest messages at the bottom
                  padding: const EdgeInsets.all(8.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMyMessage = message.uid == currentUserId;

                    return MessageBubble(
                      message: message,
                      isMyMessage: isMyMessage,
                    );
                  },
                );
              },
            ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                // Message Input Field
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),

                // Send Button
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Rest of the code remains the same as in the previous implementation