import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final Timestamp lastMessageTimestamp;
  final String recipientName;  // This is the name of the other user in the conversation

  Conversation({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    required this.recipientName,
  });

  // Convertir un document Firestore en objet Conversation
  factory Conversation.fromDocument(DocumentSnapshot doc) {
    return Conversation(
      id: doc.id,
      participants: List<String>.from(doc['participants']),
      lastMessage: doc['lastMessage'],
      lastMessageTimestamp: doc['lastMessageTimestamp'],
      recipientName: doc['recipientName'] ?? 'Unknown',  // Use Unknown if recipientName doesn't exist
    );
  }

  // Convertir un objet Conversation en document Firestore
  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTimestamp': lastMessageTimestamp,
      'recipientName': recipientName,
    };
  }
}