import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../helper/time_formatter.dart';
import '../models/conversation.dart';
import '../services/database/database_provider.dart';
import 'chat_page.dart';

class ConversationListPage extends StatefulWidget {
  const ConversationListPage({super.key});

  @override
  State<ConversationListPage> createState() => _ConversationListPageState();
}

class _ConversationListPageState extends State<ConversationListPage> {
  @override
  void initState() {
    super.initState();
    // Load conversations when the page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DatabaseProvider>(context, listen: false).loadAllUserConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // TODO: Navigate to profile page
            },
          ),
        ],
      ),
      body: Consumer<DatabaseProvider>(
        builder: (context, databaseProvider, child) {
          final conversations = databaseProvider.allConversations;

          if (conversations.isEmpty) {
            return const Center(
              child: Text('No conversations yet'),
            );
          }

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              return ConversationTile(conversation: conversation);
            },
          );
        },
      ),
      // We can add a FAB to create a new conversation later
    );
  }
}

class ConversationTile extends StatelessWidget {
  final Conversation conversation;

  const ConversationTile({
    super.key,
    required this.conversation,
  });

  @override
  Widget build(BuildContext context) {
    // Format the timestamp for display
    String formattedTime = formatTimestamp(conversation.lastMessageTimestamp);

    return ListTile(
      leading: CircleAvatar(
        // We can add profile picture here later
        child: Text(conversation.recipientName[0].toUpperCase()),
      ),
      title: Text(
        conversation.recipientName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        conversation.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        formattedTime,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              conversationId: conversation.id,
              recipientName: conversation.recipientName,
            ),
          ),
        );
      },
    );
  }
}