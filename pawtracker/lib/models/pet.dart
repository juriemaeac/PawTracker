import 'package:cloud_firestore/cloud_firestore.dart';

class Pet {
  final String uid;
  final String petId;
  final String petName;
  final String ownerName;
  final String petType;
  final String petBreed;
  final String petAge;
  final String petGender;
  final String petBirthdate;
  final String petHome;
  final double petHomeLatitude;
  final double petHomeLongitude;
  final int fencePerimeter;

  const Pet(
      {required this.uid,
      required this.petId,
      required this.petName,
      required this.ownerName,
      required this.petType,
      required this.petBreed,
      required this.petAge,
      required this.petGender,
      required this.petBirthdate,
      required this.petHome,
      required this.petHomeLatitude,
      required this.petHomeLongitude,
      required this.fencePerimeter});

  static Pet fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Pet(
        uid: snapshot['uid'],
        petId: snapshot['petId'],
        petName: snapshot['petName'],
        ownerName: snapshot['ownerName'],
        petType: snapshot['petType'],
        petBreed: snapshot['petBreed'],
        petAge: snapshot['petAge'],
        petGender: snapshot['petGender'],
        petBirthdate: snapshot['petBirthdate'],
        petHome: snapshot['petHome'],
        petHomeLatitude: snapshot['petHomeLatitude'],
        petHomeLongitude: snapshot['petHomeLongitude'],
        fencePerimeter: snapshot['fencePerimeter']);
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'petId': petId,
      'petName': petName,
      'ownerName': ownerName,
      'petType': petType,
      'petBreed': petBreed,
      'petAge': petAge,
      'petGender': petGender,
      'petBirthdate': petBirthdate,
      'petHome': petHome,
      'petHomeLatitude': petHomeLatitude,
      'petHomeLongitude': petHomeLongitude,
      'fencePerimeter': fencePerimeter
    };
  }
}
