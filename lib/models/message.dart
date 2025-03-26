/*
*
* Model of a message
*
*
* ---------------------------------------------------
*
* a message need :
* id
* uid (person who sent )
* username
* content
* TimeStamp
* Conversation Id (Id of the conversation)
* Like button
* */

import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String uid;
  final String username;
  final String content;
  final Timestamp timestamp;
  final String conversationId;
  final bool isLiked;

  Message({
    required this.id,
    required this.uid,
    required this.username,
    required this.content,
    required this.timestamp,
    required this.conversationId,
    // False at first
    this.isLiked = false,
  });

  factory Message.fromDocument(DocumentSnapshot doc) {
    return Message(
      id: doc.id,
      uid: doc['uid'],
      username: doc['username'],
      content: doc['content'],
      timestamp: doc['timestamp'],
      conversationId: doc['conversationId'],
      // False if empty
      isLiked: doc['isLiked'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'content': content,
      'timestamp': timestamp,
      'conversationId': conversationId,
      'isLiked': isLiked,
    };
  }
}