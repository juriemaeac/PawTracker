import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pawtracker/calendar/calendarItem.dart';
import 'package:pawtracker/utils/constants.dart';

class CalendarSection extends StatelessWidget {
  const CalendarSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String dateNow = DateFormat("MMMM yyyy").format(DateTime.now());
    return Column(
      children: [
        Container(
          //color: Colors.amber,
          //margin: const EdgeInsets.only(left: 30.0, right: 30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dateNow, style: AppTextStyles.subHeadings),
            ],
          ),
        ),
        Container(
          //color: Colors.pink,
          // padding: const EdgeInsets.only(
          //     left: 25.0, top: 15.0, right: 25.0, bottom: 0),
          child: Row(
            children: const [
              CalendarWeekly(),
            ],
          ),
        ),
      ],
    );
  }
}
