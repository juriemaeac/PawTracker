import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pawtracker/utils/constants.dart';
import 'package:pawtracker/utils/navigation.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Navigation()));
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
            child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image(
                image: const AssetImage('assets/images/paw_loading.gif'),
                gaplessPlayback: true,
                height: height / 5,
                fit: BoxFit.fitHeight,
              ),
              const SizedBox(height: 80),
            ],
          ),
        )));
  }
}
