import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawtracker/models/pet.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //get current user id
  final user = FirebaseAuth.instance.currentUser;
  Future<String> addPet(
    String uid,
    String petName,
    String ownerName,
    String petType,
    String petBreed,
    String petAge,
    String petGender,
    String petBirthdate,
    String petHome,
    double petHomeLatitude,
    double petHomeLongitude,
    int fencePerimeter,
  ) async {
    // asking uid here because we dont want to make extra calls to firebase auth when we can just get from our state management
    String res = "Some error occurred";
    try {
      // String photoUrl =
      //     await StorageMethods().uploadImageToStorage('posts', file, true);
      String petId = const Uuid().v1(); // creates unique id based on time
      Pet pet = Pet(
        uid: uid,
        petId: petId,
        petName: petName,
        ownerName: ownerName,
        petType: petType,
        petBreed: petBreed,
        petAge: petAge,
        petGender: petGender,
        petBirthdate: petBirthdate,
        petHome: petHome,
        petHomeLatitude: petHomeLatitude,
        petHomeLongitude: petHomeLongitude,
        fencePerimeter: fencePerimeter,
      );
      _firestore.collection('pets').doc(petId).set(pet.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  //update pet
  Future<String> updatePet(
    String uid,
    String petId,
    String petName,
    String ownerName,
    String petType,
    String petBreed,
    String petAge,
    String petGender,
    String petBirthdate,
    String petHome,
    double petHomeLatitude,
    double petHomeLongitude,
    int fencePerimeter,
  ) async {
    // asking uid here because we dont want to make extra calls to firebase auth when we can just get from our state management
    String res = "Some error occurred";
    try {
      // String photoUrl =
      //     await StorageMethods().uploadImageToStorage('posts', file, true);
      Pet pet = Pet(
        uid: uid,
        petId: petId,
        petName: petName,
        ownerName: ownerName,
        petType: petType,
        petBreed: petBreed,
        petAge: petAge,
        petGender: petGender,
        petBirthdate: petBirthdate,
        petHome: petHome,
        petHomeLatitude: petHomeLatitude,
        petHomeLongitude: petHomeLongitude,
        fencePerimeter: fencePerimeter,
      );
      _firestore.collection('pets').doc(petId).update(pet.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
