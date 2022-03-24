import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../models/user.dart';
import '../../shared/shared.dart';

class FriendsController extends GetxController {
  // todo fix item shows twice , listener instead of get to keep views updated

  var friendsObs = [].obs; //list of UserModel
  var friendSuggestionsObs = [].obs; //list of UserModel
  var incomingFriendRequestsObs = [].obs; //list of UserModel

  loadFriends() {
    if (friendsObs.value.isNotEmpty) return;

    usersCollection.doc(auth.currentUser?.email).get().then((value) {
      var userModel = UserModel.fromJson(value.data());

      //get full profile of each user who sent friend request
      userModel.friends.forEach((friend) {
        usersCollection.doc(friend).get().then((value) {
          friendsObs.value.add(UserModel.fromJson(value.data()));
          debugPrint('success single loadFriend profile');
        }).onError((error, stackTrace) {
          printError(
              info: 'error single loadFriend profile' + error.toString());
        });
      });

      debugPrint('success loading friends');
    }).onError((error, stackTrace) {
      printError(info: 'error loading friends' + error.toString());
    });
  }

  loadFriendSuggestions() {
    if (friendSuggestionsObs.value.isNotEmpty) return;

    usersCollection.limit(10).get().then((value) {
      value.docs.forEach((element) {
        var userModel = UserModel.fromJson(element.data());

        //if user not already friends with logged user
        if (!userModel.friends.contains(auth.currentUser?.email)) {
          //if user not already have sent friend request from logged user
          if (!userModel.receivedFriendRequests
              .contains(auth.currentUser?.email)) {
            //if user is not logged user
            if (userModel.email != auth.currentUser?.email) {
              friendSuggestionsObs.add(userModel);
            }
          }
        }
      });

      debugPrint('success loadFriendSuggestions');
    }).onError((error, stackTrace) {
      printError(info: 'error loadFriendSuggestions' + error.toString());
    });
  }

  loadFriendRequests() {
    if (incomingFriendRequestsObs.value.isNotEmpty) return;
    //get ids of users who sent friend requests
    usersCollection.doc(auth.currentUser?.email).get().then((value) {
      var userModel = UserModel.fromJson(value.data());

      //get full profile of each user who sent friend request
      userModel.receivedFriendRequests.forEach((receivedFriendRequest) {
        usersCollection.doc(receivedFriendRequest).get().then((value) {
          incomingFriendRequestsObs.value.add(UserModel.fromJson(value.data()));
          debugPrint('success single loadFriendRequest profile');
        }).onError((error, stackTrace) {
          printError(
              info:
                  'error single loadFriendRequest profile' + error.toString());
        });
      });

      debugPrint('success loadFriendRequests ids');
    }).onError((error, stackTrace) {
      printError(info: 'error loadFriendRequests' + error.toString());
    });
  }

  void sendFriendRequest(UserModel friendSuggestion) {
    //remove from suggestions
    friendSuggestionsObs.value.remove(friendSuggestion);
    friendSuggestionsObs.refresh();

    debugPrint(
        'friendSuggestionsObs length ${friendSuggestionsObs.value.length}');

    //sent friend request
    FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get the document
      DocumentSnapshot snapshot =
          await transaction.get(usersCollection.doc(friendSuggestion.email));

      if (!snapshot.exists) {
        throw Exception("Queue entry does not exist!");
      }
      var _userModel = UserModel.fromJson(snapshot.data());

      if (!_userModel.receivedFriendRequests
          .contains(auth.currentUser?.email)) {
        _userModel.receivedFriendRequests.add(auth.currentUser?.email);
      }

      transaction.update(usersCollection.doc(friendSuggestion.email),
          userModelToJson(_userModel));
    }).then((value) {
      debugPrint("sendFriendRequest $value");
    }).catchError(
        (error) => printError(info: "Failed to sendFriendRequest: $error"));
  }

  void acceptFriendRequest(UserModel incomingFriendRequest) {
    //remove from received friend requests
    //remove from suggestions
    incomingFriendRequestsObs.value.remove(incomingFriendRequest);
    incomingFriendRequestsObs.refresh();

    //add other user to logged user friends
    usersCollection.doc(auth.currentUser?.email).update({
      'friends': FieldValue.arrayUnion([incomingFriendRequest.email])
    }).then((value) {
      debugPrint("acceptFriendRequest ");
    }).onError((error, stackTrace) {
      printError(info: "Failed to acceptFriendRequest: $error");
    });

    //add logged user to other user friends
    usersCollection.doc(incomingFriendRequest.email).update({
      'friends': FieldValue.arrayUnion([auth.currentUser?.email])
    }).then((value) {
      debugPrint("2 acceptFriendRequest ");
    }).onError((error, stackTrace) {
      printError(info: "2 Failed to acceptFriendRequest: $error");
    });

    //remove received friend request
    usersCollection.doc(auth.currentUser?.email).update({
      'receivedFriendRequests':
          FieldValue.arrayRemove([incomingFriendRequest.email])
    }).then((value) {
      debugPrint("3 acceptFriendRequest ");
    }).onError((error, stackTrace) {
      printError(info: "3 Failed to acceptFriendRequest: $error");
    });
  }

  void deleteFriend(UserModel friend) {
    friendsObs.value.remove(friend);
    friendsObs.refresh();

    //remove other user from logged user friends
    usersCollection.doc(auth.currentUser?.email).update({
      'friends': FieldValue.arrayRemove([friend.email])
    }).then((value) {
      debugPrint("1 deleteFriend ");
    }).onError((error, stackTrace) {
      printError(info: "1 Failed to deleteFriend: $error");
    });

    //remove logged user from other user friends
    usersCollection.doc(friend.email).update({
      'friends': FieldValue.arrayRemove([auth.currentUser?.email])
    }).then((value) {
      debugPrint("2 deleteFriend ");
    }).onError((error, stackTrace) {
      printError(info: "2 Failed to deleteFriend: $error");
    });
  }
}
