import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:realtime_quizzes/customization/theme.dart';

import '../../screens/find_game/find_game.dart';
import '../../screens/friends/friends.dart';
import '../../screens/profile/profile.dart';
import '../../screens/search/search.dart';
import 'home_controller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final PageController pageController = PageController();
  HomeController homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quizzes'),
          actions: [
            homeController.bottomSelectedIndex.value == 1
                ? InkWell(
                    onTap: () {
                      Get.to(() => SearchScreen());
                    },
                    child: Container(
                        margin: EdgeInsets.all(smallPadding),
                        child: Icon(Icons.group_add)),
                  )
                : const SizedBox()
          ],
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
    });
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
