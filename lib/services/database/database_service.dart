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
import '../auth/auth_service.dart';

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
      bio: '',
    );

    // converting the user in a map in order to save it in the firestore

    final userMap = user.toMap();

    // saving in the database
    await _db.collection('Users').doc(uid).set(userMap);
  }

  // Mettre a jour la bio
  Future<void> updateUserBioFirebase(String bio) async {
    // on recup id
    String uid = AuthService().getCurrentUid();

    // on le met met a jour dans firebase
    try {
      await _db.collection("Users").doc(uid).update({"bio": bio});
    } catch (e) {
      print(e);
    }
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

      // Check if users are friends
      if (!currentUser.friends.contains(receiverId) ||
          !receiverUser.friends.contains(uid)) {
        throw Exception("You can only message your friends");
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

  Stream<List<Message>> streamMessagesInConversation(String conversationId) {
    return _db
        .collection("Messages")
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Message.fromDocument(doc)).toList()
    );
  }

// Get zll user you can chat with
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
  //Get all Message of a conversation with someone
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

  // FRIENDSS

// Send a friend request
  Future<bool> sendFriendRequestInFirebase(String receiverId) async {
    try {
      String? currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return false;

      DocumentSnapshot receiverDoc = await _db.collection("Users").doc(receiverId).get();
      UserProfile receiverUser = UserProfile.fromDocument(receiverDoc);

      // Check if already friends or request already sent
      if (receiverUser.friends.contains(currentUserId) ||
          receiverUser.friendRequests.contains(currentUserId)) {
        return false;
      }

      // Add friend request to receiver's document
      await _db.collection("Users").doc(receiverId).update({
        'friendRequests': FieldValue.arrayUnion([currentUserId]),
      });

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // Accept a friend request
  Future<bool> acceptFriendRequestInFirebase(String senderId) async {
    try {
      String? currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return false;

      // Update current user's document
      await _db.collection("Users").doc(currentUserId).update({
        'friendRequests': FieldValue.arrayRemove([senderId]),
        'friends': FieldValue.arrayUnion([senderId]),
      });

      // Update sender's document
      await _db.collection("Users").doc(senderId).update({
        'friends': FieldValue.arrayUnion([currentUserId]),
      });

      return true;
    } catch (e) {
      print("Error accepting friend request: $e");
      return false;
    }
  }

  // Reject a friend request
  Future<bool> rejectFriendRequestInFirebase(String senderId) async {
    try {
      String? currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return false;

      await _db.collection("Users").doc(currentUserId).update({
        'friendRequests': FieldValue.arrayRemove([senderId]),
      });

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // Remove a friend
  Future<bool> removeFriendInFirebase(String friendId) async {
    try {
      String? currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return false;

      // Remove friend from current user's friend list
      await _db.collection("Users").doc(currentUserId).update({
        'friends': FieldValue.arrayRemove([friendId]),
      });

      // Remove current user from friend's friend list
      await _db.collection("Users").doc(friendId).update({
        'friends': FieldValue.arrayRemove([currentUserId]),
      });

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // Get friends of the current user
  Future<List<UserProfile>> getFriendsInFirebase() async {
    try {
      String? currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return [];

      DocumentSnapshot userDoc = await _db.collection("Users").doc(currentUserId).get();
      UserProfile currentUser = UserProfile.fromDocument(userDoc);

      // Fetch friend profiles
      List<Future<UserProfile?>> friendFutures = currentUser.friends.map((friendId) async {
        return await getUserFromFirebase(friendId);
      }).toList();

      List<UserProfile> friends = (await Future.wait(friendFutures)).whereType<UserProfile>().toList();
      return friends;
    } catch (e) {
      print(e);
      return [];
    }
  }

  // Get pending friend requests
  Future<List<UserProfile>> getPendingFriendRequestsInFirebase() async {
    try {
      String? currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return [];

      DocumentSnapshot userDoc = await _db.collection("Users").doc(currentUserId).get();
      UserProfile currentUser = UserProfile.fromDocument(userDoc);

      // Fetch friend request sender profiles
      List<Future<UserProfile?>> requestFutures = currentUser.friendRequests.map((senderId) async {
        return await getUserFromFirebase(senderId);
      }).toList();

      List<UserProfile> friendRequests = (await Future.wait(requestFutures)).whereType<UserProfile>().toList();
      return friendRequests;
    } catch (e) {
      print("Error fetching friend requests: $e");
      return [];
    }
  }
}