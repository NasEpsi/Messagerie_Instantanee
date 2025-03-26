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

class UserProfile{
  final String uid;
  final String name;
  final String email;
  final String username;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.username,
  });

  // Converting a firestore file into a model user
  factory UserProfile.fromDocument(DocumentSnapshot doc){
    return UserProfile(
      uid: doc['uid'],
      name: doc['name'],
      email: doc['email'],
      username: doc['username'],

    );
  }
  // Converting a model user into a firestore file

  Map<String,dynamic> toMap(){
    return {
      'uid':uid,
      'name':name,
      'email':email,
      'username':username,
    };
  }
}