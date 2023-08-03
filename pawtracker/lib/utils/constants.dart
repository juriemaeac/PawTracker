import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const white = Colors.white;
  static const black = Color(0xFF404040);
  static const grey = Colors.grey;
  static const darkGrey = Color.fromARGB(255, 104, 104, 104);
  static const greyAccent = Color(0xffF0F0F0);
  static const greyAccentLine = Color.fromARGB(255, 218, 218, 218);

  static const pinkAccent = Color(0xffFFC8DD);
  static const pink = Color(0xffFFAFCC);
  static const lightBlue = Color(0xffBDE1FE);
  static const blue = Color(0xffA2D2FF);
  static const lightGreen = Color(0xffB2F7EF);

  static const lightPurple = Color(0xffCDB4DB);
  static const lightyellow = Color(0xffFDF3C7);
  static const lightOrange = Color(0xffFFD3B6);
  static const lightRed = Color(0xffFFB6B9);
}

class AppTextStyles {
  static const TextStyle headings1 = TextStyle(
    color: AppColors.black,
    fontSize: 30,
    fontWeight: FontWeight.w500,
    fontFamily: 'Poppins',
  );
  static const TextStyle subHeadings = TextStyle(
    color: AppColors.grey,
    fontSize: 14,
    fontFamily: 'Poppins',
  );
  static const title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    fontFamily: 'Poppins',
    color: AppColors.black,
  );
  static TextStyle headings = GoogleFonts.quicksand(
    textStyle: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w600,
      color: AppColors.black,
    ),
  );
  static TextStyle subHeadings2 = GoogleFonts.quicksand(
    textStyle: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: AppColors.black,
    ),
  );
  static TextStyle subHeadings3 = GoogleFonts.quicksand(
    textStyle: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: AppColors.black,
    ),
  );
  static TextStyle title1 = GoogleFonts.quicksand(
    textStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppColors.black,
    ),
  );
  static TextStyle subtitle = GoogleFonts.quicksand(
    textStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.black,
    ),
  );
  static TextStyle subtitle1 = GoogleFonts.quicksand(
    textStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.black,
    ),
  );
  static const body = TextStyle(
    fontSize: 14,
    fontFamily: 'Poppins',
    color: AppColors.black,
  );
  static TextStyle body1 = GoogleFonts.quicksand(
    textStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.black,
    ),
  );
  static TextStyle body2 = GoogleFonts.quicksand(
    textStyle: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: AppColors.black,
    ),
  );
  static TextStyle body3 = GoogleFonts.quicksand(
    textStyle: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: AppColors.black,
    ),
  );
  static TextStyle body4 = GoogleFonts.quicksand(
    textStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.black,
    ),
  );
  static const TextStyle textFields = TextStyle(
    color: AppColors.black,
    fontWeight: FontWeight.w500,
    fontSize: 16,
    fontFamily: 'Poppins',
  );
}
