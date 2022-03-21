import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../layouts/home/home.dart';
import '../../models/user.dart';
import '../../shared/shared.dart';

class RegisterController extends GetxController {
  // var timerCounter = Rxn<int>();

  var isPasswordVisible = false.obs;
  var downloadState = DownloadState.INITIAL.obs;

  changePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  register({
    required String name,
    required String email,
    required String password,
    String? imageUrl,
  }) {
    downloadState.value = DownloadState.LOADING;
    try {
      FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) {
        //user created successfully, save user to info to db
        UserModel user = UserModel(name, email, imageUrl);
        usersCollection.doc(user.email).set(user).then((value) {
          debugPrint('firestore success : ');
          downloadState.value = DownloadState.SUCCESS;

          Get.to(() => HomeScreen());
        }).onError((error, stackTrace) {
          debugPrint('firestore error : ' + error.toString());
          downloadState.value = DownloadState.ERROR;
        });
      }).onError((error, stackTrace) {
        debugPrint('Register error : ' + error.toString());
        downloadState.value = DownloadState.ERROR;
      });
    } on FirebaseAuthException catch (e) {
      downloadState.value = DownloadState.ERROR;
      if (e.code == 'weak-password') {
        debugPrint('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        debugPrint('The account already exists for that email.');
      }
    } catch (e) {
      downloadState.value = DownloadState.ERROR;
      debugPrint(e.toString());
    }
  }
}
