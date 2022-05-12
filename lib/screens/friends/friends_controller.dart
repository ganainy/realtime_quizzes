import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:realtime_quizzes/models/UserStatus.dart';
import 'package:realtime_quizzes/shared/components.dart';

import '../../main_controller.dart';
import '../../models/user.dart';
import '../../shared/shared.dart';

//todo improve ui(percentages of screen),
//todo flag that game is running so no one enters
//todo terminate game on user offline or didnt answer 3 in a row
//todo charts in history screen

class FriendsController extends GetxController {
  var receivedFriendRequestsObs = [].obs; //list of UserModel
  var friendsObs = [].obs; //list of UserModel

  StreamSubscription? queueEntryListener;
  late MainController mainController;
  @override
  void onInit() {}

  loadConnections() {
//load received friend requests
    receivedFriendRequestsObs.value.clear();
    receivedFriendRequestsObs.refresh();

    Shared.loggedUser?.connections
        .where((connection) =>
            connection?.userStatus == UserStatus.RECEIVED_FRIEND_REQUEST)
        .forEach((connection) {
      usersCollection.doc(connection?.email).get().then((value) {
        var receivedFriendRequest = UserModel.fromJson(value.data());
        receivedFriendRequestsObs.value.add(receivedFriendRequest);
        receivedFriendRequestsObs.refresh();
        debugPrint('success single load receivedFriendRequest ');
      }).onError((error, stackTrace) {
        printError(
            info: 'error single load receivedFriendRequest' + error.toString());
        mainController.errorDialog(error.toString());
      });
    });
    //load friends, listen to their online/offline status
    friendsObs.value.clear();
    friendsObs.refresh();

    Shared.loggedUser?.connections
        .where((connection) => connection?.userStatus == UserStatus.FRIEND)
        .forEach((connection) {
      usersCollection.doc(connection?.email).snapshots().listen((event) {
        var friend = UserModel.fromJson(event.data());

        addOrUpdateFriend(friend);
        friendsObs.refresh();
        debugPrint('success single loadFriend profile');
      }).onError((error, stackTrace) {
        printError(info: 'error single loadFriend profile' + error.toString());
        mainController.errorDialog(error.toString());
      });
    });
  }

  void addOrUpdateFriend(UserModel friendUpdated) {
    var index = friendsObs.value.indexOf(friendsObs.value
        .firstWhereOrNull((friend) => friend.email == friendUpdated.email));

    bool isNotDeletedConnection = false;
    Shared.loggedUser!.connections.forEach((connection) {
      if (connection?.email == friendUpdated.email &&
          connection?.userStatus == UserStatus.FRIEND) {
        isNotDeletedConnection = true;
      }
    });

    if (!isNotDeletedConnection) {
      return; //if friend is already deleted, dont add or update
    }

    if (index == -1) {
      //friend is not in list, add it
      friendsObs.value.add(friendUpdated);
      return;
    }

    //friend is already in list, update it
    friendsObs.value.update(index, friendUpdated);
  }
}
