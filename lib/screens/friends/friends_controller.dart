import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:realtime_quizzes/layouts/home/home_controller.dart';

import '../../models/api.dart';
import '../../models/player.dart';
import '../../models/question.dart';
import '../../models/queue_entry.dart';
import '../../models/user.dart';
import '../../network/dio_helper.dart';
import '../../shared/constants.dart';
import '../../shared/shared.dart';
import '../multiplayer_quiz/multiplayer_quiz_screen.dart';

class FriendsController extends GetxController {
  var loggedUserObs = Rxn<UserModel>(); // UserModel
  var friendsObs = [].obs; //list of UserModel
  var friendSuggestionsObs = [].obs; //list of UserModel
  var receivedFriendRequestsObs = [].obs;

  var difficultySelectionsObs = [false, true, false].obs;
  var categorySelectionsObs = 'Random'.tr.obs;
  var numQuestionsSelectionsObs = Rxn<String?>();

  var sentInviteQueueEntryModelObs = Rxn<QueueEntryModel>();
  var receivedInvitesObs = [].obs; //list of QueueEntryModel

  StreamSubscription? queueEntryListener;
  late HomeController homeController;
  @override
  void onInit() {
    homeController = Get.find<HomeController>();
    addListeners();
    observeUserChanges();
    observeGameInvites();
  }

  //
  Function eq = const ListEquality().equals;
  var receivedFriendRequestsIdsObs = Rxn<List<dynamic>?>(); //list of String
  var friendsObsIdsObs = Rxn<List<dynamic>?>(); //list of String

  addListeners() {
    loggedUserObs.listen((loggedUser) {
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

  //observe changes of logged user to update the profile
  observeUserChanges() {
    usersCollection.doc(auth.currentUser?.email).snapshots().listen((event) {
      loggedUserObs.value = UserModel.fromJson(event.data());
      debugPrint('logged user changed');
    }).onError((error, stackTrace) {
      homeController.errorDialog(error.toString());
      printError(info: 'error observe logged user' + error.toString());
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

    loggedUserObs.value?.friends.forEach((friendId) {
      usersCollection.doc(friendId).get().then((value) {
        var friend = UserModel.fromJson(value.data());
        addUniqueUser(userModelListObs: friendsObs, userModel: friend);
        debugPrint('success single loadFriend profile');
      }).onError((error, stackTrace) {
        printError(info: 'error single loadFriend profile' + error.toString());
        homeController.errorDialog(error.toString());
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
        if (!loggedUserObs.value!.friends.contains(userModel.email)) {
          if (!loggedUserObs.value!.receivedFriendRequests
              .contains(userModel.email)) {
            if (!loggedUserObs.value!.sentFriendRequests
                .contains(userModel.email)) {
              //don't show the user himself in suggestions
              if (userModel.email != loggedUserObs.value!.email) {
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
      homeController.errorDialog(error.toString());
    });
  }

  loadFriendRequests() {
    //get ids of users who sent friend requests

    receivedFriendRequestsObs.value.clear();
    receivedFriendRequestsObs.refresh();

    //get full profile of each user who sent friend request
    loggedUserObs.value?.receivedFriendRequests
        .forEach((receivedFriendRequest) {
      usersCollection.doc(receivedFriendRequest).get().then((value) {
        var friendRequest = UserModel.fromJson(value.data());
        addUniqueUser(
            userModelListObs: receivedFriendRequestsObs,
            userModel: friendRequest);
        debugPrint('success single loadFriendRequest profile');
      }).onError((error, stackTrace) {
        homeController.errorDialog(error.toString());
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
      homeController.errorDialog(error.toString());
      printError(info: "1 Failed sentFriendRequests: $error");
    });

    //add logged user to other user received friends requests
    usersCollection.doc(friendSuggestion?.email).update({
      'receivedFriendRequests':
          FieldValue.arrayUnion([Shared.loggedUser?.email])
    }).then((value) {
      debugPrint("1 sentFriendRequests ");
    }).onError((error, stackTrace) {
      homeController.errorDialog(error.toString());
      printError(info: "1 Failed sentFriendRequests: $error");
    });
  }

  void acceptFriendRequest(UserModel incomingFriendRequest) {
    /* receivedFriendRequestsObs.value.remove(incomingFriendRequest);
    receivedFriendRequestsObs.refresh();*/

    //add other user to logged user friends
    usersCollection.doc(auth.currentUser?.email).update({
      'friends': FieldValue.arrayUnion([incomingFriendRequest.email])
    }).then((value) {
      debugPrint("acceptFriendRequest ");
    }).onError((error, stackTrace) {
      homeController.errorDialog(error.toString());
      printError(info: "Failed to acceptFriendRequest: $error");
    });

    //add logged user to other user friends
    usersCollection.doc(incomingFriendRequest.email).update({
      'friends': FieldValue.arrayUnion([auth.currentUser?.email])
    }).then((value) {
      debugPrint("2 acceptFriendRequest ");
    }).onError((error, stackTrace) {
      homeController.errorDialog(error.toString());
      printError(info: "2 Failed to acceptFriendRequest: $error");
    });

    //remove received friend request
    usersCollection.doc(auth.currentUser?.email).update({
      'receivedFriendRequests':
          FieldValue.arrayRemove([incomingFriendRequest.email])
    }).then((value) {
      debugPrint("3 acceptFriendRequest ");
    }).onError((error, stackTrace) {
      homeController.errorDialog(error.toString());
      printError(info: "3 Failed to acceptFriendRequest: $error");
    });

    //remove sent friend request
    usersCollection.doc(incomingFriendRequest.email).update({
      'sentFriendRequests': FieldValue.arrayRemove([auth.currentUser?.email])
    }).then((value) {
      debugPrint("4 acceptFriendRequest ");
    }).onError((error, stackTrace) {
      homeController.errorDialog(error.toString());
      printError(info: "4 Failed to acceptFriendRequest: $error");
    });
  }

  void deleteFriend(UserModel friend) {
    /* friendsObs.value.remove(friend);
    friendsObs.refresh();*/

    //remove other user from logged user friends
    usersCollection.doc(auth.currentUser?.email).update({
      'friends': FieldValue.arrayRemove([friend.email])
    }).then((value) {
      debugPrint("1 deleteFriend ");
    }).onError((error, stackTrace) {
      homeController.errorDialog(error.toString());
      printError(info: "1 Failed to deleteFriend: $error");
    });

    //remove logged user from other user friends
    usersCollection.doc(friend.email).update({
      'friends': FieldValue.arrayRemove([auth.currentUser?.email])
    }).then((value) {
      debugPrint("2 deleteFriend ");
    }).onError((error, stackTrace) {
      homeController.errorDialog(error.toString());
      printError(info: "2 Failed to deleteFriend: $error");
    });
  }

  //update friends state to show online or offline
  void observeFriendsStatus() {
    debugPrint('observeFriendsStatus');

    loggedUserObs.value?.friends.forEach((friendId) {
      usersCollection.doc(friendId).snapshots().listen((event) {
        debugPrint('listenting to friends');
        var friend = UserModel.fromJson(event.data());
        //update online status
        friendsObs.value
            .firstWhere((element) => element.email == friend.email)
            .isOnline = friend.isOnline;
        friendsObs.refresh();
      }).onError((error) {
        homeController.errorDialog(error.toString());
        debugPrint('error listening to friends');
      });
    });
  }
//scenario 1
  //send game invite to a friend

  void declineGameInvite(QueueEntryModel incomingGameInvite) {
    //game invite observer won't be automatically activated, so we have to
    //remove invite on decline manually
    Future.delayed(const Duration(milliseconds: 100), () {
      receivedInvitesObs.value.removeWhere((invite) {
        return incomingGameInvite.queueEntryId == invite.queueEntryId;
      });
      receivedInvitesObs.refresh();
    });

    incomingGameInvite.hasFriendDeclinedInvite = true;
    invitesCollection
        .doc(incomingGameInvite.queueEntryId)
        .update(queueEntryModelToJson(incomingGameInvite))
        .then((value) {
      debugPrint('invite declined ');
    }).onError((error, stackTrace) {
      homeController.errorDialog(error.toString());
      printError(info: 'declineGameInvite error :' + error.toString());
    });
  }

  void observeGameInvites() {
    //scenario 1,2
    invitesCollection
        .where('invitedFriend', isEqualTo: (auth.currentUser?.email))
        .snapshots()
        .listen((event) {
      receivedInvitesObs.value.clear();
      event.docs.forEach((element) {
        var gameInvite = QueueEntryModel.fromJson(element.data());
        receivedInvitesObs.value.add(gameInvite);
        receivedInvitesObs.refresh();
      });
    }).onError((error) {
      homeController.errorDialog(error.toString());
      printError(info: 'observeGameInvites error :' + error.toString());
    });
  }

  ///-----------Scenario 1, user send invite to friend-------------
  //delete sent invite
  void removeGameInvite() {
    invitesCollection
        .doc(sentInviteQueueEntryModelObs.value?.queueEntryId)
        .delete()
        .then((value) {
      debugPrint('delete game successful');
    }).onError((error, stackTrace) {
      homeController.errorDialog(error.toString());
      printError(info: 'delete game error' + error.toString());
    });
  }

  void sendGameInvite(UserModel friend) {
    debugPrint('sendGameInvite');
    var queueEntryModelJson =
        queueEntryModelToJson(sentInviteQueueEntryModelObs.value);

    invitesCollection
        .doc(sentInviteQueueEntryModelObs.value?.queueEntryId)
        .set(queueEntryModelJson)
        .then((value) {
      debugPrint('created invite');

      showWaitingDialog(friend);
      observeSentInviteChanges();
    }).onError((error, stackTrace) {
      homeController.errorDialog(error.toString());
      printError(info: 'create invite error :' + error.toString());
    });
  }

  void observeSentInviteChanges() {
    //scenario 1
    //this method will be triggered if another player is matched with this player
    queueEntryListener = invitesCollection
        .doc(auth.currentUser?.email)
        .snapshots()
        .listen((queueEntryJson) {
      var queueEntry = QueueEntryModel.fromJson(queueEntryJson.data());

      if (queueEntry.hasFriendAcceptedInvite) {
        startGame();
        debugPrint('invite accepted , match should start');
      } else if (queueEntry.hasFriendDeclinedInvite) {
        homeController.showInfoDialog(
            message: 'your game invite was declined.',
            title: 'invite declined');
        removeGameInvite();
      }

      queueEntryListener?.onError((error, stackTrace) {
        homeController.errorDialog(error.toString());
        printError(info: 'observeQueueChanges error :' + error.toString());
      });
    });
  }

  void fetchQuiz(UserModel friend) {
    //scenario 1
    var players = [
      PlayerModel(user: Shared.loggedUser),
      PlayerModel(user: UserModel(email: friend.email))
    ];

    var _difficulty;
    if (difficultySelectionsObs.value.elementAt(0)) _difficulty = 'easy';
    if (difficultySelectionsObs.value.elementAt(1)) _difficulty = 'medium';
    if (difficultySelectionsObs.value.elementAt(2)) _difficulty = 'hard';

    var _category = Constants.categoryList.firstWhere(
        (element) => element['category'] == categorySelectionsObs.value)['api'];

    var queueEntryModel = QueueEntryModel(
        difficulty: _difficulty,
        category: _category,
        //when no number of questions selected use default=10
        numberOfQuestions: int.parse(numQuestionsSelectionsObs.value ?? '10'),
        queueEntryId: auth.currentUser?.email,
        players: players,
        createdAt: DateTime.now().millisecondsSinceEpoch);
    queueEntryModel.invitedFriend = friend.email;

    sentInviteQueueEntryModelObs.value = queueEntryModel;

    var params = {
      'difficulty': sentInviteQueueEntryModelObs.value?.difficulty,
      'amount': sentInviteQueueEntryModelObs.value?.numberOfQuestions,
      'category': sentInviteQueueEntryModelObs.value?.category,
      'type': 'multiple',
    };

    //remove null parameters from queryParams so API call won't fail
    if (params['category'] == null) {
      params.remove('category');
    }

    DioHelper.getQuestions(queryParams: params).then((jsonResponse) {
      ApiModel apiModel = ApiModel.fromJson(jsonResponse.data);
      if (apiModel.responseCode == null || apiModel.responseCode != 0) {
        homeController.errorDialog('error_loading_quiz'.tr);

        printError(info: 'error loading questions from API');
      } else {
        uploadQuiz(apiModel.questions, friend, players);
      }
    }).onError((error, stackTrace) {
      homeController.errorDialog(error.toString());
      printError(info: 'error loading questions from API' + error.toString());

      homeController.errorDialog(
          'this_error_occurred_while_loading_quiz'.tr + error.toString());
    });
  }

  void uploadQuiz(List<QuestionModel> questions, UserModel friend,
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
      homeController.errorDialog(error.toString());
      printError(info: 'firestore add questions error : ' + error.toString());
    });
  }

  void startGame() {
    //scenario 1,2
    queueEntryListener?.cancel();
    Get.to(() => MultiPlayerQuizScreen(),
        arguments: (sentInviteQueueEntryModelObs.value));
  }

  ///-----------Scenario 2, user accept invite from friend-------------
  void acceptGameInvite(QueueEntryModel incomingGameInvite) {
    //scenario 2
    sentInviteQueueEntryModelObs.value = incomingGameInvite;

    incomingGameInvite.hasFriendAcceptedInvite = true;

    invitesCollection
        .doc(incomingGameInvite.queueEntryId)
        .update(queueEntryModelToJson(incomingGameInvite))
        .then((value) {
      startGame();
      debugPrint('invite accepted ');
    }).onError((error, stackTrace) {
      homeController.errorDialog(error.toString());
      printError(info: 'acceptGameInvite error :' + error.toString());
    });
  }

  Future<void> loadOtherPlayerProfile(
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
  }

  void showWaitingDialog(UserModel friend) {
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        removeGameInvite();
        Get.back();
      },
    );

    Get.defaultDialog(
      actions: [cancelButton],
      title: 'Waiting for ${friend.name} to accept',
      barrierDismissible: false,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              "${sentInviteQueueEntryModelObs.value?.difficulty ?? 'Mixed'}-${sentInviteQueueEntryModelObs.value?.category ?? 'Random'}-"
              "${sentInviteQueueEntryModelObs.value?.numberOfQuestions} ${'questions'.tr} ",
              style: TextStyle(fontSize: 14)),
          SizedBox(
            height: 10,
          ),
          CircularProgressIndicator(),
        ],
      ),
    );
  }
}
