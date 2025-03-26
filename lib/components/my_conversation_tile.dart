// components/conversation_tile.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/conversation.dart';

class ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return DateFormat('HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: Colors.blueGrey,
        child: Text(
          conversation.recipientName.isNotEmpty
              ? conversation.recipientName[0].toUpperCase()
              : '?',
          style: const TextStyle(color: Colors.white),
        ),
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
        _formatTimestamp(conversation.lastMessageTimestamp),
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
