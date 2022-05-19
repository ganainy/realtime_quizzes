import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:realtime_quizzes/main_controller.dart';

class HomeController extends GetxController {
  var bottomSelectedIndex = 0.obs;

  late MainController mainController;
  late PageController pageController;

  @override
  void onInit() {
    try {
      mainController = Get.find<MainController>();
    } catch (e) {
      mainController = Get.put(MainController());
    }
    pageController = PageController();
    mainController.observeProfileChanges();
  }

  void navigateBottomsheet(int index) {
    bottomSelectedIndex.value = index;
    pageController.animateToPage(index,
        duration: Duration(milliseconds: 500), curve: Curves.ease);
  }
}
