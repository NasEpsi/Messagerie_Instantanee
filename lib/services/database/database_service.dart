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

import '../../models/user.dart';

class DatabaseService{
  // get an instance of firestore
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  /*
  * User Profile
  * When creating an account, we will save the data in the database to display it on the profile
  * */

  // Saving User Data
  Future<void> saveUserInfoInFirebase({required String name, email, username}) async {
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
}
