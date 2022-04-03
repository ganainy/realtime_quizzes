import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../layouts/home/home_controller.dart';
import '../../screens/find_game/find_game.dart';
import '../../screens/friends/friends.dart';
import '../../screens/profile/profile.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final HomeController homeController = Get.put(HomeController());
  /*..getQuizzes()
    ..observeInvites();*/

  final PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quizzes'),
      ),
      body: buildPageView(),
      bottomNavigationBar: Obx(() {
        return BottomNavigationBar(
          currentIndex: homeController.bottomSelectedIndex.value,
          items: buildBottomNavBarItems(),
          onTap: ((index) {
            homeController.bottomSelectedIndex.value = index;
            pageController.animateToPage(index,
                duration: Duration(milliseconds: 500), curve: Curves.ease);
          }),
        );
      }),
    );
  }

  List<BottomNavigationBarItem> buildBottomNavBarItems() {
    return [
      BottomNavigationBarItem(
        icon: new Icon(Icons.widgets_rounded),
        label: 'Game',
      ),
      BottomNavigationBarItem(
        icon: new Icon(Icons.supervised_user_circle_outlined),
        label: 'Friends',
      ),
      BottomNavigationBarItem(
        icon: new Icon(Icons.account_circle),
        label: 'Profile',
      ),
    ];
  }

  Widget buildPageView() {
    return PageView(
      controller: pageController,
      onPageChanged: (index) {
        homeController.bottomSelectedIndex.value = index;
      },
      children: <Widget>[
        FindGameScreen(),
        FriendsScreen(),
        ProfileScreen(),
      ],
    );
  }
}
