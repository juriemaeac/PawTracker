import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:pawtracker/models/user.dart' as model;

class AuthMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // get user details
  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(documentSnapshot);
  }

  // Signing Up User
  Future<String> signUpUser({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required BuildContext context,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        // registering user in auth with email and password
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        model.User _user = model.User(
          firstName: firstName,
          lastName: lastName,
          uid: cred.user!.uid,
          email: email,
        );

        // adding user in our database
        await _firestore
            .collection("users")
            .doc(cred.user!.uid)
            .set(_user.toJson());

        res = "success";
      } else {
        res = "Please enter all the fields";
        return "Please enter all the fields";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        return 'The email is invalid.';
      } else {}

      print(e);
      return e.toString();
    }
    return res;
  }

  // logging in user
  Future<String> loginUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    String res = "Some error Occurred";
    try {
      // logging in user with email and password
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      res = "success";
    } on FirebaseAuthException catch (e) {
      //showSnackBar(context, e.message!);
      if (e.code == 'invalid-email') {
        return 'The email is invalid.';
      } else if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      } else {}

      print(e);
      return e.toString();
    }
    return res;
  }

  //EMAIL VERIFICATION
  // Future<void> sendEmailVerification(BuildContext context) async {
  //   try {
  //     _auth.currentUser!.sendEmailVerification();
  //   } on FirebaseAuthException catch (e) {
  //     showSnackBar(context, e.message!);
  //     print(e);
  //   }
  // }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
