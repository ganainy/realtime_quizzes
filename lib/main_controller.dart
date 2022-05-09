import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:realtime_quizzes/models/quiz_settings.dart';
import 'package:realtime_quizzes/screens/friends/friends_controller.dart';

import '../../models/api.dart';
import '../../models/player.dart';
import '../../models/question.dart';
import '../../models/queue_entry.dart';
import '../../network/dio_helper.dart';
import '../../screens/multiplayer_quiz/multiplayer_quiz_screen.dart';
import '../../screens/single_player_quiz/single_player_quiz_screen.dart';
import '../../shared/constants.dart';
import '../../shared/shared.dart';
import 'layouts/home/home.dart';
import 'models/user.dart';

class MainController extends GetxController {
  var isOnlineObs = Rxn<bool>();

  void changeUserStatus(bool isOnline) {
    //set user as online and offline based on if using app or not
    usersCollection.doc(Shared.loggedUser?.email).update({
      'isOnline': isOnline,
    }).then((value) {
      debugPrint('update status success');
      isOnlineObs.value = isOnline;
    });
  }

  //observables to update ui
  var userObs = Rxn<UserModel?>();
  var queueEntryObs = Rxn<QueueEntryModel?>();
  var selectedDifficultyListObs = [false, true, false].obs;
  var receivedInvitesObs = [].obs; //list of QueueEntryModel
  /*Function eq = const ListEquality().equals; //function to compare two lists*/
  StreamSubscription? queueEntryListener;
  var receivedFriendRequestsIdsObs = Rxn<List<dynamic>?>(); //list of String
  var friendsObsIdsObs = Rxn<List<dynamic>?>(); //list of String
  var receivedFriendRequestsObs = [].obs; //list of UserModel

  late FriendsController friendsController;
  @override
  void onInit() {
    //initialize user email
    Shared.loggedUser = UserModel(email: auth.currentUser?.email);
    friendsController = Get.put(FriendsController());
    //set user as online on app start
    changeUserStatus(true);
    //keep listening to received invites
    observeGameInvites();
    //set initial values of quiz parameters
    queueEntryObs.value = Shared.queueEntryModel;
    //save latest game setting values in shared class to access through app
    queueEntryObs.listen((p0) {
      Shared.queueEntryModel = p0!;
    });

    selectedDifficultyListObs.listen((p0) {
      if (selectedDifficultyListObs.value.elementAt(0)) {
        Shared.queueEntryModel.quizSettings?.difficulty = 'easy';
      }
      if (selectedDifficultyListObs.value.elementAt(1)) {
        Shared.queueEntryModel.quizSettings?.difficulty = 'medium';
      }
      if (selectedDifficultyListObs.value.elementAt(2)) {
        Shared.queueEntryModel.quizSettings?.difficulty = 'hard';
      }
    });
  }

  //observe changes of logged user to update the profile
  observeProfileChanges() {
    usersCollection.doc(Shared.loggedUser?.email).snapshots().listen((event) {
      var user = UserModel.fromJson(event.data());
      Shared.loggedUser = user;
      userObs.value = user;

      //only fetch friends again if there is difference than already showing friends
      /*if (!eq(friendsObsIdsObs.value, Shared.loggedUser?.friends)) {
        debugPrint(' loadFriends()');*/
      friendsController.loadFriends();
      friendsController.observeFriendsStatus();
      friendsObsIdsObs.value = Shared.loggedUser?.friends;
      /*  }*/

      //listen to upcoming friend requests
      /*if (!eq(receivedFriendRequestsIdsObs.value,
          Shared.loggedUser?.receivedFriendRequests)) {*/
      debugPrint('receivedFriendRequests()');
      loadFriendRequests();
      receivedFriendRequestsIdsObs.value =
          Shared.loggedUser?.receivedFriendRequests;
      /*}*/

      debugPrint('logged user changed');
    }).onError((error, stackTrace) {
      errorDialog(error.toString());
      printError(info: 'error observe logged user' + error.toString());
    });
  }

  //load accounts info of users who sent friend requests
  loadFriendRequests() {
    debugPrint('loadFriendRequests() called');

    receivedFriendRequestsObs.value.clear();
    //get full profile of each user who sent friend request
    Shared.loggedUser?.receivedFriendRequests.forEach((receivedFriendRequest) {
      if (Shared.loggedUser!.removedRequests.contains(receivedFriendRequest)) {
        //dont show friend request if user removed it before
      } else {
        usersCollection.doc(receivedFriendRequest).get().then((value) {
          var friendRequest = UserModel.fromJson(value.data());
          /*addUniqueUser(
              userModelListObs: receivedFriendRequestsObs,
              userModel: friendRequest);*/
          receivedFriendRequestsObs.value.add(friendRequest);
          receivedFriendRequestsObs.refresh();
          debugPrint('success single loadFriendRequest profile');
        }).onError((error, stackTrace) {
          errorDialog(error.toString());
          printError(
              info:
                  'error single loadFriendRequest profile' + error.toString());
        });
      }
    });
  }

//check if logged user became any game invites
  void observeGameInvites() {
    //scenario 1,2
    invitesCollection
        .where('invitedFriend', isEqualTo: (Shared.loggedUser?.email))
        .snapshots()
        .listen((event) {
      receivedInvitesObs.value.clear();
      debugPrint('invites received: ${event.docs.length}');
      event.docs.forEach((element) {
        var gameInvite = QueueEntryModel.fromJson(element.data());
        if (gameInvite.inviteStatus != InviteStatus.SENDER_CANCELED_INVITE) {
          //only show game invite if not canceled by sender
          receivedInvitesObs.value.add(gameInvite);
        }
        receivedInvitesObs.refresh();
      });
    }).onError((error) {
      errorDialog(error.toString());
      printError(info: 'observeGameInvites error :' + error.toString());
    });
  }

  //load questions from api
  Future<dynamic> fetchQuiz({String? queueEntryId}) async {
    debugPrint('fetchQuiz');

    var categoryApi;
    var difficultyApi;

    //convert category name to match the param thats passed to api
    Constants.categoryList.forEach((categoryMap) {
      if (categoryMap['category'].toString().toLowerCase() ==
          Shared.queueEntryModel.quizSettings?.category?.toLowerCase()) {
        categoryApi = categoryMap['api'];
      }
    });

    //convert difficulty name to match the param thats passed to api
    Constants.difficultyList.forEach((difficultyMap) {
      if (difficultyMap['difficulty'].toString().toLowerCase() ==
          Shared.queueEntryModel.quizSettings?.difficulty?.toLowerCase()) {
        difficultyApi = difficultyMap['api'];
      }
    });

    var params = {
      'difficulty': difficultyApi,
      'amount': Shared.queueEntryModel.quizSettings?.numberOfQuestions,
      'category': categoryApi,
      'type': 'multiple',
    };

    //remove null parameters from queryParams so API call won't fail
    if (params['difficulty'] == null) {
      params.remove('difficulty');
    }
    if (params['category'] == null ||
        params['category'] ==
            'Random'.tr /*this is not real category its just for UI*/) {
      params.remove('category');
    }

    return await DioHelper.getQuestions(queryParams: params);
  }

  //upload loaded questions to firebase to be used in multiplayer
  Future<void> uploadQuiz({
    required List<QuestionModel> questions,
  }) async {
    debugPrint('uploadQuiz');

    var questionsJson = [];
    questions.forEach((question) {
      questionsJson.add(questionModelToJson(question));
    });
    //upload quiz to firestore
    return await queueCollection
        .doc(Shared.queueEntryModel.queueEntryId)
        .update({
      'questions': questionsJson,
      'createdAt': DateTime.now().millisecondsSinceEpoch
    });
  }

  //this method will listen for when another player enters logged player queue
  void observeQueueChanges(BuildContext context) {
    queueEntryListener = queueCollection
        .doc(Shared.loggedUser?.email)
        .snapshots()
        .listen((queueEntryJson) {
      var queueEntry = QueueEntryModel.fromJson(queueEntryJson.data());
      if (queueEntry.players!.length > 1) {
        foundMatchDialog();
        startGame();
        debugPrint(
            'scenario 2: another play is add to my entry, match should start');
      } else {
        debugPrint('scenario 2: still one player: ');
      }
    });

    queueEntryListener?.onError((error, stackTrace) {
      errorDialog(error.toString());
      printError(
          info: 'scenario 2: observing my queue entry error :' +
              error.toString());
    });
  }

  void startGame() {
    //stop listening to updates of queue
    queueEntryListener?.cancel();
    Get.back(); //hide any alert dialogs
    Get.to(() => MultiPlayerQuizScreen());
  }

  void cancelQueue() {
    //stop listening to updates of queue
    queueEntryListener?.cancel();
    //delete queue entry
    queueCollection
        .doc(Shared.queueEntryModel.queueEntryId)
        .delete()
        .then((value) {
      debugPrint('left queue');
    }).onError((error, stackTrace) {
      errorDialog(error.toString());
      printError(info: 'leave queue error :' + error.toString());
    });
  }

  void archiveInvite() {
    Shared.queueEntryModel.inviteStatus = InviteStatus.SENDER_CANCELED_INVITE;
    invitesCollection
        .doc(Shared.queueEntryModel.queueEntryId)
        .update(queueEntryModelToJson(Shared.queueEntryModel))
        .then((value) {
      debugPrint('archived game');
    }).onError((error, stackTrace) {
      errorDialog(error.toString());
      printError(info: 'archive game error :' + error.toString());
    });
  }

  //sends game invite to a friend
  void inviteFriendToGame({UserModel? friend}) {
    Shared.queueEntryModel.queueEntryId = Shared.loggedUser?.email;

    loadingDialog(
        loadingMessage: 'Sending invite to ${friend?.name ?? 'friend'}...',
        onCancel: archiveInvite);

    fetchQuiz().then((jsonResponse) {
      ApiModel apiModel = ApiModel.fromJson(jsonResponse.data);
      if (apiModel.responseCode == null || apiModel.responseCode != 0) {
        errorDialog('error_loading_quiz'.tr);
        printError(info: 'error API response code');
      } else {
        debugPrint('sendGameInvite');

        Shared.queueEntryModel = QueueEntryModel(
          quizSettings: QuizSettings(
            difficulty: Shared.queueEntryModel.quizSettings?.difficulty,
            category: Shared.queueEntryModel.quizSettings?.category,
            numberOfQuestions:
                Shared.queueEntryModel.quizSettings?.numberOfQuestions,
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
          queueEntryId: Shared.queueEntryModel.queueEntryId,
          players: [
            PlayerModel(user: Shared.loggedUser),
            PlayerModel(user: friend)
          ],
          questions: apiModel.questions,
        );

        var queueEntryModelJson = queueEntryModelToJson(Shared.queueEntryModel);

        invitesCollection
            .doc(Shared.queueEntryModel.queueEntryId)
            .set(queueEntryModelJson)
            .then((value) {
          debugPrint('created invite');
          Get.back();
          showWaitingDialog();
          observeSentInviteChanges();
        }).onError((error, stackTrace) {
          errorDialog(error.toString());
          printError(info: 'create invite error :' + error.toString());
        });
      }
    }).onError((error, stackTrace) {
      printError(info: 'error loading questions from API' + error.toString());

      errorDialog('error loading questions from API');
    });
  }

  void acceptGameInvite(QueueEntryModel incomingGameInvite) {
    //scenario 2
    incomingGameInvite.inviteStatus = InviteStatus.FRIEND_ACCEPTED_INVITE;
    Shared.queueEntryModel = incomingGameInvite;

    invitesCollection
        .doc(Shared.queueEntryModel.queueEntryId)
        .update(queueEntryModelToJson(Shared.queueEntryModel))
        .then((value) {
      startGame();
      debugPrint('invite accepted ');
    }).onError((error, stackTrace) {
      errorDialog(error.toString());
      printError(info: 'acceptGameInvite error :' + error.toString());
    });
  }

  //listen to updates to sent invite to know when friend accepts invite
  void observeSentInviteChanges() {
    queueEntryListener = invitesCollection
        .doc(Shared.loggedUser?.email)
        .snapshots()
        .listen((queueEntryJson) {
      Shared.queueEntryModel = QueueEntryModel.fromJson(queueEntryJson.data());

      if (Shared.queueEntryModel.inviteStatus ==
          InviteStatus.FRIEND_ACCEPTED_INVITE) {
        startGame();
        debugPrint('invite accepted , match should start');
      } else if (Shared.queueEntryModel.inviteStatus ==
          InviteStatus.FRIEND_DECLINED_INVITE) {
        showInfoDialog(
            message: 'your game invite was declined.',
            title: 'invite declined');
        archiveInvite();
      }

      queueEntryListener?.onError((error, stackTrace) {
        errorDialog(error.toString());
        printError(info: 'observeQueueChanges error :' + error.toString());
      });
    });
  }

/*  //delete sent invite
  void removeGameInvite() {
    invitesCollection
        .doc(Shared.queueEntryModel.queueEntryId)
        .delete()
        .then((value) {
      debugPrint('delete game successful');
    }).onError((error, stackTrace) {
      errorDialog(error.toString());
      printError(info: 'delete game error' + error.toString());
    });
  }*/

  void declineGameInvite(QueueEntryModel incomingGameInvite) {
    incomingGameInvite.inviteStatus = InviteStatus.FRIEND_DECLINED_INVITE;
    Shared.queueEntryModel = incomingGameInvite;
    //game invite observer won't be automatically activated, so we have to
    //remove invite on decline manually
    Future.delayed(const Duration(milliseconds: 100), () {
      receivedInvitesObs.value.removeWhere((receivedInvite) {
        return Shared.queueEntryModel.queueEntryId ==
            receivedInvite.queueEntryId;
      });
      receivedInvitesObs.refresh();
    });

    invitesCollection
        .doc(Shared.queueEntryModel.queueEntryId)
        .update(queueEntryModelToJson(Shared.queueEntryModel))
        .then((value) {
      debugPrint('invite declined ');
    }).onError((error, stackTrace) {
      errorDialog(error.toString());
      printError(info: 'declineGameInvite error :' + error.toString());
    });
  }

  //delete game from queueCollection since its over and reset queueEntryModel
  deleteGame() {
    queueCollection
        .doc(Shared.queueEntryModel.queueEntryId)
        .delete()
        .then((value) {
      debugPrint('removed from queueCollection');
      Shared.resetQueueEntry();
    }).onError((error, stackTrace) {
      printError(info: 'error remove from queueCollection');
      Shared.resetQueueEntry();
    });
  }

  void deleteFriend(UserModel? friend) {
    /* friendsObs.value.remove(friend);
    friendsObs.refresh();*/

    //remove other user from logged user friends
    usersCollection.doc(Shared.loggedUser?.email).update({
      'friends': FieldValue.arrayRemove([friend?.email])
    }).then((value) {
      debugPrint("1 deleteFriend ");
    }).onError((error, stackTrace) {
      errorDialog(error.toString());
      printError(info: "1 Failed to deleteFriend: $error");
    });

    //remove logged user from other user friends
    usersCollection.doc(friend?.email).update({
      'friends': FieldValue.arrayRemove([Shared.loggedUser?.email])
    }).then((value) {
      debugPrint("2 deleteFriend ");
    }).onError((error, stackTrace) {
      errorDialog(error.toString());
      printError(info: "2 Failed to deleteFriend: $error");
    });
  }

  /// Dialogs**/

  void showWaitingDialog() {
    Get.back();
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        archiveInvite();
        Get.back();
      },
    );

    Get.defaultDialog(
      actions: [cancelButton],
      title:
          'Waiting for ${Shared.queueEntryModel.players?.elementAt(1)?.user?.name ?? 'opponent'} to accept',
      barrierDismissible: false,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              "${Shared.queueEntryModel.quizSettings?.difficulty}-${Shared.queueEntryModel.quizSettings?.category}-"
              "${Shared.queueEntryModel.quizSettings?.numberOfQuestions} ${'questions'.tr} ",
              style: TextStyle(fontSize: 14)),
          SizedBox(
            height: 10,
          ),
          CircularProgressIndicator(),
        ],
      ),
    );
  }

  void inQueueDialog() {
    Get.back(); //hide any showing dialog before opening new one

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        cancelQueue();
        Get.back();
      },
    );
    Widget continueButton = TextButton(
      child: Text("Play offline"),
      onPressed: () {
        Get.back();
        Get.to(
          () => SinglePlayerQuizScreen(),
        );
      },
    );

    Get.defaultDialog(
      actions: [cancelButton, continueButton],
      title: 'In queue',
      barrierDismissible: false,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Game will start once we find another player with same search paramaters as you",
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(
            height: 10,
          ),
          CircularProgressIndicator(),
        ],
      ),
    );
  }

  void showFriendDialog(UserModel? friend) {
    // set up the buttons
    Widget sendInviteButton = TextButton(
      child: Text("Invite to game"),
      onPressed: () {
        Get.back();
        //todo inviteFriendToGame(friend);
      },
    );
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Get.back();
      },
    );
    Widget deleteButton = TextButton(
      child: Text("Delete friend"),
      onPressed: () {
        Get.back();
        deleteFriend(friend);
      },
    );

    Get.defaultDialog(
      actions: [sendInviteButton, deleteButton, cancelButton],
      barrierDismissible: false,
      title: 'Select action for ${friend?.name ?? 'Friend'}',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [],
      ),
    );
  }

  void showInfoDialog({String? title, required String message}) {
    Get.back(); //hide any showing dialog before opening new one
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Ok"),
      onPressed: () {
        Get.back();
      },
    );

    Get.defaultDialog(
      actions: [cancelButton],
      title: title ?? '',
      barrierDismissible: false,
      content: Text(message, style: TextStyle(fontSize: 14)),
    );
  }

  void confirmExitDialog({bool isOnlineGame = false}) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Get.back();
      },
    );
    Widget confirmButton = TextButton(
      child: Text("Confirm"),
      onPressed: () {
        if (isOnlineGame) {
          //in case of online game also delete from queue
          Shared.queueEntryModel.hasOpponentLeftGame = true;
          updateGame();
        }
        Get.back();
        Get.offAll(() => HomeScreen());
      },
    );

    Get.defaultDialog(
      actions: [confirmButton, cancelButton],
      title: 'Exit',
      barrierDismissible: false,
      content: Text('Are you sure you want to exit game?',
          style: TextStyle(fontSize: 14)),
    );
  }

  void foundMatchDialog() {
    Get.back(); //hide any showing dialog before opening new one

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        cancelQueue();
        Get.back();
      },
    );

    Get.defaultDialog(
      actions: [cancelButton],
      title: 'Found match',
      barrierDismissible: false,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Game will start shortly", style: TextStyle(fontSize: 14)),
          SizedBox(
            height: 10,
          ),
          CircularProgressIndicator(),
        ],
      ),
    );
  }

  void loadingDialog({required loadingMessage, required onCancel}) {
    Get.back(); //hide any showing dialog before opening new one

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        onCancel();
        Get.back();
      },
    );

    Get.defaultDialog(
      actions: [cancelButton],
      title: loadingMessage,
      barrierDismissible: false,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: const [
          CircularProgressIndicator(),
        ],
      ),
    );
  }

  void errorDialog(String? errorMessage, {shouldGoBack = true}) {
    if (shouldGoBack) {
      Get.back(); //hide any showing dialog before opening new one
    }
    cancelQueue();
    errorMessage ?? 'Something went wrong';

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Ok"),
      onPressed: () {
        cancelQueue();
        Get.back();
      },
    );

    Get.defaultDialog(
      actions: [cancelButton],
      title: 'Error',
      barrierDismissible: false,
      content: Text('${errorMessage}', style: const TextStyle(fontSize: 14)),
    );
  }

  void updateGame() {
    queueCollection
        .doc(Shared.queueEntryModel.queueEntryId)
        .update(queueEntryModelToJson(Shared.queueEntryModel))
        .then((value) {
      debugPrint('updateGame success ');
    }).onError((error, stackTrace) {
      errorDialog(error.toString());
      printError(info: 'updateGame error :' + error.toString());
    });
  }

  //updating only fields inside observable object and not the whole object
  //doesn't trigger rebuild, so we need to do it manually
  void forceUpdateUi() {
    queueEntryObs.refresh();
  }
}
