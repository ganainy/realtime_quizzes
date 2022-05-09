import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../main_controller.dart';
import '../../models/user.dart';
import '../../shared/shared.dart';

//todo improve ui(percentages of screen),
//todo flag that game is running so no one enters
//todo terminate game on user offline or didnt answer 3 in a row
//todo add search by name also with shimmer effect
//todo charts in history screen
//todo after signup or login new account new user is not loaded

class FriendsController extends GetxController {
  var friendsObs = [].obs; //list of UserModel

  StreamSubscription? queueEntryListener;
  late MainController mainController;
  @override
  void onInit() {}

  addUniqueUser(
      {userModelListObs: Rxn<List<UserModel>>, userModel: UserModel}) {
    var list = userModelListObs.value;

    bool isUnique = true;
    list.forEach((listItem) {
      if (listItem.email == userModel.email) {
        isUnique = false;
      }
    });
    if (isUnique) {
      list.add(userModel);
      userModelListObs.refresh();
    }
  }

  loadFriends() {
    friendsObs.value.clear();

    Shared.loggedUser?.friends.forEach((friendId) {
      usersCollection.doc(friendId).get().then((value) {
        var friend = UserModel.fromJson(value.data());
        /* addUniqueUser(userModelListObs: friendsObs, userModel: friend);*/
        friendsObs.value.add(friend);
        friendsObs.refresh();

        debugPrint('success single loadFriend profile');
      }).onError((error, stackTrace) {
        printError(info: 'error single loadFriend profile' + error.toString());
        mainController.errorDialog(error.toString());
      });
    });
  }

  void sendFriendRequest(UserModel? friendSuggestion) {
    //add other user to logged user sent friends requests
    usersCollection.doc(Shared.loggedUser?.email).update({
      'sentFriendRequests': FieldValue.arrayUnion([friendSuggestion?.email])
    }).then((value) {
      debugPrint("1 sentFriendRequests ");
    }).onError((error, stackTrace) {
      mainController.errorDialog(error.toString());
      printError(info: "1 Failed sentFriendRequests: $error");
    });

    //add logged user to other user received friends requests
    usersCollection.doc(friendSuggestion?.email).update({
      'receivedFriendRequests':
          FieldValue.arrayUnion([Shared.loggedUser?.email])
    }).then((value) {
      debugPrint("1 sentFriendRequests ");
    }).onError((error, stackTrace) {
      mainController.errorDialog(error.toString());
      printError(info: "1 Failed sentFriendRequests: $error");
    });
  }

  void acceptFriendRequest(UserModel incomingFriendRequest) {
    /* receivedFriendRequestsObs.value.remove(incomingFriendRequest);
    receivedFriendRequestsObs.refresh();*/

    //add other user to logged user friends
    usersCollection.doc(Shared.loggedUser?.email).update({
      'friends': FieldValue.arrayUnion([incomingFriendRequest.email])
    }).then((value) {
      debugPrint("acceptFriendRequest ");
    }).onError((error, stackTrace) {
      mainController.errorDialog(error.toString());
      printError(info: "Failed to acceptFriendRequest: $error");
    });

    //add logged user to other user friends
    usersCollection.doc(incomingFriendRequest.email).update({
      'friends': FieldValue.arrayUnion([Shared.loggedUser?.email])
    }).then((value) {
      debugPrint("2 acceptFriendRequest ");
    }).onError((error, stackTrace) {
      mainController.errorDialog(error.toString());
      printError(info: "2 Failed to acceptFriendRequest: $error");
    });

    //remove received friend request
    usersCollection.doc(Shared.loggedUser?.email).update({
      'receivedFriendRequests':
          FieldValue.arrayRemove([incomingFriendRequest.email])
    }).then((value) {
      debugPrint("3 acceptFriendRequest ");
    }).onError((error, stackTrace) {
      mainController.errorDialog(error.toString());
      printError(info: "3 Failed to acceptFriendRequest: $error");
    });

    //remove sent friend request
    usersCollection.doc(incomingFriendRequest.email).update({
      'sentFriendRequests': FieldValue.arrayRemove([Shared.loggedUser?.email])
    }).then((value) {
      debugPrint("4 acceptFriendRequest ");
    }).onError((error, stackTrace) {
      mainController.errorDialog(error.toString());
      printError(info: "4 Failed to acceptFriendRequest: $error");
    });
  }

  void removeFriendRequest(UserModel incomingFriendRequest) {
    /*  receivedFriendRequestsObs.value.remove(incomingFriendRequest);
    receivedFriendRequestsObs.refresh();*/

    Shared.loggedUser?.removedRequests.add(incomingFriendRequest.email);
    //add other user to logged user friends
    usersCollection
        .doc(Shared.loggedUser?.email)
        .update(userModelToJson(Shared.loggedUser))
        .then((value) {
      debugPrint("removeFriendRequest ");
    }).onError((error, stackTrace) {
      mainController.errorDialog(error.toString());
      printError(info: "Failed to removeFriendRequest: $error");
    });
  }

  //update friends state to show online or offline
  void observeFriendsStatus() {
    debugPrint('observeFriendsStatus');

    Shared.loggedUser?.friends.forEach((friendId) {
      usersCollection.doc(friendId).snapshots().listen((event) {
        debugPrint('listenting to friends');
        var friend = UserModel.fromJson(event.data());
        //update online status
        friendsObs.value
            .firstWhere((element) => element.email == friend.email)
            .isOnline = friend.isOnline;
        friendsObs.refresh();
      }).onError((error) {
        mainController.errorDialog(error.toString());
        debugPrint('error listening to friends');
      });
    });
  }
}
