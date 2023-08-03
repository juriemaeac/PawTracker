import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pawtracker/screens/home_screen.dart';
import 'package:pawtracker/screens/map_screen.dart';
import 'package:pawtracker/screens/profile_screen.dart';

const webScreenSize = 600;

bool isCalibrated = false;

bool isCat = false;
String assistantName = "Cooper";
bool isPetAdded = false;
bool isPet = false;
String petNameGlobal = "";
double deviceLatitudeGlobal = 0;
double deviceLongitudeGlobal = 0;
//character limit device latlong
String deviceLatGlobal = "";
String deviceLongGlobal = "";
String deviceAddressGlobal = "";
double homeLatitudeGlobal = 0;
double homeLongitudeGlobal = 0;
int geofenceRadiusGlobal = 0;
String perimeterGlobal = "";
String altitudeGlobal = "";
String speedGlobal = "";
double phoneLatitudeGlobal = 0;
double phoneLongitudeGlobal = 0;
String phoneAddressGlobal = "";
String petHomeAddressGlobal = "";
String mapLinkGlobal = "";
String distancePetHomeGlobal = "";
String distancePhonePetGlobal = "";
bool isPhoneLocOn = false;

List<Widget> homeScreenItems = [
  const HomeScreen(),
  const MapScreen(),
  const ProfileScreen(),
];
