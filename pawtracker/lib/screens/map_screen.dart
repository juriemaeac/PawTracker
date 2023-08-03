import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:pawtracker/utils/constants.dart';
import 'package:pawtracker/utils/global_variable.dart';
import 'package:pawtracker/widgets/indicators.dart';
import 'package:pawtracker/widgets/snackbar.dart';
import 'package:shape_of_view_null_safe/shape_of_view_null_safe.dart';
import 'package:super_tooltip/super_tooltip.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final String apiKey = "nNpeA6MVcnH0q5w6LfXTP2uNR58WIcKI";
  final user = FirebaseAuth.instance.currentUser;
  bool hasPet = false;
  var userData = {};
  int petLen = 0;
  bool isLoading = false;
  SuperTooltip? tooltip1;
  SuperTooltip? tooltip2;
  SuperTooltip? tooltip3;
  bool visible1 = false;
  bool visible2 = false;
  String? petType;
  String? petHome;
  double homeLatitude = 0;
  double homeLongitude = 0;

  // double petHomeLatitude = 0;
  // double petHomeLongitude = 0;
  String? fencePerimeter;
  double deviceLat = 0;
  double deviceLong = 0;

  double phoneLat = 0;
  double phoneLong = 0;
  // double phoneLat = 14.276834;
  // double phoneLong = 120.734157;
  late LatLng phoneCenter = LatLng(phoneLat, phoneLong);

  List<Marker> markers = [];

  void petAddedChecker() {
    if (isPet == true) {
      hasPet = true;
    } else {
      hasPet = false;
    }
  }

  void markerVisibility() {
    final phoneCurrentCenter = LatLng(phoneLat, phoneLong);
    final homeLocationPoint = LatLng(homeLatitude, homeLongitude);
    final deviceLocationPoint = LatLng(deviceLat, deviceLong);

    print('hatdog LOCATION POINT: $phoneCurrentCenter');
    print('hatdog DEVICE LOCATION POINT: $deviceLocationPoint');
    print('hatdog HOME LOCATION POINT: $homeLocationPoint');
    if (homeLatitude > 0 && homeLongitude > 0) {
      setState(() {
        Marker marker1 = Marker(
          width: 50.0,
          height: 55.0,
          point: homeLocationPoint, //LatLng(51.5, -0.09),
          builder: (context) => Visibility(
            visible: visible1,
            child: WillPopScope(
              onWillPop: _willPopCallback2,
              child: GestureDetector(
                onTap: onTap2,
                child: ShapeOfView(
                  shape: BubbleShape(
                      position: BubblePosition.Bottom,
                      arrowPositionPercent: 0.5,
                      borderRadius: 20,
                      arrowHeight: 10,
                      arrowWidth: 10),
                  child: Container(
                    color: AppColors.white,
                    padding: const EdgeInsets.only(
                        bottom: 15, top: 5, left: 5, right: 5),
                    child: Icon(
                      Icons.home,
                      color: AppColors.blue,
                      size: 35.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        markers.add(marker1);
      });
    }
    if (deviceLat > 0 && deviceLong > 0) {
      setState(() {
        Marker marker2 = Marker(
          width: 50.0,
          height: 55.0,
          point: deviceLocationPoint, //LatLng(51.5, -0.09),
          builder: (context) => Visibility(
            visible: visible2,
            child: WillPopScope(
              onWillPop: _willPopCallback3,
              child: GestureDetector(
                onTap: onTap3,
                child: ShapeOfView(
                  shape: BubbleShape(
                      position: BubblePosition.Bottom,
                      arrowPositionPercent: 0.5,
                      borderRadius: 20,
                      arrowHeight: 10,
                      arrowWidth: 10),
                  child: Container(
                    color: AppColors.white,
                    padding: const EdgeInsets.only(
                        bottom: 15, top: 5, left: 5, right: 5),
                    child: Icon(
                      Icons.pets,
                      color: AppColors.pinkAccent,
                      size: 35.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        markers.add(marker2);
      });
    }
    Marker marker3 = Marker(
      width: 50.0,
      height: 55.0,
      point: phoneCurrentCenter, //LatLng(51.5, -0.09),
      builder: (context) => WillPopScope(
        onWillPop: _willPopCallback1,
        child: GestureDetector(
          onTap: onTap1,
          child: ShapeOfView(
            shape: BubbleShape(
                position: BubblePosition.Bottom,
                arrowPositionPercent: 0.5,
                borderRadius: 20,
                arrowHeight: 10,
                arrowWidth: 10),
            child: Container(
              color: AppColors.white,
              padding:
                  const EdgeInsets.only(bottom: 15, top: 5, left: 5, right: 5),
              child: Icon(
                Icons.person_rounded,
                color: AppColors.lightOrange,
                size: 35.0,
              ),
            ),
          ),
        ),
      ),
    );
    print('hatdog MARKER 3: $phoneCurrentCenter');
    markers.add(marker3);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //getHomeLocation();
    //_getCurrentLocation();
    deviceLat = deviceLatitudeGlobal;
    deviceLong = deviceLongitudeGlobal;
    homeLatitude = homeLatitudeGlobal;
    homeLongitude = homeLongitudeGlobal;
    petAddedChecker();
    getPets();

    //markerVisibility();
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
        isLoading = false;
      } else {
        isPetAdded = true;
        isLoading = false;
      }
      userData = userSnap.data()!;
      setState(() {});
    } catch (e) {
      showSnackBar(
        context,
        e.toString(),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<bool> _willPopCallback1() async {
    if (tooltip1!.isOpen) {
      tooltip1!.close();
      return false;
    }
    return true;
  }

  void onTap1() {
    if (tooltip1 != null && tooltip1!.isOpen) {
      tooltip1!.close();
      return;
    }

    var renderBox = context.findRenderObject() as RenderBox;
    final overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox?;

    var targetGlobalCenter = renderBox
        .localToGlobal(renderBox.size.center(Offset.zero), ancestor: overlay);

    // Tooltip between device and person
    tooltip1 = SuperTooltip(
      popupDirection: TooltipDirection.up,
      closeButtonColor: Colors.white,
      closeButtonSize: 15,
      showCloseButton: ShowCloseButton.inside,
      borderWidth: 0,
      backgroundColor: AppColors.lightOrange,
      shadowColor: Colors.transparent,
      borderColor: AppColors.lightOrange,
      arrowLength: 0,
      content: Material(
        child: Container(
          width: 200,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.lightOrange,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.person_rounded,
                color: AppColors.white,
                size: 25.0,
              ),
              const SizedBox(width: 20),
              SizedBox(
                width: 150,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "You are $distancePhonePetGlobal km away from your pet's location",
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    tooltip1!.show(context);
  }

  Future<bool> _willPopCallback2() async {
    if (tooltip2!.isOpen) {
      tooltip2!.close();
      return false;
    }
    return true;
  }

  void onTap2() {
    if (tooltip2 != null && tooltip2!.isOpen) {
      tooltip2!.close();
      return;
    }

    var renderBox = context.findRenderObject() as RenderBox;
    final overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox?;

    var targetGlobalCenter = renderBox
        .localToGlobal(renderBox.size.center(Offset.zero), ancestor: overlay);

    // Tooltip between device and person
    tooltip2 = SuperTooltip(
      popupDirection: TooltipDirection.up,
      closeButtonColor: Colors.white,
      closeButtonSize: 15,
      showCloseButton: ShowCloseButton.inside,
      borderWidth: 0,
      backgroundColor: AppColors.blue,
      shadowColor: Colors.transparent,
      borderColor: AppColors.blue,
      arrowLength: 0,
      content: Material(
        child: Container(
          width: 200,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.blue,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.home_rounded,
                color: AppColors.white,
                size: 25.0,
              ),
              const SizedBox(width: 20),
              SizedBox(
                width: 150,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "Your pet is $distancePetHomeGlobal km away from your home location.",
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    tooltip2!.show(context);
  }

  Future<bool> _willPopCallback3() async {
    if (tooltip3!.isOpen) {
      tooltip3!.close();
      return false;
    }
    return true;
  }

  void onTap3() {
    if (tooltip3 != null && tooltip3!.isOpen) {
      tooltip3!.close();
      return;
    }

    var renderBox = context.findRenderObject() as RenderBox;
    final overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox?;

    var targetGlobalCenter = renderBox
        .localToGlobal(renderBox.size.center(Offset.zero), ancestor: overlay);

    // Tooltip between device and person
    tooltip3 = SuperTooltip(
      popupDirection: TooltipDirection.up,
      closeButtonColor: Colors.white,
      closeButtonSize: 15,
      showCloseButton: ShowCloseButton.inside,
      borderWidth: 0,
      backgroundColor: AppColors.pinkAccent,
      shadowColor: Colors.transparent,
      borderColor: AppColors.pinkAccent,
      arrowLength: 0,
      content: Material(
        child: Container(
          width: 200,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.pinkAccent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.pets,
                color: AppColors.white,
                size: 25.0,
              ),
              const SizedBox(width: 20),
              SizedBox(
                width: 150,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          isPhoneLocOn
                              ? 'Your pet is $distancePhonePetGlobal km away from you and $distancePetHomeGlobal km away from your home location.'
                              : 'Your pet is $distancePetHomeGlobal km away from your home location.',
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    tooltip3!.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final phoneCurrentCenter =
        LatLng(phoneLatitudeGlobal, phoneLongitudeGlobal);
    final homeLocationPoint = LatLng(homeLatitude, homeLongitude);
    final deviceLocationPoint = LatLng(deviceLat, deviceLong);
    print("Inside Build pet: $hasPet");
    print("Inside Build added: $isPetAdded");
    print("Inside Build: $phoneCenter");
    print('PHONE DISTANCE: $distancePetHomeGlobal');
    return Scaffold(
      backgroundColor: AppColors.white,
      body: isLoading
          ? Center(
              child: Image(
                image: const AssetImage('assets/images/paw_loading.gif'),
                gaplessPlayback: true,
                height: MediaQuery.of(context).size.height / 5,
                fit: BoxFit.fitHeight,
              ),
              // CircularProgressIndicator(
              //   backgroundColor: AppColors.blue,
              // ),
            )
          : Center(
              child: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      center: isPhoneLocOn
                          ? LatLng(phoneLatitudeGlobal, phoneLongitudeGlobal)
                          : deviceLocationPoint,
                      zoom: 13.0,
                      maxZoom: 18,
                      //zoom: 13,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://api.tomtom.com/map/1/tile/basic/main/"
                            "{z}/{x}/{y}.png?key={apiKey}",
                        additionalOptions: {"apiKey": apiKey},
                      ),
                      MarkerLayer(
                        markers: //markers
                            [
                          Marker(
                            width: 50.0,
                            height: 55.0,
                            point: homeLocationPoint, //LatLng(51.5, -0.09),
                            builder: (context) => !isPetAdded
                                ? SizedBox()
                                : WillPopScope(
                                    onWillPop: _willPopCallback2,
                                    child: GestureDetector(
                                      onTap: onTap2,
                                      child: ShapeOfView(
                                        shape: BubbleShape(
                                            position: BubblePosition.Bottom,
                                            arrowPositionPercent: 0.5,
                                            borderRadius: 20,
                                            arrowHeight: 10,
                                            arrowWidth: 10),
                                        child: Container(
                                          color: AppColors.white,
                                          padding: const EdgeInsets.only(
                                              bottom: 15,
                                              top: 5,
                                              left: 5,
                                              right: 5),
                                          child: Icon(
                                            Icons.home,
                                            color: AppColors.blue,
                                            size: 35.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                          Marker(
                            width: 50.0,
                            height: 55.0,
                            point: deviceLocationPoint, //LatLng(51.5, -0.09),
                            builder: (context) => !isPetAdded
                                ? SizedBox()
                                : WillPopScope(
                                    onWillPop: _willPopCallback3,
                                    child: GestureDetector(
                                      onTap: onTap3,
                                      child: ShapeOfView(
                                        shape: BubbleShape(
                                            position: BubblePosition.Bottom,
                                            arrowPositionPercent: 0.5,
                                            borderRadius: 20,
                                            arrowHeight: 10,
                                            arrowWidth: 10),
                                        child: Container(
                                          color: AppColors.white,
                                          padding: const EdgeInsets.only(
                                              bottom: 15,
                                              top: 5,
                                              left: 5,
                                              right: 5),
                                          child: Icon(
                                            Icons.pets,
                                            color: AppColors.pinkAccent,
                                            size: 35.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                          isPhoneLocOn
                              ? Marker(
                                  width: 50.0,
                                  height: 55.0,
                                  point:
                                      phoneCurrentCenter, //LatLng(51.5, -0.09),
                                  builder: (context) => WillPopScope(
                                    onWillPop: _willPopCallback1,
                                    child: GestureDetector(
                                      onTap: !isPetAdded ? null : onTap1,
                                      child: ShapeOfView(
                                        shape: BubbleShape(
                                            position: BubblePosition.Bottom,
                                            arrowPositionPercent: 0.5,
                                            borderRadius: 20,
                                            arrowHeight: 10,
                                            arrowWidth: 10),
                                        child: Container(
                                          color: AppColors.white,
                                          padding: const EdgeInsets.only(
                                              bottom: 15,
                                              top: 5,
                                              left: 5,
                                              right: 5),
                                          child: Icon(
                                            Icons.person_rounded,
                                            color: AppColors.lightOrange,
                                            size: 35.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Marker(
                                  point: deviceLocationPoint,
                                  builder: (context) => const SizedBox()),
                        ],
                      )
                    ],
                  ),
                  !isCalibrated
                      ? SizedBox()
                      : Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            margin: const EdgeInsets.all(20),
                            padding: const EdgeInsets.all(5),
                            height: isPhoneLocOn ? 140 : 95,
                            decoration: BoxDecoration(
                              color: Colors.white, //.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                isPhoneLocOn
                                    ? Column(
                                        children: [
                                          IndicatorWidget(
                                            text:
                                                "You are $distancePhonePetGlobal km away from your pet's location",
                                            color: AppColors.lightOrange,
                                            icon: Icons.person_rounded,
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),
                                IndicatorWidget(
                                  text: isPhoneLocOn
                                      ? 'Your pet is $distancePhonePetGlobal km away from you and $distancePetHomeGlobal km away from your home location.'
                                      : 'Your pet is $distancePetHomeGlobal km away from your home location.',
                                  color: AppColors.pinkAccent,
                                  icon: Icons.pets,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                IndicatorWidget(
                                  text:
                                      "Your pet is $distancePetHomeGlobal km away from your home location.",
                                  color: AppColors.blue,
                                  icon: Icons.home_rounded,
                                ),
                              ],
                            ),
                          ),
                        ),
                ],
              ),
            ),
    );
  }
}
