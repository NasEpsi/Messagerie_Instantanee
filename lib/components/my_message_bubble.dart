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
            color: isMyMessage ? Colors.blue[100] : Colors.grey[200],
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
                    color: Colors.blue[800],
                  ),
                ),
              Text(message.content),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatTimestamp(message.timestamp),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
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
                      color: message.isLiked ? Colors.red : Colors.grey,
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
