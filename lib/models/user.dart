/*
*
* models of a user
*
* -----------------------------------------
*
* A user is made with
*
*uid
* name
* email
* username
* pfp
*
* */

import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String username;
  final String bio;
  final List<String> friends;
  final List<String> friendRequests;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.username,
    required this.bio,
    this.friends = const [],
    this.friendRequests = const [],
  });

  // Converting a firestore file into a model user
  factory UserProfile.fromDocument(DocumentSnapshot doc) {
    return UserProfile(
      uid: doc['uid'],
      name: doc['name'],
      email: doc['email'],
      username: doc['username'],
      bio: doc['bio'],
      friends: List<String>.from(doc['friends'] ?? []),
      friendRequests: List<String>.from(doc['friendRequests'] ?? []),
    );
  }

  // Converting a model user into a firestore file
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'username': username,
      'bio':bio,
      'friends': friends,
      'friendRequests': friendRequests,
    };
  }

  // check if the user is friend with another user
  bool isFriendsWith(String otherUid) {
    return friends.contains(otherUid);
  }

  // If there is others friend request
  bool hasFriendRequestFrom(String otherUid) {
    return friendRequests.contains(otherUid);
  }
}