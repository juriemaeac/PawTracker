import 'dart:async';
import 'dart:convert' show utf8;
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pawtracker/utils/constants.dart';
import 'package:pawtracker/utils/global_variable.dart';
import 'package:pawtracker/utils/navigation.dart';
import 'package:pawtracker/widgets/snackbar.dart';
import 'package:pawtracker/widgets/text_field_disabled.dart';
import 'package:pawtracker/widgets/text_field_input.dart';

class WifiSetter extends StatefulWidget {
  @override
  _WifiSetterState createState() => _WifiSetterState();
}

class _WifiSetterState extends State<WifiSetter> {
  final user = FirebaseAuth.instance.currentUser;
  var userData = {};
  int petLen = 0;

  bool isLoading = false;
  bool _isObscure = false;
  bool _isObscure1 = false;

  final String SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String CHARACTERISTIC_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  final String TARGET_DEVICE_NAME = "PawTracker v.1";

  FlutterBlue flutterBlue = FlutterBlue.instance;
  StreamSubscription<ScanResult>? scanSubscription;

  BluetoothDevice? targetDevice;
  BluetoothCharacteristic? targetCharacteristic;

  String connectionText = "";

  double lat = 0;
  double long = 0;
  late LatLng currentCenter = LatLng(lat, long);

  String completeAddressCalibrated = '';

  TextEditingController wifiNameController = TextEditingController();
  TextEditingController wifiPasswordController = TextEditingController();
  TextEditingController petNameController =
      TextEditingController(text: petNameGlobal);
  TextEditingController userEmailController = TextEditingController();
  TextEditingController userPasswordController = TextEditingController();
  TextEditingController homeAddressController = TextEditingController();
  TextEditingController latController = TextEditingController();
  TextEditingController longController = TextEditingController();
  TextEditingController perimeterController = TextEditingController();

  TextEditingController homeAddressCalibrated =
      TextEditingController(text: petHomeAddressGlobal);
  TextEditingController latCalibrated =
      TextEditingController(text: homeLatitudeGlobal.toString());
  TextEditingController longCalibrated =
      TextEditingController(text: homeLongitudeGlobal.toString());

  bool isGetLocPressed = false;

  @override
  void initState() {
    super.initState();
    startScan();
    _getCurrentLocation();
    getCurrentUserEmail();
  }

  startScan() {
    setState(() {
      connectionText = "Start Scanning";
    });

    scanSubscription = flutterBlue.scan().listen((scanResult) {
      print(scanResult.device.name);
      if (scanResult.device.name.contains(TARGET_DEVICE_NAME)) {
        stopScan();

        setState(() {
          connectionText = "Found Target Device";
        });

        targetDevice = scanResult.device;
        connectToDevice();
      }
    }, onDone: () => stopScan());
  }

  stopScan() {
    scanSubscription!.cancel();

    //scanSubscription = null;
  }

  connectToDevice() async {
    if (targetDevice == null) {
      return;
    }

    setState(() {
      connectionText = "Device Connecting";
    });

    await targetDevice!.connect();

    setState(() {
      connectionText = "Device Connected";
    });

    discoverServices();
  }

  disconnectFromDeivce() {
    if (targetDevice == null) {
      return;
    }

    targetDevice!.disconnect();

    setState(() {
      connectionText = "Device Disconnected";
    });
  }

  discoverServices() async {
    if (targetDevice == null) {
      return;
    }

    List<BluetoothService> services = await targetDevice!.discoverServices();
    services.forEach((service) {
      if (service.uuid.toString() == SERVICE_UUID) {
        service.characteristics.forEach((characteristics) {
          if (characteristics.uuid.toString() == CHARACTERISTIC_UUID) {
            targetCharacteristic = characteristics;
            setState(() {
              connectionText = "Calibrating ${targetDevice!.name}";
            });
          }
        });
      }
    });
  }

  writeData(String data) async {
    if (targetCharacteristic == null) return;

    List<int> bytes = utf8.encode(data);
    await targetCharacteristic!.write(bytes);
  }

  _getCurrentLocation() async {
    setState(() {
      isLoading = true;
    });
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = isCalibrated
        ? isGetLocPressed
            ? await placemarkFromCoordinates(
                position.latitude, position.longitude)
            : await placemarkFromCoordinates(
                homeLatitudeGlobal, homeLongitudeGlobal)
        : await placemarkFromCoordinates(
            phoneLatitudeGlobal, phoneLongitudeGlobal);
    Placemark placemark = placemarks[0];
    String completeAddress =
        '${placemark.street}, ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.country}'; //, ${placemark.postalCode}';

    setState(() {
      isLoading = false;
      homeAddressController.text = completeAddress;
      //petHomeAddressGlobal = completeAddress;
      lat = position.latitude;
      latController.text = lat.toString();
      long = position.longitude;
      longController.text = long.toString();
      currentCenter = LatLng(lat, long);
      print("IS LOC PRESSED: $isGetLocPressed");
      print('==========================================');
      print('GET CURRENT LOCATION POINTS');
      print('LATITUDE: ${position.latitude}, LONGITUDE: ${position.longitude}');
      print('==========================================');
      print(
          'LOCATIONADDRESS: ${homeAddressController.text} || LAT: $lat || LONG: $long');
      print('==========================================\n\n');
    });
  }

  _UpdateCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = isCalibrated
        ? isGetLocPressed
            ? await placemarkFromCoordinates(
                position.latitude, position.longitude)
            : await placemarkFromCoordinates(
                homeLatitudeGlobal, homeLongitudeGlobal)
        : await placemarkFromCoordinates(
            phoneLatitudeGlobal, phoneLongitudeGlobal);
    Placemark placemark = placemarks[0];
    String completeAddress =
        '${placemark.street}, ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.country}'; //, ${placemark.postalCode}';

    setState(() {
      homeAddressController.text = completeAddress;
      //petHomeAddressGlobal = completeAddress;
      lat = position.latitude;
      latController.text = lat.toString();
      long = position.longitude;
      longController.text = long.toString();
      currentCenter = LatLng(lat, long);
      print("IS LOC PRESSED: $isGetLocPressed");
      print('==========================================');
      print('GET CURRENT LOCATION POINTS');
      print('LATITUDE: ${position.latitude}, LONGITUDE: ${position.longitude}');
      print('==========================================');
      print(
          'LOCATIONADDRESS: ${homeAddressController.text} || LAT: $lat || LONG: $long');
      print('==========================================\n\n');
    });
  }

  //get current user email
  getCurrentUserEmail() async {
    userEmailController.text =
        (await FirebaseAuth.instance.currentUser)!.email!;
  }

  @override
  void dispose() {
    super.dispose();
    stopScan();
    isGetLocPressed = false;
    homeAddressController.dispose();
    latController.dispose();
    longController.dispose();
    wifiNameController.dispose();
    wifiPasswordController.dispose();
    userEmailController.dispose();
    userPasswordController.dispose();
    perimeterController.dispose();
    petNameController.dispose();
  }

  submitAction() {
    var wifiData =
        '${petNameController.text}, ${userEmailController.text}, ${userPasswordController.text}, ${latController.text}, ${longController.text}, ${perimeterController.text}, ${wifiNameController.text}, ${wifiPasswordController.text}';
    //   var wifiData =
    //      '${petNameController.text}, ${userEmailController.text}, ${userPasswordController.text}, 14.599133, 121.008304, ${perimeterController.text}, ${wifiNameController.text}, ${wifiPasswordController.text}';
    writeData(wifiData);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    print('HOME ADDRESS: $petHomeAddressGlobal');
    print("Calibrated Home: $completeAddressCalibrated");
    print('LAT: $homeLatitudeGlobal');
    print('LONG: $homeLongitudeGlobal');
    print("IS LOC PRESSED: $isGetLocPressed");

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.pinkAccent,
        elevation: 0,
        title: Text(connectionText),
      ),
      body: Container(
          child: targetCharacteristic == null
              ? SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(
                        image:
                            const AssetImage('assets/images/paw_loading.gif'),
                        gaplessPlayback: true,
                        height: MediaQuery.of(context).size.height / 5,
                        fit: BoxFit.fitHeight,
                      ),
                      const Text(
                        "Waiting for Connection...",
                        style: AppTextStyles.textFields,
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                    ],
                  ),
                )
              : isLoading
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image(
                            image: const AssetImage(
                                'assets/images/paw_loading.gif'),
                            gaplessPlayback: true,
                            height: MediaQuery.of(context).size.height / 5,
                            fit: BoxFit.fitHeight,
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text('PawTracker',
                                    style: AppTextStyles.subHeadings3.copyWith(
                                      color: AppColors.darkGrey,
                                      fontWeight: FontWeight.w600,
                                    )),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.bluetooth_connected_rounded,
                                      size: 20,
                                      color: AppColors.darkGrey,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text('Bluetooth Connection',
                                        style: AppTextStyles.body1.copyWith(
                                          color: AppColors.darkGrey,
                                          fontWeight: FontWeight.w600,
                                        )),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  height: height * 0.18,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    //color: Colors.red,
                                  ),
                                  child: const Image(
                                    image: AssetImage(
                                      'assets/images/pawtracker.png',
                                    ),
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        //_getCurrentLocation();
                                      },
                                      child: const Icon(
                                        Icons.gps_fixed_rounded,
                                        size: 20,
                                        color: AppColors.darkGrey,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text('GPS Coordinates',
                                        style: AppTextStyles.body1.copyWith(
                                          color: AppColors.darkGrey,
                                          fontWeight: FontWeight.w600,
                                        )),
                                  ],
                                ),
                                Container(
                                  width: width / 3.5,
                                  child: FittedBox(
                                    fit: BoxFit.fitWidth,
                                    child: TextButton(
                                      onPressed: () {
                                        isGetLocPressed = true;
                                        _UpdateCurrentLocation();
                                      },
                                      child: Text('Update Location',
                                          style: AppTextStyles.body1.copyWith(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w600,
                                          )),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFieldInputDisabled(
                              isReadOnly: true,
                              textEditingController: isLoading
                                  ? isCalibrated
                                      ? TextEditingController(
                                          text: petHomeAddressGlobal)
                                      : TextEditingController(
                                          text: phoneAddressGlobal)
                                  : homeAddressController,
                              hintText: 'Home Address',
                              labelText: 'Home Address',
                              textInputType: TextInputType.name,
                              textCapitalization: TextCapitalization.words,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 2 -
                                      40,
                                  child: TextFieldInputDisabled(
                                    isReadOnly: true,
                                    textEditingController: isCalibrated
                                        ? isGetLocPressed
                                            ? isLoading
                                                ? TextEditingController(
                                                    text: homeLatitudeGlobal
                                                        .toString())
                                                : latController
                                            : latCalibrated
                                        : TextEditingController(
                                            text:
                                                phoneLatitudeGlobal.toString()),
                                    hintText: 'Latitude',
                                    labelText: 'Latitude',
                                    textInputType: TextInputType.name,
                                    textCapitalization:
                                        TextCapitalization.words,
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 2 -
                                      40,
                                  child: TextFieldInputDisabled(
                                    isReadOnly: true,
                                    textEditingController: isCalibrated
                                        ? isGetLocPressed
                                            ? isLoading
                                                ? TextEditingController(
                                                    text: homeLongitudeGlobal
                                                        .toString())
                                                : longController
                                            : longCalibrated
                                        : TextEditingController(
                                            text: phoneLongitudeGlobal
                                                .toString()),
                                    hintText: 'Longitude',
                                    labelText: 'Longitude',
                                    textInputType: TextInputType.name,
                                    textCapitalization:
                                        TextCapitalization.words,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Divider(
                              color: AppColors.greyAccentLine,
                              thickness: 1,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.wifi_rounded,
                                  size: 20,
                                  color: AppColors.darkGrey,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Wifi Details',
                                  style: AppTextStyles.body1,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFieldInput(
                              textEditingController: wifiNameController,
                              hintText: 'WiFi SSID',
                              labelText: 'WiFi SSID',
                              textInputType: TextInputType.text,
                              textCapitalization: TextCapitalization.words,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              controller: wifiPasswordController,
                              obscureText: !_isObscure1,
                              style: AppTextStyles.textFields,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.greyAccent,
                                hintText: 'WiFi Password',
                                labelText: 'WiFi Password',
                                labelStyle: AppTextStyles.subHeadings,
                                hintStyle: AppTextStyles.subHeadings,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide: BorderSide(
                                      color: Colors.transparent, width: 2),
                                ),
                                suffixIcon: IconButton(
                                    splashColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    icon: Icon(
                                      _isObscure1
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: AppColors.darkGrey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isObscure1 = !_isObscure1;
                                      });
                                    }),
                              ),
                              validator: (String? value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Required!";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Divider(
                              color: AppColors.greyAccentLine,
                              thickness: 1,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.phonelink_ring_rounded,
                                  size: 20,
                                  color: AppColors.darkGrey,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Enter Details',
                                  style: AppTextStyles.body1,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFieldInputDisabled(
                              isReadOnly: true,
                              textEditingController: petNameController,
                              hintText: 'Enter Pet Name',
                              labelText: 'Pet Name',
                              textInputType: TextInputType.text,
                              textCapitalization: TextCapitalization.words,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFieldInputDisabled(
                              isReadOnly: true,
                              textEditingController: userEmailController,
                              hintText: 'Enter Email',
                              labelText: 'Email',
                              textInputType: TextInputType.emailAddress,
                              textCapitalization: TextCapitalization.none,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              controller: userPasswordController,
                              obscureText: !_isObscure,
                              style: AppTextStyles.textFields,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.greyAccent,
                                hintText: 'Enter Password',
                                labelText: 'Password',
                                labelStyle: AppTextStyles.subHeadings,
                                hintStyle: AppTextStyles.subHeadings,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide: BorderSide(
                                      color: Colors.transparent, width: 2),
                                ),
                                suffixIcon: IconButton(
                                    splashColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    icon: Icon(
                                      _isObscure
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: AppColors.darkGrey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isObscure = !_isObscure;
                                      });
                                    }),
                              ),
                              validator: (String? value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Required!";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFieldInput(
                              textEditingController: perimeterController,
                              hintText: 'Geofence Radius',
                              labelText: 'Geofence Radius',
                              textInputType: TextInputType.number,
                              textCapitalization: TextCapitalization.words,
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    if (userEmailController.text.isNotEmpty &&
                                        userPasswordController
                                            .text.isNotEmpty &&
                                        petNameController.text.isNotEmpty &&
                                        perimeterController.text.isNotEmpty &&
                                        latController.text.isNotEmpty &&
                                        longController.text.isNotEmpty) {
                                      submitAction();
                                      //show dialog calibration successful
                                      showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              //title: const Text('Success'),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              20.0))),
                                              contentPadding:
                                                  EdgeInsets.only(top: 30.0),
                                              content: Container(
                                                height: 120,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    60,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.check_circle,
                                                      color: Colors.green,
                                                      size: 50,
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    const Text('Successful',
                                                        style: AppTextStyles
                                                            .title),
                                                    const Text(
                                                        'Device Calibration',
                                                        style:
                                                            AppTextStyles.body),
                                                  ],
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    //Navigator.pop(context);
                                                    Navigator.push(
                                                        context,
                                                        PageTransition(
                                                            type:
                                                                PageTransitionType
                                                                    .fade,
                                                            duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        500),
                                                            child:
                                                                const Navigation()));
                                                  },
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            );
                                          });
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Please fill all the fields'),
                                        ),
                                      );
                                    }
                                  },
                                  style: ButtonStyle(
                                    padding: MaterialStateProperty.all(
                                        const EdgeInsets.symmetric(
                                            vertical: 15.0, horizontal: 15.0)),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            AppColors.blue),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                    ),
                                    shadowColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.transparent),
                                  ),
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 2.8,
                                    child: Center(
                                      child: Text(
                                        'Calibrate',
                                        style: AppTextStyles.body1.copyWith(
                                          color: AppColors.white,
                                          //fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )),
    );
  }
}
