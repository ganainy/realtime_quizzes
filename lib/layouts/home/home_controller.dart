import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:realtime_quizzes/models/user.dart';

import '../../models/question.dart';
import '../../models/queue_entry.dart';
import '../../network/dio_helper.dart';
import '../../screens/multiplayer_quiz/multiplayer_quiz_screen.dart';
import '../../screens/single_player_quiz/single_player_quiz_screen.dart';
import '../../shared/constants.dart';
import '../../shared/shared.dart';

class HomeController extends GetxController {
  var userObs = Rxn<UserModel?>();

  var bottomSelectedIndex = 0.obs;

  //observables to update ui
  var numOfQuestionsObs = 10.00.obs;
  var selectedCategoryObs = ('Random'.tr).obs;
  var selectedDifficultyObs = ('Random'.tr).obs;

  StreamSubscription? queueEntryListener;

  @override
  void onInit() {
    loadProfile();

    //save actual values in shared class to access through app
    numOfQuestionsObs.listen((p0) {
      Shared.numQuestions = p0.toInt();
    });

    selectedCategoryObs.listen((p0) {
      Shared.category = p0;
    });

    selectedDifficultyObs.listen((p0) {
      Shared.difficulty = p0;
    });
  }

  loadProfile() {
    usersCollection.doc(auth.currentUser?.email).get().then((json) {
      var user = UserModel.fromJson(json.data());
      userObs.value = user;
      //save logged user info, to be used later in different parts of app
      Shared.loggedUser = user;
    }).onError((error, stackTrace) {
      printError(info: 'error loading logged user profile' + error.toString());
    });
  }

  //load questions from api
  Future<dynamic> fetchQuiz({String? queueEntryId}) async {
    debugPrint('fetchQuiz');

    var categoryApi;
    var difficultyApi;

    //convert category name to match the param thats passed to api
    Constants.categoryList.forEach((categoryMap) {
      if (categoryMap['category'] == Shared.category) {
        categoryApi = categoryMap['api'];
      }
    });

    //convert difficulty name to match the param thats passed to api
    Constants.difficultyList.forEach((difficultyMap) {
      if (difficultyMap['difficulty'] == Shared.difficulty) {
        difficultyApi = difficultyMap['api'];
      }
    });

    var params = {
      'difficulty': difficultyApi,
      'amount': Shared.numQuestions,
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
    return await queueCollection.doc(Shared.queueEntryId).update({
      'questions': questionsJson,
      'createdAt': DateTime.now().millisecondsSinceEpoch
    });
  }

  //this method will be triggered if another player is matched with this player
  void observeQueueChanges(BuildContext context) {
    queueEntryListener = queueCollection
        .doc(auth.currentUser?.email)
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
    queueCollection.doc(Shared.queueEntryId).delete().then((value) {
      debugPrint('left queue');
    }).onError((error, stackTrace) {
      errorDialog(error.toString());
      printError(info: 'leave queue error :' + error.toString());
    });
  }

  /// Dialogs**/

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

  void loadingDialog() {
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
      title: 'Looking for games online',
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
