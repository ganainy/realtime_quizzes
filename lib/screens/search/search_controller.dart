import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:realtime_quizzes/main_controller.dart';
import 'package:realtime_quizzes/models/user.dart';

import '../../shared/shared.dart';

class SearchController extends GetxController {
  var downloadState = DownloadState.INITIAL.obs;
  var results = [].obs; //list of users
  var searchQuery = ''.obs; //input to search box

  late MainController mainController;

  @override
  void onInit() {
    mainController = Get.find<MainController>();
  }

  //find user with name or email that matches search query
  void findUserMatches() {
    downloadState.value = DownloadState.LOADING;
    usersCollection.get().then((value) {
      results.clear();
      value.docs.forEach((userDoc) {
        var user = UserModel.fromJson(userDoc.data());

        if (user.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            user.email!.toLowerCase().contains(searchQuery.toLowerCase())) {
          //set result state
          if (Shared.loggedUser!.friends.contains(user.email)) {
            user.userStatus = UserStatus.FRIEND;
          } else if (Shared.loggedUser!.sentFriendRequests
              .contains(user.email)) {
            user.userStatus = UserStatus.RECEIVED_FRIEND_REQUEST;
          } else if (Shared.loggedUser!.receivedFriendRequests
              .contains(user.email)) {
            user.userStatus = UserStatus.SENT_FRIEND_REQUEST;
          } else {
            user.userStatus = UserStatus.NOT_FRIEND;
          }
          if (user.email != Shared.loggedUser?.email) {
            results.value.add(user); //only add if not the logged user
          }
        }
      });
      if (results.isEmpty) {
        downloadState.value = DownloadState.EMPTY;
      } else {
        downloadState.value = DownloadState.SUCCESS;
      }
    }).catchError((error) {
      mainController.errorDialog(error.toString());
      downloadState.value = DownloadState.INITIAL;
    });
  }

  //send friend request or accept friend request or something else based on result status
  void interactWithUser(UserModel? result) {
    if (result?.userStatus == null) {
      Exception("User status is null");
    } else if (result!.userStatus == UserStatus.FRIEND) {
      mainController.errorDialog('User is already your friend');
    } else if (result.userStatus == UserStatus.RECEIVED_FRIEND_REQUEST) {
      mainController
          .errorDialog('You already sent friend request to this user');
    } else if (result.userStatus == UserStatus.SENT_FRIEND_REQUEST) {
      acceptFriendRequest(result);
    } else {
      sendFriendRequest(result);
    }
  }

  void acceptFriendRequest(UserModel? result) {
    //add to logged user friends ,
    usersCollection.doc(Shared.loggedUser?.email).update({
      'friends': FieldValue.arrayUnion([result?.email])
    }).then((value) {
      debugPrint("1 added to friends");
      findUserMatches();
    }).onError((error, stackTrace) {
      mainController.errorDialog(error.toString());
      printError(info: "1 Failed add to friends: $error");
    });
    //remove from received friend requests of logged user
    usersCollection.doc(Shared.loggedUser?.email).update({
      'receivedFriendRequests': FieldValue.arrayRemove([result?.email])
    }).then((value) {
      debugPrint("2 removed from receivedFriendRequests");
    }).onError((error, stackTrace) {
      mainController.errorDialog(error.toString());
      printError(info: "2 Failed remove from receivedFriendRequests: $error");
    });
    //remove from sent friend requests of result user
    usersCollection.doc(result?.email).update({
      'sentFriendRequests': FieldValue.arrayRemove([Shared.loggedUser?.email])
    }).then((value) {
      debugPrint("3 removed from sentFriendRequests");
    }).onError((error, stackTrace) {
      mainController.errorDialog(error.toString());
      printError(info: "3 Failed remove from sentFriendRequests: $error");
    });
  }

  void sendFriendRequest(UserModel? result) {
    //add other user to logged user sent friends requests
    usersCollection.doc(Shared.loggedUser?.email).update({
      'sentFriendRequests': FieldValue.arrayUnion([result?.email])
    }).then((value) {
      debugPrint("1 sentFriendRequests ");
      findUserMatches();
    }).onError((error, stackTrace) {
      mainController.errorDialog(error.toString());
      printError(info: "1 Failed sentFriendRequests: $error");
    });

    //add logged user to other user received friends requests
    usersCollection.doc(result?.email).update({
      'receivedFriendRequests':
          FieldValue.arrayUnion([Shared.loggedUser?.email])
    }).then((value) {
      debugPrint("1 sentFriendRequests ");
    }).onError((error, stackTrace) {
      mainController.errorDialog(error.toString());
      printError(info: "1 Failed sentFriendRequests: $error");
    });
  }
}
