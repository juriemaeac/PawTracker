import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pawtracker/utils/constants.dart';

class IndicatorWidget extends StatelessWidget {
  String? text;
  Color? color;
  IconData? icon;

  IndicatorWidget({super.key, this.text, this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: color,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              // contentPadding:
              //     const EdgeInsets.only(top: 30.0, right: 30, left: 30),
              //title:
              content: Container(
                width: 300,
                height: 100,
                decoration: BoxDecoration(
                  color: color,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            icon,
                            color: AppColors.white,
                            size: 25.0,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(text!,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.white,
                          )),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                // ignore: deprecated_member_use
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(false); //Will not exit the App
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 30.0,
                      bottom: 20,
                    ),
                    child: Text(
                      'OK',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: AppColors.white,
        ),
      ),
    );
  }
}
