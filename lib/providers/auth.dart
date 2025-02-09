import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  User? get user => _user;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      _user = result.user;
      notifyListeners();
      return _user;
    } catch (error) {
      String modifiedErrorMessage =
          error.toString().replaceAll("firebase_auth", "");
      Fluttertoast.showToast(
        msg: modifiedErrorMessage,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        fontSize: 16.0,
      );
      return null;
    }
  }

  Future registerWithEmailAndPassword(
      String email, String password, String fullName) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      _user = result.user;

      await FirebaseFirestore.instance.collection('users').doc(_user!.uid).set({
        'email': email,
        'username': fullName,
      });
      notifyListeners();
      return _user;
    } catch (error) {
      String modifiedErrorMessage =
          error.toString().replaceAll("firebase_auth", "");
      Fluttertoast.showToast(
        msg: modifiedErrorMessage,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        fontSize: 16.0,
      );
      return null;
    }
  }

  Future signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      notifyListeners();
    } catch (error) {
      print(error.toString());
      return null;
    }
  }
}
