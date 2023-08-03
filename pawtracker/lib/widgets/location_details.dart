import 'package:flutter/material.dart';
import 'package:pawtracker/utils/constants.dart';

class DetailsCard extends StatelessWidget {
  String? label;
  String? value;
  IconData? icon;
  Border? border;
  Color? color;
  List<BoxShadow>? boxShadow;
  DetailsCard(
      {this.label,
      this.value,
      this.color,
      this.icon,
      this.border,
      this.boxShadow});

  @override
  Widget build(BuildContext context) {
    return Container(
        //padding: const EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width / 4,
        height: MediaQuery.of(context).size.width / 4,
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: border,
            boxShadow: boxShadow),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 10, top: 10, left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ],
              ),
            ),
            Text(value!,
                style: AppTextStyles.body4, overflow: TextOverflow.clip),
            Container(
              margin: const EdgeInsets.only(right: 10, left: 10, bottom: 10),
              padding: const EdgeInsets.all(5),
              width: MediaQuery.of(context).size.width / 4 - 16,
              decoration: BoxDecoration(
                color: AppColors.greyAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  label!,
                  style: AppTextStyles.body3.copyWith(color: AppColors.grey),
                ),
              ),
            ),
          ],
        ));
  }
}
