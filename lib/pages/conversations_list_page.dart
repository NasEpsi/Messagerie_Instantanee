import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helper/time_formatter.dart';
import '../models/conversation.dart';
import '../services/database/database_provider.dart';
import '../services/auth/auth_service.dart';
import 'chat_page.dart';
import 'profile_page.dart';

class ConversationListPage extends StatefulWidget {
  const ConversationListPage({super.key});

  @override
  State<ConversationListPage> createState() => _ConversationListPageState();
}

class _ConversationListPageState extends State<ConversationListPage> {
  @override
  // Load conversations when the page is initialized
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DatabaseProvider>(context, listen: false)
          .loadAllUserConversations();
    });
  }

  void _navigateToCurrentUserProfile() {
    final currentUserId = AuthService().getCurrentUid();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          uid: currentUserId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Vos conversations',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Theme.of(context).colorScheme.primary, size: 50,),
            onPressed: _navigateToCurrentUserProfile,
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      body: Consumer<DatabaseProvider>(
        builder: (context, databaseProvider, child) {
          final conversations = databaseProvider.allConversations;

          if (conversations.isEmpty) {
            return Center(
              child: Text('No conversations yet',
                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
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
      leading: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(
                uid: conversation.participants.firstWhere(
                  (uid) => uid != AuthService().getCurrentUid(),
                ),
              ),
            ),
          );
        },
        child: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.inverseSurface,
          child: Text(conversation.recipientName[0].toUpperCase(),
            style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
          ),
        ),
      ),
      title: Text(
        conversation.recipientName,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.inverseSurface,
          fontSize: 19,
        ),      ),
      subtitle: Text(
        conversation.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 23
        ),
      ),
      trailing: Text(
        formattedTime,
        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 15),
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
