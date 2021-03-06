import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:realtime_quizzes/customization/theme.dart';
import 'package:realtime_quizzes/screens/games/games_screen.dart';
import 'package:realtime_quizzes/screens/search/search.dart';

import '../../screens/friends/friends.dart';
import '../../screens/profile/profile.dart';
import 'home_controller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  HomeController homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        /*appBar: AppBar(
          title: const Text('Quizzes'),
        ),*/
        body: buildPageView(),
        bottomNavigationBar: Obx(() {
          return BottomNavigationBar(
            selectedItemColor: darkText,
            unselectedItemColor: darkBg,
            currentIndex: homeController.bottomSelectedIndex.value,
            items: buildBottomNavBarItems(),
            onTap: ((index) {
              homeController.navigateBottomsheet(index);
            }),
          );
        }),
      ),
    );
  }

  List<BottomNavigationBarItem> buildBottomNavBarItems() {
    return [
      const BottomNavigationBarItem(
        icon: Icon(Icons.widgets_rounded),
        label: 'Game',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.supervised_user_circle_outlined),
        label: 'Friends',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.account_circle),
        label: 'Profile',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.search),
        label: 'Discover',
      ),
    ];
  }

  Widget buildPageView() {
    return PageView(
      controller: homeController.pageController,
      onPageChanged: (index) {
        homeController.bottomSelectedIndex.value = index;
      },
      children: <Widget>[
        GamesScreen(),
        FriendsScreen(),
        ProfileScreen(),
        SearchScreen(),
      ],
    );
  }
}
