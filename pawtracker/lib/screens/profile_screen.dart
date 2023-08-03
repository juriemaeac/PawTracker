import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:pawtracker/screens/add_profile_screen.dart';
import 'package:pawtracker/screens/edit_profile_screen.dart';
import 'package:pawtracker/utils/constants.dart';
import 'package:pawtracker/utils/global_variable.dart';
import 'package:pawtracker/widgets/snackbar.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  var userData = {};
  int petLen = 0;

  bool isLoading = false;
  String? ownerName;
  String? petName;
  String? petBreed;
  String? petAge;
  String? petType;
  String? petGender;
  String? petBirthdate;
  String? petHome;
  double? petHomeLatitude;
  double? petHomeLongitude;
  int? fencePerimeter;
  String? petHomeProfile;

  void petAddedChecker() {
    if (isPet == true) {
      isPetAdded = true;
    } else {
      isPetAdded = false;
    }
  }

  void getPets() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      var petSnap = await FirebaseFirestore.instance
          .collection('pets')
          .where('uid', isEqualTo: user!.uid)
          .get();

      // // get pet lENGTH
      petLen = petSnap.docs.length;
      if (petLen == 0) {
        isPetAdded = false;
      } else {
        isPetAdded = true;
      }
      userData = userSnap.data()!;
      setState(() {});
    } catch (e) {
      showSnackBar(
        context,
        e.toString(),
      );
    }
  }

  Future<void> getPetData() async {
    setState(() {
      isLoading = true;
    });
    var petSnap = await FirebaseFirestore.instance
        .collection('pets')
        .where('uid', isEqualTo: user!.uid)
        .get();
    setState(() {
      isLoading = false;
      ownerName = petSnap.docs[0]['ownerName'];
      petName = petSnap.docs[0]['petName'];
      petBreed = petSnap.docs[0]['petBreed'];
      petAge = petSnap.docs[0]['petAge'];
      petType = petSnap.docs[0]['petType'];
      petGender = petSnap.docs[0]['petGender'];
      petBirthdate = petSnap.docs[0]['petBirthdate'];
      petHomeProfile = petHomeAddressGlobal;
      if (petType == 'Dog') {
        isCat = false;
      } else if (petType == 'Cat') {
        isCat = true;
      } else {
        return;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getPets();
    getPetData();
    //_getHomeLocation();
  }

  @override
  Widget build(BuildContext context) {
    print("CALIBRATED: $isCalibrated");

    return isPetAdded
        ? Scaffold(
            backgroundColor: AppColors.pinkAccent,
            body: SafeArea(
              child: isLoading
                  ? Center(
                      child: Image(
                        image: const AssetImage(
                            'assets/images/paw_loading_pink.gif'),
                        gaplessPlayback: true,
                        height: MediaQuery.of(context).size.height / 5,
                        fit: BoxFit.fitHeight,
                      ),
                      // CircularProgressIndicator(
                      //   backgroundColor: AppColors.blue,
                      // ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 30,
                          right: 30,
                          left: 30,
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 160,
                              left: 40,
                              child: Transform(
                                transform: Matrix4.rotationZ(3.8),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 40,
                                  color: AppColors.white.withOpacity(0.4),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 200,
                              right: 15,
                              child: Transform(
                                transform: Matrix4.rotationZ(1.8),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 40,
                                  color: AppColors.white.withOpacity(0.4),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 250,
                              left: 20,
                              child: Container(
                                height: 20,
                                width: 20,
                                decoration: BoxDecoration(
                                  color: AppColors.white.withOpacity(0.4),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 120,
                              right: 40,
                              child: Transform(
                                transform: Matrix4.rotationZ(2.1),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 20,
                                  color: AppColors.white.withOpacity(0.4),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 150,
                              left: 140,
                              child: Transform(
                                transform: Matrix4.rotationZ(1),
                                child: Icon(
                                  Icons.pets_rounded,
                                  size: 20,
                                  color: AppColors.white.withOpacity(0.4),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 120,
                              left: 10,
                              child: Transform(
                                transform: Matrix4.rotationZ(1.3),
                                child: Container(
                                  height: 15,
                                  width: 15,
                                  decoration: BoxDecoration(
                                    color: AppColors.white.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.pets_rounded,
                                      color: AppColors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text('PawTracker',
                                        style: AppTextStyles.title1
                                            .copyWith(color: AppColors.white)),
                                  ],
                                ),
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height / 1.8,
                                  child: Stack(
                                    children: [
                                      Align(
                                        alignment: Alignment.topCenter,
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              2.5,
                                          child: isCat
                                              ? const Image(
                                                  image: AssetImage(
                                                      'assets/images/cat_wink.png'),
                                                )
                                              : const Image(
                                                  image: AssetImage(
                                                      'assets/images/dog_here.png'),
                                                ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          padding: const EdgeInsets.all(20),
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              4.5,
                                          decoration: const BoxDecoration(
                                            color: AppColors.white,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(20),
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                //color: Colors.amber,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    16,
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      //color: Colors.green,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              16,
                                                      child: FittedBox(
                                                        fit: BoxFit.fitHeight,
                                                        child: Icon(
                                                          Icons.pets_rounded,
                                                          color:
                                                              AppColors.black,
                                                          size: 60,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              16 /
                                                              1.8,
                                                          //color: Colors.blue,
                                                          child: FittedBox(
                                                            fit: BoxFit
                                                                .fitHeight,
                                                            child: Text(
                                                                petName
                                                                    .toString(),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: AppTextStyles
                                                                    .subHeadings2
                                                                    .copyWith(
                                                                        color: AppColors
                                                                            .black)),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              16 /
                                                              3.5,
                                                          child: FittedBox(
                                                            fit: BoxFit
                                                                .fitHeight,
                                                            child: Text(
                                                                petBreed
                                                                    .toString(),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: AppTextStyles
                                                                    .body1
                                                                    .copyWith(
                                                                        color: AppColors
                                                                            .grey)),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Divider(
                                                color: AppColors.greyAccentLine,
                                                thickness: 1,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            6,
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    decoration:
                                                        const BoxDecoration(
                                                      color:
                                                          AppColors.lightPurple,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(20),
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          petGender.toString(),
                                                          style: AppTextStyles
                                                              .body4
                                                              .copyWith(
                                                                  color: AppColors
                                                                      .white)),
                                                    ),
                                                  ),
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            7,
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    decoration:
                                                        const BoxDecoration(
                                                      color:
                                                          AppColors.lightGreen,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(20),
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          petType.toString(),
                                                          style: AppTextStyles
                                                              .body4
                                                              .copyWith(
                                                                  color: AppColors
                                                                      .white)),
                                                    ),
                                                  ),
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            7,
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: AppColors.lightRed,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(20),
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '${petAge}y/0',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: AppTextStyles
                                                            .body4
                                                            .copyWith(
                                                          color:
                                                              AppColors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            4,
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    decoration:
                                                        const BoxDecoration(
                                                      color:
                                                          AppColors.lightOrange,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(20),
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                          petBirthdate
                                                              .toString(),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: AppTextStyles
                                                              .body4
                                                              .copyWith(
                                                                  color: AppColors
                                                                      .white)),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Container(
                                                    //color: Colors.amber,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            16 /
                                                            3.5,
                                                    child: FittedBox(
                                                      fit: BoxFit.fitHeight,
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .person_rounded,
                                                            color:
                                                                AppColors.grey,
                                                            size: 15,
                                                          ),
                                                          const SizedBox(
                                                              width: 5),
                                                          Text(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              ownerName
                                                                  .toString(),
                                                              style: AppTextStyles
                                                                  .body1
                                                                  .copyWith(
                                                                      color: AppColors
                                                                          .grey)),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Container(
                                                    //color: Colors.blue,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            16 /
                                                            3.5,
                                                    child: FittedBox(
                                                      fit: BoxFit.fitHeight,
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.home_rounded,
                                                            color:
                                                                AppColors.grey,
                                                            size: 15,
                                                          ),
                                                          const SizedBox(
                                                              width: 5),
                                                          Text(
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            isCalibrated
                                                                ? petHomeAddressGlobal
                                                                    .toString()
                                                                : 'Home Address not calibrated',
                                                            style: AppTextStyles
                                                                .body1
                                                                .copyWith(
                                                                    color: AppColors
                                                                        .grey),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 20),
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height / 4.5,
                                  child: Stack(
                                    children: [
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          padding: const EdgeInsets.all(18),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              7.2,
                                          decoration: const BoxDecoration(
                                            color: AppColors.white,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(20),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    4,
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2.3,
                                                      child: FittedBox(
                                                        fit: BoxFit.fitWidth,
                                                        child: Text(
                                                            'Need to update some\ndetails?',
                                                            style: AppTextStyles
                                                                .subtitle
                                                                .copyWith(
                                                                    color: AppColors
                                                                        .darkGrey)),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              4,
                                                      height: 35,
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const EditPet()),
                                                          );
                                                        },
                                                        style: ButtonStyle(
                                                          padding: MaterialStateProperty
                                                              .all(const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 10,
                                                                  horizontal:
                                                                      15.0)),
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all<Color>(
                                                                      AppColors
                                                                          .blue),
                                                          shape: MaterialStateProperty
                                                              .all<
                                                                  RoundedRectangleBorder>(
                                                            RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                            ),
                                                          ),
                                                          shadowColor:
                                                              MaterialStateProperty
                                                                  .all<Color>(Colors
                                                                      .transparent),
                                                        ),
                                                        child: Container(
                                                          //color: Colors.amber,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              2,
                                                          child: FittedBox(
                                                            fit:
                                                                BoxFit.fitWidth,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                const Icon(
                                                                  Icons
                                                                      .cloud_upload_rounded,
                                                                  color:
                                                                      AppColors
                                                                          .white,
                                                                  size: 15,
                                                                ),
                                                                const SizedBox(
                                                                    width: 8),
                                                                Text(
                                                                  'Update',
                                                                  style: AppTextStyles
                                                                      .body1
                                                                      .copyWith(
                                                                    color: AppColors
                                                                        .white,
                                                                    //fontWeight: FontWeight.w600,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              5,
                                          child: isCat
                                              ? const Image(
                                                  image: AssetImage(
                                                      'assets/images/cat_sit.png'),
                                                )
                                              : const Image(
                                                  image: AssetImage(
                                                      'assets/images/dog_sit.png'),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 20),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          )
        : Scaffold(
            backgroundColor: AppColors.pinkAccent,
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: isLoading
                      ? Center(
                          child: Image(
                            image: const AssetImage(
                                'assets/images/paw_loading_pink.gif'),
                            gaplessPlayback: true,
                            height: MediaQuery.of(context).size.height / 5,
                            fit: BoxFit.fitHeight,
                          ),
                          // CircularProgressIndicator(
                          //   backgroundColor: AppColors.blue,
                          // ),
                        )
                      : Stack(
                          children: [
                            Positioned(
                              top: 120,
                              left: 40,
                              child: Transform(
                                transform: Matrix4.rotationZ(3.8),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 40,
                                  color: AppColors.white.withOpacity(0.4),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 20,
                              right: 15,
                              child: Transform(
                                transform: Matrix4.rotationZ(1.8),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 40,
                                  color: AppColors.white.withOpacity(0.4),
                                ),
                              ),
                            ),
                            // Positioned(
                            //   bottom: 0,
                            //   left: 20,
                            //   child: Container(
                            //     height: 20,
                            //     width: 20,
                            //     decoration: BoxDecoration(
                            //       color: AppColors.white.withOpacity(0.4),
                            //     ),
                            //   ),
                            // ),
                            Positioned(
                              bottom: 0,
                              right: 40,
                              child: Transform(
                                transform: Matrix4.rotationZ(2.1),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 20,
                                  color: AppColors.white.withOpacity(0.4),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 140,
                              right: 100,
                              child: Transform(
                                transform: Matrix4.rotationZ(1),
                                child: Icon(
                                  Icons.pets_rounded,
                                  size: 20,
                                  color: AppColors.white.withOpacity(0.4),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 30,
                              child: Transform(
                                transform: Matrix4.rotationZ(1.3),
                                child: Container(
                                  height: 15,
                                  width: 15,
                                  decoration: BoxDecoration(
                                    color: AppColors.white.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(30),
                              height: 400,
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      padding: const EdgeInsets.all(25),
                                      width: MediaQuery.of(context).size.width -
                                          60,
                                      height: 190,
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Container(
                                        //color: Colors.amber,
                                        child: FittedBox(
                                          fit: BoxFit.fitHeight,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const SizedBox(height: 20),
                                              Text('No Pet Added',
                                                  style: AppTextStyles.title1
                                                      .copyWith(
                                                          color: AppColors
                                                              .darkGrey)),
                                              Text(
                                                  'Lets set up your pet profile',
                                                  style: AppTextStyles.body1
                                                      .copyWith(
                                                          color:
                                                              AppColors.grey)),
                                              const SizedBox(height: 10),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const AddPet(),
                                                    ),
                                                  );
                                                },
                                                style: ButtonStyle(
                                                  padding:
                                                      MaterialStateProperty.all(
                                                          const EdgeInsets.all(
                                                              20)),
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                              Color>(
                                                          AppColors.blue),
                                                  //shape circle
                                                  shape: MaterialStateProperty
                                                      .all<RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            150.0),
                                                  )),
                                                  shadowColor:
                                                      MaterialStateProperty.all<
                                                              Color>(
                                                          Colors.transparent),
                                                ),
                                                child: Container(
                                                  height: 20,
                                                  width: 20,
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.pets_rounded,
                                                    color: AppColors.white,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topCenter,
                                    child: isCat
                                        ? Image(
                                            image: const AssetImage(
                                                'assets/images/cat_sit.png'),
                                            // width: MediaQuery.of(context)
                                            //         .size
                                            //         .width /
                                            //     2,
                                            height: 250,
                                          )
                                        : Image(
                                            image: const AssetImage(
                                                'assets/images/dog_sit.png'),
                                            // width: MediaQuery.of(context)
                                            //         .size
                                            //         .width /
                                            //     2,
                                            height: 250,
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          );
  }
}
