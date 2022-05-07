import 'package:get/get.dart';
import 'package:realtime_quizzes/main_controller.dart';

class HomeController extends GetxController {
  var bottomSelectedIndex = 0.obs;

  late MainController mainController;
  @override
  void onInit() {
    mainController = Get.find<MainController>();
    mainController.observeProfileChanges();
  }
}
