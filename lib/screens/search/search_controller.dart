import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:realtime_quizzes/main_controller.dart';
import 'package:realtime_quizzes/models/user.dart';
import 'package:realtime_quizzes/shared/components.dart';

import '../../models/UserStatus.dart';
import '../../models/download_state.dart';
import '../../shared/shared.dart';

class SearchController extends GetxController {
  var downloadStateObs = DownloadState.INITIAL.obs;
  var queryResultsObs = [].obs; //list of users
  var searchQueryObs = ''.obs; //input to search box

  late MainController mainController;

  @override
  void onReady() {
    super.onReady();
    mainController = Get.find<MainController>();
  }

  //whenever logged user connections are updated, update the queryResultsObs
  //so that in case queryResultsObs are also logged user connections, latest state will be displayed
  void updateQueryResultsState() {
    debugPrint('updateQueryResultsState');

    if (queryResultsObs.value.isEmpty) {
      return;
    }

    queryResultsObs.value.forEach((queryResult) {
      for (var connection in Shared.loggedUser!.connections) {
        /* queryResultsObs.value
              .firstWhere((element) => element.email == queryResult.email)
              .userStatus = connection.userStatus;*/
        var index = queryResultsObs.value.indexOf(queryResultsObs.value
            .firstWhereOrNull(
                (queryResult) => queryResult.email == connection!.email));
        queryResultsObs.value.update(index, queryResult);
      }
    });

    queryResultsObs.refresh();
  }

  //find user with name or email that matches search query
  void findUserMatches() {
    downloadStateObs.value = DownloadState.LOADING;
    usersCollection.get().then((value) {
      queryResultsObs.clear();
      queryResultsObs.refresh();
      value.docs.forEach((userDoc) {
        var user = UserModel.fromJson(userDoc.data());

        if (user.email == Shared.loggedUser?.email)
          return; //don't show logged user

        if (user.name.toLowerCase().contains(searchQueryObs.toLowerCase()) ||
            user.email!.toLowerCase().contains(searchQueryObs.toLowerCase())) {
          //set status of each friend
          var connection =
              Shared.loggedUser!.connections.firstWhere((connection) {
            return connection?.email == user.email;
          }, orElse: () => null);
          /*if (connection != null) {
            //user is friend or sent request or received request or removed
            user.userStatus = connection.userStatus;
          } else {
            //user is not friend
            user.userStatus = UserStatus.NOT_FRIEND;
          }*/
          queryResultsObs.value.add(user);
          queryResultsObs.refresh();
        }
      });
      if (queryResultsObs.isEmpty) {
        downloadStateObs.value = DownloadState.EMPTY;
      } else {
        downloadStateObs.value = DownloadState.SUCCESS;
      }
    }).catchError((error) {
      mainController.errorDialog(error.toString());
      downloadStateObs.value = DownloadState.INITIAL;
    });
  }

  //send friend request or accept friend request or something else based on other user status
  void interactWithUser(UserModel? user, UserStatus? status) {
    if (status == null) {
      Exception("User status is null");
    } else if (status == UserStatus.FRIEND) {
      mainController.errorDialog(
        'User is already your friend',
      );
    } else if (status == UserStatus.RECEIVED_FRIEND_REQUEST) {
      mainController.acceptFriendRequest(user);
    } else if (status == UserStatus.SENT_FRIEND_REQUEST) {
      mainController.errorDialog(
        'You already sent friend request to this user',
      );
    } else if (status == UserStatus.NOT_FRIEND) {
      mainController.sendFriendRequest(user);
    }
  }
}
