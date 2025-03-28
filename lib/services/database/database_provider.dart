/*
*
* Database provider
*
*
* Used to separate the management of firestore data in the way it is displayed on the UI
*
* - the database service takes care of managing the data of the bdd
* - the database provider organizes and displays the data
*
* ca makes the code adaptable, readable , easy to test, clean and on.
*
* we choose to evolve the backend, the front end interacting with this provider and not with the live service
* only service interactions will have to be evaluated ___ provider simplifying transition and maintenance
*
* */

import 'package:flutter/foundation.dart';
import 'package:messagerie_instantanee/models/conversation.dart';
import '../../models/message.dart';
import '../../models/user.dart';
import '../auth/auth_service.dart';
import 'database_service.dart';

class DatabaseProvider extends ChangeNotifier {

  // on recuperer la bdd et l'auth

  final _auth = AuthService();
  final _db = DatabaseService();


  // on recupere le profil utilisateur grace a luid
  Future<UserProfile?> userProfile(String uid) => _db.getUserFromFirebase(uid);
  // Maj de la Bio
  Future<void> updateBio(String bio) => _db.updateUserBioFirebase(bio);


  /*
  * Conversations
  * */

  // Listing local Conversations and Messages
  List<Conversation> _allConversations = [];
  List<Message> _allMessages = [];

  // get all the local conversations and Messages
  List<Conversation> get allConversations => _allConversations;

  List<Message> get allMessages => _allMessages;

  // Get all the conversation of the user
  Future<void> loadAllUserConversations() async {
    String? uid = _auth.getCurrentUid();
    final allConversations = await _db.getAllUserConversationsFromFirebase(uid);

    // Local saving
    _allConversations = allConversations;
    // Update UI
    notifyListeners();
  }

  // Send a message
  Future<void> sendMessage(String receiverId, String content) async {
    // Sending the message only in firebase
    await _db.sendMessageInFirebase(receiverId, content);

    // Reload conversations and messages
    await loadAllUserConversations();

    String conversationId = _generateConversationId(
        _auth.getCurrentUid(), receiverId);
    await loadMessageinConversation(conversationId);
  }

  // delete a message
  // Future<void> deleteMessage(String messageId) async {
  //   try {
  //   // on poste le message que firebase
  //   await _db.deleteMessageFromFirebase(messageId);
  //
  //   await loadAllUserConversations();
  //   } catch (e) {
  //     print("Erreur lors de la suppression du message : $e");
  //   }
  // }

  Map<String, Stream<List<Message>>> _conversationStreams = {};
  Stream<List<Message>> getConversationMessagesStream(String conversationId) {
    // If stream doesn't exist for this conversation, create it
    if (!_conversationStreams.containsKey(conversationId)) {
      _conversationStreams[conversationId] = _db.streamMessagesInConversation(conversationId);
    }
    return _conversationStreams[conversationId]!;
  }

  Future<void> loadMessageinConversation(String conversationId) async {
    _allMessages = await _db.getAllMessageInConversationFromFirebase(conversationId);
    notifyListeners();
  }


  String _generateConversationId(String uid1, String uid2) {
    List<String> participants = [uid1, uid2]..sort();
    return participants.join("_");
  }

  //Likess
  Future<void> toggleLikeMessage(String messageId) async {
    try {
      // Toggle like in Firebase
      await _db.toggleLikeMessageInFirebase(messageId);

      // Reload messages to update the UI
      String? conversationId = _allMessages.firstWhere((message) => message.id == messageId).conversationId;
      await loadMessageinConversation(conversationId);
    } catch (e) {
      print(e);
    }
  }

  // Friendss

  Future<bool> sendFriendRequest(String receiverId) async {
    bool result = await _db.sendFriendRequestInFirebase(receiverId);
    notifyListeners();
    return result;
  }

  Future<bool> acceptFriendRequest(String senderId) async {
    bool result = await _db.acceptFriendRequestInFirebase(senderId);
    notifyListeners();
    return result;
  }

  Future<bool> rejectFriendRequest(String senderId) async {
    bool result = await _db.rejectFriendRequestInFirebase(senderId);
    notifyListeners();
    return result;
  }

  Future<bool> removeFriend(String friendId) async {
    bool result = await _db.removeFriendInFirebase(friendId);
    notifyListeners();
    return result;
  }

  Future<List<UserProfile>> getFriends() async {
    return await _db.getFriendsInFirebase();
  }

  Future<List<UserProfile>> getPendingFriendRequests() async {
    return await _db.getPendingFriendRequestsInFirebase();
  }
}