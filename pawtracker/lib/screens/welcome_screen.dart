import 'package:flutter/material.dart';
import 'package:pawtracker/screens/login_screen.dart';
import 'package:pawtracker/utils/constants.dart';
import 'package:pawtracker/utils/global_variable.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Border border = Border.all(color: AppColors.greyAccentLine, width: 1);
  BoxShadow pressedShadow = const BoxShadow(
    color: Color.fromARGB(31, 49, 49, 49),
    blurRadius: 15,
    offset: Offset(0, 5),
  );
  bool isSelected1 = false;
  bool isSelected2 = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isSelected1 = !isSelected1;
                        isSelected2 = false;
                        isCat = true;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected1 ? AppColors.blue : Colors.white,
                        border: border,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isSelected1 ? [pressedShadow] : [],
                      ),
                      margin: const EdgeInsets.only(left: 20.0, top: 20.0),
                      child: Text(
                        'Cat',
                        style: AppTextStyles.body,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isSelected2 = !isSelected2;
                        isSelected1 = false;
                        isCat = false;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected2 ? AppColors.blue : Colors.white,
                        border: border,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isSelected2 ? [pressedShadow] : [],
                      ),
                      margin: const EdgeInsets.only(left: 20.0, top: 20.0),
                      child: Text(
                        'Dog',
                        style: AppTextStyles.body,
                      ),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 30.0)),
                  // backgroundColor:
                  //     MaterialStateProperty.all<Color>(Colors.blueAccent),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  shadowColor:
                      MaterialStateProperty.all<Color>(Colors.transparent),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Proceed',
                      style: AppTextStyles.body,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
