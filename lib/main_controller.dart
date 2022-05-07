import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../models/api.dart';
import '../../models/player.dart';
import '../../models/question.dart';
import '../../models/queue_entry.dart';
import '../../network/dio_helper.dart';
import '../../screens/multiplayer_quiz/multiplayer_quiz_screen.dart';
import '../../screens/single_player_quiz/single_player_quiz_screen.dart';
import '../../shared/constants.dart';
import '../../shared/shared.dart';
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
  var numOfQuestionsObs = 10.00.obs;
  var selectedCategoryObs = ('Random'.tr).obs;
  var selectedDifficultyObs = ('Random'.tr).obs;
  var selectedDifficultyListObs = [false, true, false].obs;
  var receivedInvitesObs = [].obs; //list of QueueEntryModel

  StreamSubscription? queueEntryListener;

  @override
  void onInit() {
    //initialize user email
    Shared.loggedUser = UserModel(email: auth.currentUser?.email);

    //keep listening to received invites
    observeGameInvites();

    //save latest game setting values in shared class to access through app
    numOfQuestionsObs.listen((p0) {
      Shared.queueEntryModel.numberOfQuestions = p0.toInt();
    });

    selectedCategoryObs.listen((p0) {
      Shared.queueEntryModel.category = p0;

      /* Shared.category = Constants.categoryList
          .firstWhere((element) => element['category'] == p0)['api'];*/
    });

    selectedDifficultyObs.listen((p0) {
      Shared.queueEntryModel.difficulty = p0;
    });

    selectedDifficultyListObs.listen((p0) {
      if (selectedDifficultyListObs.value.elementAt(0)) {
        Shared.queueEntryModel.difficulty = 'easy';
      }
      if (selectedDifficultyListObs.value.elementAt(1)) {
        Shared.queueEntryModel.difficulty = 'medium';
      }
      if (selectedDifficultyListObs.value.elementAt(2)) {
        Shared.queueEntryModel.difficulty = 'hard';
      }
    });
  }

  //observe changes of logged user to update the profile
  observeProfileChanges() {
    usersCollection.doc(Shared.loggedUser?.email).snapshots().listen((event) {
      var user = UserModel.fromJson(event.data());
      Shared.loggedUser = user;
      userObs.value = user;
      debugPrint('logged user changed');
    }).onError((error, stackTrace) {
      errorDialog(error.toString());
      printError(info: 'error observe logged user' + error.toString());
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
        receivedInvitesObs.value.add(gameInvite);
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
          Shared.queueEntryModel.category?.toLowerCase()) {
        categoryApi = categoryMap['api'];
      }
    });

    //convert difficulty name to match the param thats passed to api
    Constants.difficultyList.forEach((difficultyMap) {
      if (difficultyMap['difficulty'].toString().toLowerCase() ==
          Shared.queueEntryModel.difficulty?.toLowerCase()) {
        difficultyApi = difficultyMap['api'];
      }
    });

    var params = {
      'difficulty': difficultyApi,
      'amount': Shared.queueEntryModel.numberOfQuestions,
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

  //sends game invite to a friend
  void inviteFriendToGame({UserModel? friend}) {
    Shared.queueEntryModel.queueEntryId = Shared.loggedUser?.email;

    loadingDialog(loadingMessage: 'Sending invite...');

    fetchQuiz().then((jsonResponse) {
      ApiModel apiModel = ApiModel.fromJson(jsonResponse.data);
      if (apiModel.responseCode == null || apiModel.responseCode != 0) {
        errorDialog('error_loading_quiz'.tr);
        printError(info: 'error API response code');
      } else {
        debugPrint('sendGameInvite');

        Shared.queueEntryModel = QueueEntryModel(
          difficulty: Shared.queueEntryModel.difficulty,
          category: Shared.queueEntryModel.category,
          numberOfQuestions: Shared.queueEntryModel.numberOfQuestions,
          queueEntryId: Shared.queueEntryModel.queueEntryId,
          players: [
            PlayerModel(user: Shared.loggedUser),
            PlayerModel(user: friend)
          ],
          createdAt: DateTime.now().millisecondsSinceEpoch,
          invitedFriend: friend?.email,
          questions: apiModel.questions,
        );

        var queueEntryModelJson = queueEntryModelToJson(Shared.queueEntryModel);

        invitesCollection
            .doc(Shared.queueEntryModel.queueEntryId)
            .set(queueEntryModelJson)
            .then((value) {
          debugPrint('created invite');
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
    incomingGameInvite.hasFriendAcceptedInvite = true;
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

      if (Shared.queueEntryModel.hasFriendAcceptedInvite) {
        startGame();
        debugPrint('invite accepted , match should start');
      } else if (Shared.queueEntryModel.hasFriendDeclinedInvite) {
        showInfoDialog(
            message: 'your game invite was declined.',
            title: 'invite declined');
        removeGameInvite();
      }

      queueEntryListener?.onError((error, stackTrace) {
        errorDialog(error.toString());
        printError(info: 'observeQueueChanges error :' + error.toString());
      });
    });
  }

  //delete sent invite
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
  }

  void declineGameInvite(QueueEntryModel incomingGameInvite) {
    incomingGameInvite.hasFriendDeclinedInvite = true;
    Shared.queueEntryModel = incomingGameInvite;
    //game invite observer won't be automatically activated, so we have to
    //remove invite on decline manually
    Future.delayed(const Duration(milliseconds: 100), () {
      receivedInvitesObs.value.removeWhere((receivedInvite) {
        return Shared.queueEntryModel?.queueEntryId ==
            receivedInvite.queueEntryId;
      });
      receivedInvitesObs.refresh();
    });

    invitesCollection
        .doc(Shared.queueEntryModel?.queueEntryId)
        .update(queueEntryModelToJson(Shared.queueEntryModel))
        .then((value) {
      debugPrint('invite declined ');
    }).onError((error, stackTrace) {
      errorDialog(error.toString());
      printError(info: 'declineGameInvite error :' + error.toString());
    });
  }

  /// Dialogs**/

  //dialog used to select game settings when creating game against friend
  void showQuizSpecDialog(UserModel? friend) {
    Get.back();

    Widget startButton = TextButton(
      child: Text("Start"),
      onPressed: () {
        inviteFriendToGame(friend: friend);
        Get.back();
      },
    );
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Get.back();
      },
    );

    Get.defaultDialog(
      actions: [startButton, cancelButton],
      title: 'Select game options',
      barrierDismissible: false,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() {
            return ToggleButtons(
              children: <Widget>[
                Container(
                  width: 30,
                  height: 30,
                  color: Colors.green,
                ),
                Container(
                  width: 30,
                  height: 30,
                  color: Colors.orange,
                ),
                Container(
                  width: 30,
                  height: 30,
                  color: Colors.red,
                ),
              ],
              isSelected: selectedDifficultyListObs.value,
              onPressed: (int index) {
                switch (index) {
                  case 0:
                    selectedDifficultyListObs.value[0] = true;
                    selectedDifficultyListObs.value[1] = false;
                    selectedDifficultyListObs.value[2] = false;
                    break;
                  case 1:
                    selectedDifficultyListObs.value[0] = false;
                    selectedDifficultyListObs.value[1] = true;
                    selectedDifficultyListObs.value[2] = false;
                    break;
                  case 2:
                    selectedDifficultyListObs.value[0] = false;
                    selectedDifficultyListObs.value[1] = false;
                    selectedDifficultyListObs.value[2] = true;
                    break;
                }
                showQuizSpecDialog(friend);
              },
            );
          }),
          DropdownButton<String>(
            items: Constants.categoryNames.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              selectedCategoryObs.value = value!;
              debugPrint('$value');
              showQuizSpecDialog(friend);
            },
            value: selectedCategoryObs.value,
          ),
          DropdownButton<String>(
            items: [
              '2',
              '3',
              '4',
              '5',
              '6',
              '7',
              '8',
              '9',
              '10',
              '11',
              '12',
              '13',
              '14',
              '15',
              '16',
              '17',
              '18',
              '19',
              '19',
              '20',
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text('$value'),
              );
            }).toList(),
            onChanged: (value) {
              numOfQuestionsObs.value = double.parse(value!);
              debugPrint('$value');
              showQuizSpecDialog(friend);
            },
            value: numOfQuestionsObs.value.toInt().toString(),
          )
        ],

        //  Constants.categoryList.map((category) =>
      ),
    );
  }

  void showWaitingDialog() {
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        removeGameInvite();
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
              "${Shared.queueEntryModel.difficulty}-${Shared.queueEntryModel.category}-"
              "${Shared.queueEntryModel.numberOfQuestions} ${'questions'.tr} ",
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

  void loadingDialog({loadingMessage = 'Looking for games online'}) {
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

  void errorDialog(String? errorMessage) {
    Get.back(); //hide any showing dialog before opening new one
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
}
