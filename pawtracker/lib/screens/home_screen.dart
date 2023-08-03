import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' hide Query;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pawtracker/calendar/calendarSection.dart';
import 'package:pawtracker/providers/auth_methods.dart';
import 'package:pawtracker/screens/calibrate_screen.dart';
import 'package:pawtracker/screens/login_screen.dart';
import 'package:pawtracker/utils/constants.dart';
import 'package:pawtracker/utils/global_variable.dart';
import 'package:pawtracker/widgets/location_details.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  FirebaseDatabase database = FirebaseDatabase.instance;
  Border border = Border.all(color: AppColors.greyAccentLine, width: 1);
  BoxShadow pressedShadow = const BoxShadow(
    color: Color.fromARGB(31, 49, 49, 49),
    blurRadius: 15,
    offset: Offset(0, 5),
  );
  bool isSelected1 = false;
  bool isSelected2 = false;
  bool isSelected3 = false;
  bool isSelected4 = false;
  bool isSelected5 = false;

  String? petType;
  var userData = {};
  int petLen = 0;
  bool isLoading = false;
  double phoneLat = 0;
  double phoneLong = 0;

  //Device readings (Telemetry)
  String perimeter = "N/A";
  String deviceLat = "0";
  String deviceLong = "0";
  String altitude = "0";
  String speed = "0";
  String month = "mm", day = "dd", year = "yyyy";
  String hour = "00", minute = "00", second = "00";
  double hourDouble = 0, minuteDouble = 0, secondDouble = 0;
  String dateTime = "mm/dd/yyyy | 00:00:00";
  String distancePetHome = '';
  String distancePhonePet = '';

  bool readingEmpty = false;

  int alertCount = 0;
  bool notSafeUnderstood = false;

  String mapLink = "";

  String parseData(String data) {
    String v0 = data.toString();
    String result = v0.substring(v0.indexOf(':') + 1);
    result = result.replaceAll(RegExp(r"\s+"), "");
    return result;
  }

  //get user uid
  // String uid = FirebaseAuth.instance.currentUser!.uid;
  String uid = '';
  String distanceBetween(double lat1, double lon1, double lat2, double lon2) {
    double distance = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
    distance = (distance / 1000); // (distance / 1000).toStringAsFixed(2);
    if (distance > 13326) {
      distance = 0.01;
    }
    return distance.toStringAsFixed(2);
  }

  String? locationAddress;

  void getPets() async {
    print("==========================================");
    print("getPets");
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      var petSnap = await FirebaseFirestore.instance
          .collection('pets')
          .where('uid', isEqualTo: user!.uid)
          .get();

      petType = petSnap.docs[0]['petType'];

      // // get pet lENGTH
      petLen = petSnap.docs.length;
      if (petLen == 0) {
        isPetAdded = false;
        setState(() {
          petNameGlobal = "No Pet Added";
        });
      } else {
        isPetAdded = true;
        if (petType == "Cat") {
          isCat = true;
        } else if (petType == "Dog") {
          isCat = false;
        }
        setState(() {
          petNameGlobal = petSnap.docs[0]['petName'];
        });
      }
      userData = userSnap.data()!;
      print('\n\n=============PET LENGTH============');
      print('PET LENGTH: $petLen');
      print('=============PET LENGTH============\n\n');
    } catch (e) {
      // showSnackBar(
      //   context,
      //   e.toString(),
      // );
      petNameGlobal = "No Pet Added";
    }
  }

  _getCurrentLocation() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    print("\n\n==========================================");
    print("_getCurrentLocation");
    print("==========================================\n\n");
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print("SERVICE ENABLED: $serviceEnabled");
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    print("HAtDOG");
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String completeAddress =
        '${placemark.street}, ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.country}'; //, ${placemark.postalCode}';

    phoneLat = position.latitude;
    phoneLong = position.longitude;

    print('==========================================');
    print('GET CURRENT LOCATION');
    print('LATITUDE: ${position.latitude}, LONGITUDE: ${position.longitude}');
    print('completeAddress: $completeAddress');
    if (mounted) {
      setState(() {
        // if (phoneLat != 0 && phoneLong != 0) {
        //   isPhoneLocOn = true;
        // } else {
        //   isPhoneLocOn = false;
        // }
        if (serviceEnabled == true) {
          isPhoneLocOn = true;
        } else {
          isPhoneLocOn = false;
        }
        isLoading = false;

        phoneLatitudeGlobal = phoneLat;
        phoneLongitudeGlobal = phoneLong;
        phoneAddressGlobal = completeAddress;

        //HOME-PET DISTANCE
        distancePetHome = distanceBetween(
          deviceLatitudeGlobal,
          deviceLongitudeGlobal,
          homeLatitudeGlobal,
          homeLongitudeGlobal,
        );
        distancePetHomeGlobal = distancePetHome;
        // //PHONE-PET DISTANCE
        distancePhonePet = distanceBetween(
          phoneLatitudeGlobal,
          phoneLongitudeGlobal,
          deviceLatitudeGlobal,
          deviceLongitudeGlobal,
        );
        distancePhonePetGlobal = distancePhonePet;
        print("\n\n===========PET DISTANCE============");
        print("DISTANCE PHONE-PET: $distancePhonePet");
        print("DISTANCE PET-HOME: $distancePetHome");
        print("===========PET DISTANCE============\n\n");
        print("===========PHONE LOCATION============");
        print('PHONE LAT: $phoneLat');
        print('PHONE LONG: $phoneLong');
        print('PHONE LAT GLOBAL: $phoneLatitudeGlobal');
        print('PHONE LONG GLOBAL: $phoneLongitudeGlobal');
        print('PHONE ADDRESS GLOBAL: $phoneAddressGlobal');
        print("===========PHONE LOCATION============");
        print("get current location inside mounted.");
        print("==========================================\n\n");
      });
    }
    if (!mounted) {
      print("NOT MOUNTED");
      return;
    }
    setState(() {
      if (serviceEnabled == true) {
        isPhoneLocOn = true;
      } else {
        isPhoneLocOn = false;
      }
      isLoading = false;
      phoneLatitudeGlobal = phoneLat;
      phoneLongitudeGlobal = phoneLong;
      phoneAddressGlobal = completeAddress;
      //HOME-PET DISTANCE
      distancePetHome = distanceBetween(
        deviceLatitudeGlobal,
        deviceLongitudeGlobal,
        homeLatitudeGlobal,
        homeLongitudeGlobal,
      );
      distancePetHomeGlobal = distancePetHome;
      // //PHONE-PET DISTANCE
      distancePhonePet = distanceBetween(
        phoneLatitudeGlobal,
        phoneLongitudeGlobal,
        deviceLatitudeGlobal,
        deviceLongitudeGlobal,
      );
      distancePhonePetGlobal = distancePhonePet;
      print("\n\n===========PET DISTANCE============");
      print("DISTANCE PHONE-PET: $distancePhonePet");
      print("DISTANCE PET-HOME: $distancePetHome");
      print("===========PET DISTANCE============\n\n");
      print("===========PHONE LOCATION============");
      print('PHONE LAT: $phoneLat');
      print('PHONE LONG: $phoneLong');
      print('PHONE LAT GLOBAL: $phoneLatitudeGlobal');
      print('PHONE LONG GLOBAL: $phoneLongitudeGlobal');
      print('PHONE ADDRESS GLOBAL: $phoneAddressGlobal');
      print("===========PHONE LOCATION============");
      print("get current location outisde mounted.");
      print("==========================================\n\n");
    });
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

  readData() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    print("\n\n=================RUNNING READ DATA=================");
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("UsersData/$uid/readings");

    // Get the Stream
    Stream<DatabaseEvent> stream = ref.onValue;
    // Subscribe to the stream!
    stream.listen((DatabaseEvent event) {
      // print('=========================');
      // print(event.snapshot.value);

      //print(event.snapshot.value);
      Query query = ref.limitToLast(1);
      var latestTelemetry = query.onValue.listen(
        (event) {
          var telemetry = event.snapshot.value!;
          //print("Latest Value: ${telemetry}");
          final dataSerial =
              json.decode(json.encode(telemetry)) as Map<String, dynamic>;
          List<String> telemetryData = [];
          if (telemetry != null) {
            //print("Iterate DATA!!!!!!!!");
            var cleanData =
                dataSerial.values.toString().replaceAll(RegExp(r'[{}]+'), '');
            var cleanData2 =
                cleanData.toString().replaceAll(RegExp(r'[()]+'), '');
            //print('CLEAN DATA: $cleanData2');
            final separateData = cleanData2.split(',');
            final Map<int, String> values = {
              for (int i = 0; i < separateData.length; i++) i: separateData[i]
            };

            if (mounted) {
              setState(() {
                isCalibrated = true;

                mapLink = '${parseData(values[1]!)},${parseData(values[2]!)}';

                altitude = parseData(values[0].toString());
                speed = parseData(values[7].toString());
                perimeter = parseData(values[14].toString());
                deviceLat = parseData(values[9].toString())
                    .substring(0, 8); //.substring(0, 7));
                deviceLong = parseData(values[17].toString()).substring(0, 9);

                month = parseData(values[13].toString());
                day = parseData(values[16].toString());
                year = parseData(values[3].toString());

                if (month == "1") {
                  month = "January";
                } else if (month == "2") {
                  month = "February";
                } else if (month == "3") {
                  month = "March";
                } else if (month == "4") {
                  month = "April";
                } else if (month == "5") {
                  month = "May";
                } else if (month == "6") {
                  month = "June";
                } else if (month == "7") {
                  month = "July";
                } else if (month == "8") {
                  month = "August";
                } else if (month == "9") {
                  month = "September";
                } else if (month == "10") {
                  month = "October";
                } else if (month == "11") {
                  month = "November";
                } else if (month == "12") {
                  month = "December";
                }

                hour = parseData(values[12].toString());
                minute = parseData(values[8].toString());
                second = parseData(values[10].toString());

                hourDouble = double.parse(hour);
                minuteDouble = double.parse(minute);
                secondDouble = double.parse(second);

                if (hourDouble < 10) {
                  hour = '0$hour';
                }
                if (minuteDouble < 10) {
                  minute = '0$minute';
                }
                if (secondDouble < 10) {
                  second = '0$second';
                }

                dateTime = '$month $day, $year | $hour:$minute:$second';

                //used in getting distance for Home and Map Page
                deviceLatitudeGlobal = double.parse(parseData(values[9]!));
                deviceLongitudeGlobal = double.parse(parseData(values[17]!));
                homeLatitudeGlobal = double.parse(parseData(values[11]!));
                homeLongitudeGlobal = double.parse(parseData(values[5]!));
                //HOME-PET DISTANCE
                distancePetHome = distanceBetween(
                  deviceLatitudeGlobal,
                  deviceLongitudeGlobal,
                  homeLatitudeGlobal,
                  homeLongitudeGlobal,
                );
                distancePetHomeGlobal = distancePetHome;
                // //PHONE-PET DISTANCE
                distancePhonePet = distanceBetween(
                  phoneLatitudeGlobal,
                  phoneLongitudeGlobal,
                  deviceLatitudeGlobal,
                  deviceLongitudeGlobal,
                );
                distancePhonePetGlobal = distancePhonePet;
                print("\n\n===========PET DISTANCE============");
                print("DISTANCE PHONE-PET: $distancePhonePet");
                print("DISTANCE PET-HOME: $distancePetHome");

                //Global Readings
                geofenceRadiusGlobal = int.parse(parseData(values[13]!));
                altitudeGlobal = parseData(values[0].toString());
                speedGlobal = parseData(values[7].toString());
                deviceLatGlobal =
                    double.parse(parseData(values[9]!)).toString();
                deviceLongGlobal =
                    double.parse(parseData(values[17]!)).toString();
                print('\n\n=============DEVICE READINGS============');
                print('MAP LINK: $mapLink');
                print('DEVICE LAT: $deviceLatitudeGlobal');
                print('DEVICE LONG: $deviceLongitudeGlobal');
                print('HOME LAT: $homeLatitudeGlobal');
                print('HOME LONG: $homeLongitudeGlobal');
                print('PERIMETER: $perimeter');
                print('ALTITUDE: $altitude');
                print('SPEED: $speed');
                print('RADIUS: $geofenceRadiusGlobal');

                if (perimeter == '0') {
                  perimeter = 'Not Safe';
                  perimeterGlobal = 'Not Safe';
                  if (notSafeUnderstood == false && alertCount < 1) {
                    alertCount += 1;
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.red,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0))),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: const [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.white,
                                size: 50,
                              ),
                            ],
                          ),
                          content: Container(
                            height: 85,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Column(
                                children: [
                                  Text('Warning',
                                      style: AppTextStyles.title1
                                          .copyWith(color: AppColors.white)),
                                  const SizedBox(height: 20),
                                  Text(
                                      'Your pet is outside the geofence perimeter. Please check your pet location.',
                                      style: AppTextStyles.body1
                                          .copyWith(color: AppColors.white),
                                      textAlign: TextAlign.justify),
                                ],
                              ),
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                alertCount += 1;
                                notSafeUnderstood = true;
                                Navigator.of(context).pop();
                              },
                              child: Text('Understood',
                                  style: AppTextStyles.body1
                                      .copyWith(color: AppColors.white)),
                            ),
                          ],
                        );
                      },
                    );
                  }
                } else if (perimeter == '1') {
                  perimeter = 'Safe';
                  perimeterGlobal = 'Safe';
                }
                print('PERIMETER: $perimeter');
                print('=============DEVICE READINGS============\n\n');
                deviceAddresss();
                homeAddress();
              });
            }

            if (!mounted) {
              print("NOT MOUNTED");
              print(mounted);
              return;
            }
          } else {
            setState(() {
              readingEmpty = true;
              perimeter = "N/A";
              deviceLat = "0";
              deviceLong = "0";
              altitude = "0";
              speed = "0";
              isCalibrated = false;
            });
          }
        },
      );
    });
    print("=================END READ DATA=================\n\n");
  }

  deviceAddresss() async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        deviceLatitudeGlobal, deviceLongitudeGlobal);
    Placemark placemark = placemarks[0];
    if (mounted) {
      setState(() {
        isLoading = false;
        deviceAddressGlobal =
            '${placemark.street}, ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.country}'; //, ${placemark.postalCode}';
        print('DEVICE ADDRESS: $deviceAddressGlobal');
      });
    }
  }

  homeAddress() async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(homeLatitudeGlobal, homeLongitudeGlobal);
    Placemark placemark = placemarks[0];
    if (mounted) {
      setState(() {
        isLoading = false;
        petHomeAddressGlobal =
            '${placemark.street}, ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.country}'; //, ${placemark.postalCode}';
        print('HOME ADDRESS: $petHomeAddressGlobal');
      });
    }
  }

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
    print("Getting location...");
    _getCurrentLocation();
    print("Getting pets...");
    getPets();
    print("Getting data...");
    readData();
    print("Done");
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
            child: isLoading
                ? Center(
                    child: Image(
                      image: const AssetImage('assets/images/paw_loading.gif'),
                      gaplessPlayback: true,
                      height: height / 5,
                      fit: BoxFit.fitHeight,
                    ),
                    // CircularProgressIndicator(
                    //   backgroundColor: AppColors.blue,
                    // ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 20, left: 30, right: 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.pets_rounded,
                                        color: AppColors.black,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Text('PawTracker',
                                          style: AppTextStyles.title1),
                                    ],
                                  ),
                                  IconButton(
                                      onPressed: () async {
                                        isCalibrated = false;
                                        isCat = false;
                                        assistantName = "Cooper";
                                        isPetAdded = false;
                                        isPet = false;
                                        petNameGlobal = "";
                                        deviceLatitudeGlobal = 0;
                                        deviceLongitudeGlobal = 0;
                                        //character limit device latlong
                                        deviceLatGlobal = "";
                                        deviceLongGlobal = "";
                                        deviceAddressGlobal = "";
                                        homeLatitudeGlobal = 0;
                                        homeLongitudeGlobal = 0;
                                        geofenceRadiusGlobal = 0;
                                        perimeterGlobal = "";
                                        altitudeGlobal = "";
                                        speedGlobal = "";
                                        phoneLatitudeGlobal = 0;
                                        phoneLongitudeGlobal = 0;
                                        phoneAddressGlobal = "";
                                        petHomeAddressGlobal = "";

                                        distancePetHomeGlobal = "";
                                        distancePhonePetGlobal = "";

                                        isPhoneLocOn = false;
                                        await AuthMethods().signOut();
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginScreen(),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.logout,
                                        color: AppColors.black,
                                        size: 20,
                                      ))
                                ],
                              ),
                              SizedBox(height: 10),
                              Container(
                                height: height * 0.3,
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.topCenter,
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        height: height * 0.25,
                                        width: width,
                                        decoration: BoxDecoration(
                                          color: AppColors.pinkAccent,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              //color: Colors.amber,
                                              width: width / 3 + 30,
                                              child: FittedBox(
                                                fit: BoxFit.fitWidth,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    RichText(
                                                      text: TextSpan(
                                                        text: isCat
                                                            ? 'I am Chelsea'
                                                            : 'I am Cooper',
                                                        style: AppTextStyles
                                                            .headings
                                                            .copyWith(
                                                          color:
                                                              AppColors.white,
                                                        ),
                                                        children: const [],
                                                      ),
                                                    ),
                                                    Text(
                                                      'your paw tracking',
                                                      style: AppTextStyles
                                                          .subtitle1
                                                          .copyWith(
                                                        color: AppColors.white,
                                                        //fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                    Text(
                                                      'assistant!',
                                                      style: AppTextStyles
                                                          .subtitle1
                                                          .copyWith(
                                                        color: AppColors.white,
                                                        //fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                if (isCalibrated == false) {
                                                } else {
                                                  Uri mapUrl =
                                                      Uri.parse(mapLink);
                                                  //show alert dialog
                                                  showDialog(
                                                    barrierDismissible: false,
                                                    context: context,
                                                    builder: (BuildContext
                                                            context) =>
                                                        AlertDialog(
                                                      backgroundColor:
                                                          AppColors.white,
                                                      shape: const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius.circular(
                                                                      20.0))),
                                                      contentPadding:
                                                          const EdgeInsets
                                                                  .symmetric(
                                                              vertical: 0,
                                                              horizontal: 30),
                                                      title: Column(
                                                        children: const [
                                                          Text(
                                                            'Latest Telemetry',
                                                            style: TextStyle(
                                                                color: AppColors
                                                                    .black),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Divider(),
                                                        ],
                                                      ),
                                                      content: Container(
                                                        height: 220,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              AppColors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                        child:
                                                            SingleChildScrollView(
                                                          scrollDirection:
                                                              Axis.vertical,
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .gps_fixed_rounded,
                                                                    color: Colors
                                                                        .blue,
                                                                    size: 15,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 5,
                                                                  ),
                                                                  Text(
                                                                    'Address',
                                                                    style: AppTextStyles
                                                                        .body1,
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                  height: 3),
                                                              Text(
                                                                '$deviceAddressGlobal',
                                                                style:
                                                                    AppTextStyles
                                                                        .body1,
                                                              ),
                                                              SizedBox(
                                                                  height: 15),
                                                              Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .link_rounded,
                                                                    color: Colors
                                                                        .blue,
                                                                    size: 15,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 5,
                                                                  ),
                                                                  Text(
                                                                    'Map Link',
                                                                    style: AppTextStyles
                                                                        .body1,
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                  height: 3),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  _launchUrl(
                                                                      mapUrl);
                                                                },
                                                                child: Text(
                                                                  mapLink,
                                                                  style:
                                                                      AppTextStyles
                                                                          .body1,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height: 15),
                                                              Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .social_distance_rounded,
                                                                    color: Colors
                                                                        .blue,
                                                                    size: 15,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 5,
                                                                  ),
                                                                  Text(
                                                                      'Distance',
                                                                      style: AppTextStyles
                                                                          .body1),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                  height: 3),
                                                              Text(
                                                                isPhoneLocOn
                                                                    ? 'Your pet is ${distancePhonePetGlobal} km away from you and ${distancePetHomeGlobal} km away from your home location.'
                                                                    : 'Your pet is ${distancePetHomeGlobal} km away from your home location.',
                                                                style:
                                                                    AppTextStyles
                                                                        .body1,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    right:
                                                                        10.0),
                                                            child: const Text(
                                                                'Understood'),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }
                                              },
                                              style: ButtonStyle(
                                                padding:
                                                    MaterialStateProperty.all(
                                                        const EdgeInsets
                                                                .symmetric(
                                                            vertical: 10.0,
                                                            horizontal: 15.0)),
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                        Color>(AppColors.blue),
                                                shape:
                                                    MaterialStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                  ),
                                                ),
                                                shadowColor:
                                                    MaterialStateProperty.all<
                                                            Color>(
                                                        Colors.transparent),
                                              ),
                                              child: Container(
                                                //color: Colors.amber,
                                                width: width / 3,
                                                //height: 20,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5,
                                                        horizontal: 10.0),
                                                child: FittedBox(
                                                  fit: BoxFit.fitWidth,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Icon(
                                                        Icons.signpost_rounded,
                                                        color: AppColors.white,
                                                        size: 25,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        'Track your pet',
                                                        style: AppTextStyles
                                                            .body1
                                                            .copyWith(
                                                          color:
                                                              AppColors.white,
                                                          //fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Container(
                                        height: height * 0.25,
                                        width: width / 2.2,
                                        child: isCat
                                            ? const Image(
                                                image: AssetImage(
                                                    'assets/images/cat_hi.png'),
                                              )
                                            : const Image(
                                                image: AssetImage(
                                                    'assets/images/dog_hi.png'),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const CalendarSection(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: width,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Telemetry',
                                      style: AppTextStyles.subtitle1),
                                  Container(
                                    //color: Colors.amber,
                                    width: width / 3,
                                    child: FittedBox(
                                      fit: BoxFit.fitWidth,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.access_time_rounded,
                                            color: AppColors.grey,
                                            size: 15,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(dateTime,
                                              style: AppTextStyles.body1
                                                  .copyWith(
                                                      color: AppColors.grey,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                margin: const EdgeInsets.only(
                                    top: 10.0, bottom: 20, left: 30, right: 30),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isSelected1 = !isSelected1;
                                          isSelected2 = false;
                                          isSelected3 = false;
                                          isSelected4 = false;
                                          isSelected5 = false;
                                        });
                                      },
                                      child: DetailsCard(
                                        label: 'Perimeter',
                                        value: isLoading
                                            ? 'Loading...'
                                            : perimeter,
                                        icon: Icons.noise_aware_rounded,
                                        color: AppColors.lightPurple,
                                        border: isSelected1 ? null : border,
                                        boxShadow: isSelected1
                                            ? [pressedShadow]
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isSelected2 = !isSelected2;
                                          isSelected1 = false;
                                          isSelected3 = false;
                                          isSelected4 = false;
                                          isSelected5 = false;
                                        });
                                      },
                                      child: DetailsCard(
                                        label: 'Longitude',
                                        value: isLoading
                                            ? 'Loading...'
                                            : '$deviceLong°',
                                        icon: Icons.place_rounded,
                                        color: AppColors.lightGreen,
                                        border: isSelected2 ? null : border,
                                        boxShadow: isSelected2
                                            ? [pressedShadow]
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isSelected3 = !isSelected3;
                                          isSelected1 = false;
                                          isSelected2 = false;
                                          isSelected4 = false;
                                          isSelected5 = false;
                                        });
                                      },
                                      child: DetailsCard(
                                        label: 'Latitude',
                                        value: isLoading
                                            ? 'Loading...'
                                            : '$deviceLat°',
                                        icon: Icons.place_rounded,
                                        color: AppColors.lightyellow,
                                        border: isSelected3 ? null : border,
                                        boxShadow: isSelected3
                                            ? [pressedShadow]
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isSelected4 = !isSelected4;
                                          isSelected1 = false;
                                          isSelected2 = false;
                                          isSelected3 = false;
                                          isSelected5 = false;
                                        });
                                      },
                                      child: DetailsCard(
                                        label: 'Altitude',
                                        value: isLoading
                                            ? 'Loading...'
                                            : '${altitude}m',
                                        color: AppColors.lightOrange,
                                        icon: Icons.nature_people_rounded,
                                        border: isSelected4 ? null : border,
                                        boxShadow: isSelected4
                                            ? [pressedShadow]
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isSelected5 = !isSelected5;
                                          isSelected1 = false;
                                          isSelected2 = false;
                                          isSelected3 = false;
                                          isSelected4 = false;
                                        });
                                      },
                                      child: DetailsCard(
                                        label: 'Speed',
                                        value: isLoading
                                            ? 'Loading...'
                                            : '${speed}m/s²',
                                        color: AppColors.lightRed,
                                        icon: Icons.near_me_rounded,
                                        border: isSelected5 ? null : border,
                                        boxShadow: isSelected5
                                            ? [pressedShadow]
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 30.0),
                              padding: const EdgeInsets.all(20.0),
                              width: width,
                              height: height * 0.2,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 240, 240, 240),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Stack(
                                    //mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Icon(
                                          Icons.wifi_rounded,
                                          size: 20,
                                          color: isCalibrated
                                              ? Colors.green
                                              : AppColors.darkGrey,
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          width: width / 3,
                                          height: height * 0.13,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            //color: Colors.red,
                                          ),
                                          child: const Image(
                                            image: AssetImage(
                                              'assets/images/pawtracker.png',
                                            ),
                                            fit: BoxFit.fitHeight,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    // color: Colors.pink,
                                    width: width / 2.5,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          //color: Colors.amber,
                                          width: width / 3,
                                          child: FittedBox(
                                            fit: BoxFit.fitWidth,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text('PawTracker',
                                                    style: AppTextStyles
                                                        .subHeadings3
                                                        .copyWith(
                                                      color: AppColors.darkGrey,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    )),
                                                const SizedBox(height: 5),
                                                Text('Pet Tracking Device',
                                                    style: AppTextStyles.body4
                                                        .copyWith(
                                                      color: AppColors.darkGrey,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    )),
                                              ],
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    WifiSetter(),
                                              ),
                                            );
                                          },
                                          style: ButtonStyle(
                                            padding: MaterialStateProperty.all(
                                                const EdgeInsets.symmetric(
                                                    vertical: 10.0,
                                                    horizontal: 15.0)),
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                        Color>(
                                                    AppColors.pinkAccent),
                                            shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(13.0),
                                              ),
                                            ),
                                            shadowColor: MaterialStateProperty
                                                .all<Color>(Colors.transparent),
                                          ),
                                          child: Container(
                                            //color: Colors.amber,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15.0),
                                            width: width / 3.8,
                                            child: FittedBox(
                                              fit: BoxFit.fitWidth,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.memory_rounded,
                                                    color: AppColors.white,
                                                    size: 25,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Calibrate',
                                                    style: AppTextStyles.body1
                                                        .copyWith(
                                                      color: AppColors.white,
                                                      //fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
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
                            SizedBox(height: 20),
                          ],
                        ),
                      ],
                    ),
                  )));
  }
}
