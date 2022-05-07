import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:image_picker/image_picker.dart';

import '../../layouts/home/home.dart';
import '../../main_controller.dart';
import '../../models/user.dart';
import '../../shared/shared.dart';

class RegisterController extends GetxController {
  var pickedImageObs = Rxn<File?>();
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
        saveUserToFirestore(name, email).then((value) {
          if (pickedImageObs.value == null) {
            downloadState.value = DownloadState.SUCCESS;
            Get.to(() => HomeScreen());
          } else {
            uploadImage(email).then((value) {
              getImageDownloadURL(value).then((value) {
                updateUserImageUrl(email, value).then((value) {
                  downloadState.value = DownloadState.SUCCESS;
                  Get.to(() => HomeScreen());
                }).onError((error, stackTrace) {
                  debugPrint('updateUserImageUrl error : ' + error.toString());
                  mainController.errorDialog(error.toString());
                });
              }).onError((error, stackTrace) {
                debugPrint('getImageDownloadURL error : ' + error.toString());
                mainController.errorDialog(error.toString());
              });
            }).onError((error, stackTrace) {
              debugPrint('uploadImage error : ' + error.toString());
              mainController.errorDialog(error.toString());
            });
          }
        }).onError((error, stackTrace) {
          debugPrint('saveUserToFirestore error : ' + error.toString());
          mainController.errorDialog(error.toString());
        });
      }).onError((error, stackTrace) {
        debugPrint(
            'createUserWithEmailAndPassword error : ' + error.toString());
        mainController.errorDialog(error.toString());
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        debugPrint('The password provided is too weak.');
        mainController.errorDialog('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        debugPrint('The account already exists for that email.');
        mainController
            .errorDialog('The account already exists for that email.');
      }
    } catch (error) {
      mainController.errorDialog(error.toString());

      debugPrint(error.toString());
    }
  }

  getImageFromGallery() async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );

    if (pickedFile != null) {
      pickedImageObs.value = File(pickedFile.path);
    }
  }

  Future<TaskSnapshot> uploadImage(String? email) async {
    //upload image to firebase storage
    return await storage
        .ref()
        .child(
            'users/${Uri.file(pickedImageObs.value!.path).pathSegments.last}')
        .putFile(pickedImageObs.value!);
  }

  Future<String> getImageDownloadURL(TaskSnapshot imageSnapshot) async {
    return await imageSnapshot.ref.getDownloadURL();
  }

  Future<void> updateUserImageUrl(String? userEmail, String? imageUrl) async {
    return await usersCollection.doc(userEmail).update({'imageUrl': imageUrl});
  }

  Future<void> saveUserToFirestore(
    String name,
    String email,
  ) async {
    UserModel user = UserModel(name: name, email: email);
    await usersCollection.doc(user.email).set(userModelToJson(user));
  }
}
