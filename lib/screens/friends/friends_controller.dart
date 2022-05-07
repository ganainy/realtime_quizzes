import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../main_controller.dart';
import '../../models/user.dart';
import '../../shared/shared.dart';

//todo here: remove redundant code, improve ui(percentages of screen),
//todo move user listen to home and make it update shared logged user
//todo flag that game is running so no one enters
//todo terminate game on user offline or didnt answer 3 in a row
//todo add search by name also with shimmer effect
//todo charts in history screen

class FriendsController extends GetxController {
  var friendsObs = [].obs; //list of UserModel
  var friendSuggestionsObs = [].obs; //list of UserModel
  var receivedFriendRequestsObs = [].obs;

  StreamSubscription? queueEntryListener;
  late MainController mainController;
  @override
  void onInit() {
    mainController = Get.find<MainController>();
    addListeners();
  }

  //
  Function eq = const ListEquality().equals;
  var receivedFriendRequestsIdsObs = Rxn<List<dynamic>?>(); //list of String
  var friendsObsIdsObs = Rxn<List<dynamic>?>(); //list of String

  addListeners() {
    mainController.userObs.listen((loggedUser) {
      //load friends , suggestions , friend requests

      loadFriendSuggestions();

      //only fetch friends again if there is difference than already showing friends
      if (!eq(friendsObsIdsObs.value, loggedUser?.friends)) {
        debugPrint(' loadFriends()');
        loadFriends();
        observeFriendsStatus();
        friendsObsIdsObs.value = loggedUser?.friends;
      }

      if (!eq(receivedFriendRequestsIdsObs.value,
          loggedUser?.receivedFriendRequests)) {
        debugPrint('receivedFriendRequests()');
        loadFriendRequests();
        receivedFriendRequestsIdsObs.value = loggedUser?.receivedFriendRequests;
      }
    });
  }

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
    friendsObs.refresh();

    Shared.loggedUser?.friends.forEach((friendId) {
      usersCollection.doc(friendId).get().then((value) {
        var friend = UserModel.fromJson(value.data());
        addUniqueUser(userModelListObs: friendsObs, userModel: friend);
        debugPrint('success single loadFriend profile');
      }).onError((error, stackTrace) {
        printError(info: 'error single loadFriend profile' + error.toString());
        mainController.errorDialog(error.toString());
      });
    });
  }

  loadFriendSuggestions() {
    //listen to changes to logged user and update friend suggestion
    //(to prevent suggestions to be also in incoming friend requests)
    usersCollection.limit(10).get().then((value) {
      friendSuggestionsObs.value.clear();
      friendSuggestionsObs.refresh();

      value.docs.forEach((element) {
        var userModel = UserModel.fromJson(element.data());

        //don't show in suggestions if in pending state (in received or sent) or already friend
        if (Shared.loggedUser!.friends.contains(userModel.email)) {
          if (Shared.loggedUser!.receivedFriendRequests
              .contains(userModel.email)) {
            if (Shared.loggedUser!.sentFriendRequests
                .contains(userModel.email)) {
              //don't show the user himself in suggestions
              if (userModel.email != Shared.loggedUser!.email) {
                //don't add suggestion if already in suggestions
                if (!friendSuggestionsObs.value.contains(userModel)) {
                  friendSuggestionsObs.value.add(userModel);
                  friendSuggestionsObs.refresh();
                  debugPrint('success friend suggestion added');
                }
              }
            }
          }
        }
      });
    }).onError((error, stackTrace) {
      printError(info: 'error loadFriendSuggestions' + error.toString());
      mainController.errorDialog(error.toString());
    });
  }

  loadFriendRequests() {
    //get ids of users who sent friend requests

    receivedFriendRequestsObs.value.clear();
    receivedFriendRequestsObs.refresh();

    //get full profile of each user who sent friend request
    Shared.loggedUser?.receivedFriendRequests.forEach((receivedFriendRequest) {
      usersCollection.doc(receivedFriendRequest).get().then((value) {
        var friendRequest = UserModel.fromJson(value.data());
        addUniqueUser(
            userModelListObs: receivedFriendRequestsObs,
            userModel: friendRequest);
        debugPrint('success single loadFriendRequest profile');
      }).onError((error, stackTrace) {
        mainController.errorDialog(error.toString());
        printError(
            info: 'error single loadFriendRequest profile' + error.toString());
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

  void deleteFriend(UserModel friend) {
    /* friendsObs.value.remove(friend);
    friendsObs.refresh();*/

    //remove other user from logged user friends
    usersCollection.doc(Shared.loggedUser?.email).update({
      'friends': FieldValue.arrayRemove([friend.email])
    }).then((value) {
      debugPrint("1 deleteFriend ");
    }).onError((error, stackTrace) {
      mainController.errorDialog(error.toString());
      printError(info: "1 Failed to deleteFriend: $error");
    });

    //remove logged user from other user friends
    usersCollection.doc(friend.email).update({
      'friends': FieldValue.arrayRemove([Shared.loggedUser?.email])
    }).then((value) {
      debugPrint("2 deleteFriend ");
    }).onError((error, stackTrace) {
      mainController.errorDialog(error.toString());
      printError(info: "2 Failed to deleteFriend: $error");
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

  /*

    sentInviteQueueEntryModelObs.value = queueEntryModel;*/

  /*void uploadQuiz(List<QuestionModel> questions, UserModel friend,
      List<PlayerModel> players) {
    //scenario 1
    sentInviteQueueEntryModelObs.value?.questions = questions;
    sentInviteQueueEntryModelObs.value?.createdAt =
        DateTime.now().millisecondsSinceEpoch;
    //upload quiz to firestore
    invitesCollection
        .doc(sentInviteQueueEntryModelObs.value?.queueEntryId)
        .set(queueEntryModelToJson(sentInviteQueueEntryModelObs.value))
        .then((value) {
      loadOtherPlayerProfile(players, friend).then((value) {
        sendGameInvite(friend);
      });
    }).onError((error, stackTrace) {
      mainController.errorDialog(error.toString());
      printError(info: 'firestore add questions error : ' + error.toString());
    });
  }*/

  /*void startGame() {
    //scenario 1,2
    queueEntryListener?.cancel();
    Get.to(() => MultiPlayerQuizScreen(),
        arguments: (sentInviteQueueEntryModelObs.value));
  }*/

  ///-----------Scenario 2, user accept invite from friend-------------

  /*Future<void> loadOtherPlayerProfile(
      List<PlayerModel> players, UserModel friend) async {
    //add the logged player info (like name and image etc...)to the sentInviteQueueEntryModel
    sentInviteQueueEntryModelObs.value?.players
        ?.firstWhere(
            (element) => element?.user?.email == Shared.loggedUser?.email)
        ?.user = Shared.loggedUser;

    //add the other player info (like name and image etc...)to the sentInviteQueueEntryModel
    await Future.wait([
      usersCollection.doc(friend.email).get().then((json) {
        debugPrint('other player loaded');
        var otherUser = UserModel.fromJson(json.data());
        sentInviteQueueEntryModelObs.value?.players
            ?.firstWhere((element) => element?.user?.email == otherUser.email)
            ?.user = otherUser;
      }).onError((error, stackTrace) {
        printError(info: 'error loading other player' + error.toString());
      })
    ]);
  }*/

}
