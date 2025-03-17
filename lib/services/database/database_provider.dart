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
import '../../models/user.dart';
import '../auth/auth_service.dart';
import 'database_service.dart';

class DatabaseProvider extends ChangeNotifier {

  // on recuperer la bdd et l'auth

  final _auth = AuthService();
  final _db = DatabaseService();

  // on recupere le profil utilisateur grace a luid
  Future<UserProfile?> userProfile(String uid) => _db.getUserFromFirebase(uid);
}