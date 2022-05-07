import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:realtime_quizzes/models/user.dart';

import '../../layouts/home/home.dart';
import '../../shared/shared.dart';

class SearchController extends GetxController {
  var sentFriendRequestObs = false.obs;
  var downloadState = DownloadState.INITIAL.obs;

  var errorObs = Rxn<String?>();
  var userObs = Rxn<UserModel?>();

  @override
  void onInit() {
    errorObs.listen((p0) {
      downloadState.value = DownloadState.ERROR;
    });
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
        Get.off(() => HomeScreen());
      }).onError((error, stackTrace) {
        debugPrint('Login error : ' + error.toString());
        errorObs.value = error.toString();
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        debugPrint('No user found for that email.');
        errorObs.value = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        debugPrint('Wrong password provided for that user.');
        errorObs.value = 'Wrong password provided for that user.';
      }
    }
  }

  void findUser(String user) {
    sentFriendRequestObs.value = false;
    downloadState.value = DownloadState.LOADING;
    usersCollection.doc(user).get().then((value) {
      if (value.exists) {
        userObs.value = UserModel.fromJson(value.data());
        downloadState.value = DownloadState.SUCCESS;

        if (userObs.value!.friends.contains(Shared.loggedUser?.email)) {
          errorObs.value = 'User is already a friend';
        } else if (userObs.value!.receivedFriendRequests
            .contains(Shared.loggedUser?.email)) {
          sentFriendRequestObs.value = true;
        } else if (userObs.value!.sentFriendRequests
            .contains(Shared.loggedUser?.email)) {
          errorObs.value =
              'This user already sent you a friend request, see Friends page';
        }
      } else {
        errorObs.value = 'No user found with this email address';
      }
    }).onError((error, stackTrace) {
      printError(info: 'loadUsers error' + error.toString());
      errorObs.value = error.toString();
    });
  }

  void sendFriendRequest(UserModel? friendSuggestion) {
    sentFriendRequestObs.value = true;

    //add other user to logged user sent friends requests
    usersCollection.doc(Shared.loggedUser?.email).update({
      'sentFriendRequests': FieldValue.arrayUnion([friendSuggestion?.email])
    }).then((value) {
      debugPrint("1 sentFriendRequests ");
    }).onError((error, stackTrace) {
      errorObs.value = error.toString();
      printError(info: "1 Failed sentFriendRequests: $error");
    });

    //add logged user to other user received friends requests
    usersCollection.doc(friendSuggestion?.email).update({
      'receivedFriendRequests':
          FieldValue.arrayUnion([Shared.loggedUser?.email])
    }).then((value) {
      debugPrint("1 sentFriendRequests ");
    }).onError((error, stackTrace) {
      errorObs.value = error.toString();
      printError(info: "1 Failed sentFriendRequests: $error");
    });
  }
}
