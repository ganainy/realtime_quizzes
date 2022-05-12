import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../layouts/home/home.dart';
import '../../main_controller.dart';
import '../../models/user.dart';
import '../../shared/shared.dart';

class LoginController extends GetxController {
  var isPasswordVisible = false.obs;
  var downloadState = DownloadState.INITIAL.obs;

  late MainController mainController;
  @override
  void onInit() {
    mainController = Get.find<MainController>();
  }

  changePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  login({
    required String email,
    required String password,
  }) {
    downloadState.value = DownloadState.LOADING;

    try {
      FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) {
        //user logged successfully, save user to info to db
        Shared.loggedUser = UserModel(email: auth.currentUser?.email);
        Get.off(() => HomeScreen());
      }).onError((error, stackTrace) {
        debugPrint('Login error : ' + error.toString());
        mainController.errorDialog(error.toString());
        downloadState.value = DownloadState.INITIAL;
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        debugPrint('No user found for that email.');
        mainController.errorDialog('No user found for that email.');
        downloadState.value = DownloadState.INITIAL;
      } else if (e.code == 'wrong-password') {
        debugPrint('Wrong password provided for that user.');
        mainController.errorDialog('Wrong password provided for that user.');
        downloadState.value = DownloadState.INITIAL;
      }
    }
  }
}
