import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/my_message_bubble.dart';
import '../models/message.dart';
import '../services/auth/auth_service.dart';
import '../services/database/database_provider.dart';

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
  late final TextEditingController _messageController;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();

    // Load initial messages for this specific conversation
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
        title: Text(
          widget.recipientName,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      body: Column(
        children: [
          Divider(
              indent: 25,
              endIndent: 25,
              color: Theme.of(context).colorScheme.primary),
          // Messages List
          Expanded(
            child: Consumer<DatabaseProvider>(
              builder: (context, databaseProvider, child) {
                return StreamBuilder<List<Message>>(
                  stream: databaseProvider
                      .getConversationMessagesStream(widget.conversationId),
                  builder: (context, snapshot) {
                    // Handle different snapshot states
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'Aucun message pour le moment',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      );
                    }

                    final messages = snapshot.data!;

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
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
                );
              },
            ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary,
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ecrivez un message',
                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.inversePrimary,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
