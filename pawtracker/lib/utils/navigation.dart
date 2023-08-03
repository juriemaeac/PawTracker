import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:pawtracker/utils/constants.dart';
import 'package:pawtracker/utils/global_variable.dart';

class Navigation extends StatefulWidget {
  const Navigation({Key? key}) : super(key: key);

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _page = 0;
  late PageController pageController; // for tabs animation

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    //Animating Page
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    Color color;
    if (_page == 0) {
      color = AppColors.white;
    } else if (_page == 1) {
      color = AppColors.white;
    } else if (_page == 2) {
      color = AppColors.pinkAccent;
    } else {
      color = AppColors.white;
    }
    return Scaffold(
      backgroundColor: color,
      body: PageView(
        children: homeScreenItems,
        controller: pageController,
        onPageChanged: onPageChanged,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 15),
        decoration: const BoxDecoration(
          color: AppColors.blue,
          borderRadius: BorderRadius.all(
            Radius.circular(18),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
            child: GNav(
              rippleColor: AppColors.grey[300]!,
              hoverColor: AppColors.grey[100]!,
              gap: 8,
              activeColor: AppColors.blue,
              iconSize: 20,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: AppColors.white,
              color: AppColors.white,
              textStyle: AppTextStyles.body.copyWith(
                color: AppColors.blue,
              ),
              tabBorderRadius: 13,
              tabs: const [
                GButton(
                  icon: Icons.home_rounded,
                  text: 'Home',
                ),
                GButton(
                  icon: Icons.location_on_rounded,
                  text: 'Map',
                ),
                GButton(
                  icon: Icons.pets_rounded,
                  text: 'Profile',
                ),
              ],
              selectedIndex: _page,
              onTabChange: navigationTapped,
            ),
          ),
        ),
      ),
    );
  }
}
