/*
*
* Service who will handle all the data from and to firestore
*
* ----------------------------------------------------------
*
* - Profil user
* - Post
* - likes
* - comments
* - modération
* - Suivre
*
* */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:messagerie_instantanee/models/message.dart';

import '../../models/conversation.dart';
import '../../models/user.dart';

class DatabaseService {
  // get an instance of firestore
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  /*
  * User Profile
  * When creating an account, we will save the data in the database to display it on the profile
  * */

  // Saving User Data
  Future<void> saveUserInfoInFirebase(
      {required String name, email, username}) async {
    // gets uid
    String uid = _auth.currentUser!.uid;

    // username = whats before the @ in email
    String username = email.split('@')[0];

    // Create userProfile
    UserProfile user = UserProfile(
      uid: uid,
      name: name,
      email: email,
      username: username,
    );

    // converting the user in a map in order to save it in the firestore

    final userMap = user.toMap();

    // saving in the database
    await _db.collection('Users').doc(uid).set(userMap);
  }

  // Recuperer les donnes utilisateur
  Future<UserProfile?> getUserFromFirebase(String uid) async {
    try {
      DocumentSnapshot userDoc = await _db.collection("Users").doc(uid).get();
      return UserProfile.fromDocument(userDoc);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<UserProfile>> getAllUsers() async {
    try {
      // Get the current user's ID to exclude them from the list
      String? currentUserId = _auth.currentUser?.uid;

      QuerySnapshot snapshot = await _db
          .collection("Users")
          .where('uid', isNotEqualTo: currentUserId)
          .get();

      return snapshot.docs
          .map((doc) => UserProfile.fromDocument(doc))
          .toList();
    } catch (e) {
      print("Error fetching users: $e");
      return [];
    }
  }

  // Send Message in firebase
  Future<void> sendMessageInFirebase(String receiverId, String content) async {
    try {
      String uid = _auth.currentUser!.uid;
      UserProfile? currentUser = await getUserFromFirebase(uid);
      UserProfile? receiverUser = await getUserFromFirebase(receiverId);

      if (currentUser == null || receiverUser == null) {
        print("User not found");
        return;
      }

      //create an id for the conversation
      List<String> participants = [uid, receiverId]..sort();
      String conversationId = participants.join("_"); // uid1_uid2

      // Creating the message
      Message newMessage = Message(
        id: '',
        uid: uid,
        username: currentUser.username,
        content: content,
        timestamp: Timestamp.now(),
        conversationId: conversationId,
      );

      // saving message in firestore
      await _db.collection("Messages").add(newMessage.toMap());

      // verify if the conversation exists
      DocumentSnapshot conversationDoc =
      await _db.collection("Conversations").doc(conversationId).get();

      if (conversationDoc.exists) {
        // Update the conversation if it exists
        await _db.collection("Conversations").doc(conversationId).update({
          'lastMessage': content,
          'lastMessageTimestamp': Timestamp.now(),
        });
      } else {
        // if there is no conversation between the two user, create one
        Conversation newConversation = Conversation(
          id: conversationId,
          participants: participants,
          lastMessage: content,
          lastMessageTimestamp: Timestamp.now(),
          recipientName: receiverUser.username,
        );

        await _db
            .collection("Conversations")
            .doc(conversationId)
            .set(newConversation.toMap());
      }
    } catch (e) {
      print(e);
    }
  }

// Update the getAllUserConversationsFromFirebase method to handle recipientName
  Future<List<Conversation>> getAllUserConversationsFromFirebase(String uid) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection("Conversations")
          .where('participants', arrayContains: uid)
          .orderBy('lastMessageTimestamp', descending: true)
          .get();

      List<Conversation> conversations = [];

      for (var doc in snapshot.docs) {
        Conversation conversation = Conversation.fromDocument(doc);

        // Find the other participant's ID
        String otherUid = conversation.participants.firstWhere((id) => id != uid);

        // Get the other participant's profile
        UserProfile? otherUser = await getUserFromFirebase(otherUid);

        // Update the recipientName if needed
        if (otherUser != null && (conversation.recipientName == 'Unknown' || conversation.recipientName.isEmpty)) {
          await _db.collection("Conversations").doc(conversation.id).update({
            'recipientName': otherUser.username,
          });
          conversation = Conversation(
            id: conversation.id,
            participants: conversation.participants,
            lastMessage: conversation.lastMessage,
            lastMessageTimestamp: conversation.lastMessageTimestamp,
            recipientName: otherUser.username,
          );
        }

        conversations.add(conversation);
      }

      return conversations;
    } catch (e) {
      print(e);
      return [];
    }
  }
  //Get all Message
  Future<List<Message>> getAllMessageInConversationFromFirebase(
      String conversationId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection("Messages")
          .where('conversationId', isEqualTo: conversationId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => Message.fromDocument(doc)).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  //LIKESSS

  Future<void> toggleLikeMessageInFirebase(String messageId) async {
    try {
      // Get the current message
      DocumentSnapshot messageDoc = await _db.collection('Messages').doc(messageId).get();

      // Get the current like status
      bool isCurrentlyLiked = messageDoc['isLiked'] ?? false;

      // Toggle the like status
      await _db.collection('Messages').doc(messageId).update({
        'isLiked': !isCurrentlyLiked,
      });
    } catch (e) {
      print(e);
    }
  }
}
