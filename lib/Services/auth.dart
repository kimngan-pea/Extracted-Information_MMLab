import 'package:extracted_information/Services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:extracted_information/Models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //create user obj based on FirebaseUser
  Users? _userFromFirebaseUser(User? user) {
    return user != null ? Users(uid: user.uid) : null;
  }

  //auth change user stream
  Stream<Users?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // //sign in anonymous
  // Future signInAnon() async {
  //   try {
  //     UserCredential result = await _auth.signInAnonymously();
  //     User? user = result.user;
  //     return user;
  //   } catch (e) {
  //     print(e.toString());
  //     return null;
  //   }
  // }

  //register with email & password
  Future registerWithEmailAndPassword(String email, String password, BuildContext context) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      //create a new document for the user with uid
      if (user != null) {
        // Store the user's uid in the UserProvider
        Provider.of<UserProvider>(context, listen: false).setUserId(user.uid);
        print("User registered with UID: ${user.uid}");
      }
      return _userFromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'email-already-in-use';
      } else if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided.';
      } else {
        return null;
      }
    } catch (e) {
      print(e.toString());
      return e;
    }
  }

  //sign in with email & password
  Future signInWithEmailAndPassword(String email, String password, BuildContext context) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      //create a new document for the user with uid
      if (user != null) {
        // Store the user's uid in the UserProvider
        Provider.of<UserProvider>(context, listen: false).setUserId(user.uid);
        print("User registered with UID: ${user.uid}");
      }
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
