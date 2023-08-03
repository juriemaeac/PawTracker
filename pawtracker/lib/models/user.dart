import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String firstName;
  final String lastName;
  final String uid;

  const User({
    required this.firstName,
    required this.lastName,
    required this.uid,
    required this.email,
  });

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      firstName: snapshot["firstName"],
      lastName: snapshot["lastName"],
      uid: snapshot["uid"],
      email: snapshot["email"],
    );
  }

  Map<String, dynamic> toJson() => {
        "firstName": firstName,
        "lastName": lastName,
        "uid": uid,
        "email": email,
      };
}
