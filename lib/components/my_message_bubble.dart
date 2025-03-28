import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helper/time_formatter.dart';
import '../models/message.dart';
import '../services/database/database_provider.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMyMessage;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    final theme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Align(
        alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: isMyMessage ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMyMessage)
                Text(
                  message.username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              Text(message.content,
                style: TextStyle(
                  color: isMyMessage ? Theme.of(context).colorScheme.inversePrimary : Theme.of(context).colorScheme.inversePrimary,
                ),),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatTimestamp(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      provider.toggleLikeMessage(message.id);
                    },
                    child: Icon(
                      message.isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 16,
                      color: message.isLiked ? Theme.of(context).colorScheme.secondaryContainer : Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  // Maybe later
                  // if (isMyMessage)
                  //   GestureDetector(
                  //     onTap: () {
                  //       provider.deleteMessage(message.id);
                  //     },
                  //     child: const Icon(
                  //       Icons.delete_outline,
                  //       size: 16,
                  //       color: Colors.grey,
                  //     ),
                  //   ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
