import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:realtime_quizzes/models/player.dart';
import 'package:realtime_quizzes/screens/vs_random_quiz/vs_random_quiz_screen.dart';

import '../../models/api.dart';
import '../../models/question.dart';
import '../../models/queue_entry.dart';
import '../../network/dio_helper.dart';
import '../../shared/constants.dart';
import '../../shared/shared.dart';

enum DialogType { IN_QUEUE, FOUND_MATCH, LOADING, HIDE }

class FindGameController extends GetxController {
  var numOfQuestionsObs = 10.00.obs;
  var selectedCategoryObs = 'general_knowledge'.tr.obs;
  var selectedDifficultyObs = 'medium'.tr.obs;

  var errorObs = Rxn<String?>();
  var queueEntryIdObs = Rxn<String>();
  var queueEntryModelObs = Rxn<QueueEntryModel>();
  StreamSubscription? queueEntryListener;
  StreamSubscription? observeQueueQuestionChangesStreamSubscription;

  //for the variables that needs to be observed from controller
  var isObserveCalledObs = false.obs; //to make sure observe() called only once
  var dialogTypeObs = Rxn<DialogType?>();
  observe() {
    if (isObserveCalledObs.value) return;
    isObserveCalledObs.value = true;

    dialogTypeObs.listen((dialogType) {
      switch (dialogType) {
        case DialogType.IN_QUEUE:
          Get.back();
          inQueueDialog();
          break;
        case DialogType.FOUND_MATCH:
          Get.back();
          foundMatchDialog();
          break;
        case DialogType.LOADING:
          Get.back();
          loadingDialog();
          break;
        case DialogType.HIDE:
          Get.back();
          break;
        default:
          debugPrint('Get.back() called');
          Get.back();
          break;
      }
    });

    errorObs.listen((error) {
      cancelQueue();
      Get.back();
      errorDialog();
    });
  }

  void inQueueDialog() {
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
      onPressed: () {},
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
              "Game will start once we find another player with same search paramaters as you"),
          SizedBox(
            height: 10,
          ),
          CircularProgressIndicator(),
        ],
      ),
    );
  }

  void foundMatchDialog() {
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
          Text("Game will start shortly"),
          SizedBox(
            height: 10,
          ),
          CircularProgressIndicator(),
        ],
      ),
    );
  }

  void loadingDialog() {
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

  void errorDialog() {
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
      content: Text("${errorObs.value ?? ''}"),
    );
  }

  void enterQueue(BuildContext context) {
    queueEntryIdObs.value = auth.currentUser?.email;
    var players = [PlayerModel(playerEmail: auth.currentUser?.email)];
    var queueEntryModel = QueueEntryModel(
        selectedDifficultyObs.value,
        selectedCategoryObs.value,
        numOfQuestionsObs.value.toInt(),
        auth.currentUser?.email,
        players);

    var queueEntryModelJson = queueEntryModelToJson(queueEntryModel);

    queueCollection
        .doc(queueEntryModel.queueEntryId)
        .set(queueEntryModelJson)
        .then((value) {
      debugPrint('scenario 2: created queue entry and in queue');

      dialogTypeObs.value = DialogType.IN_QUEUE;
      observeQueueChanges(context);
    }).onError((error, stackTrace) {
      errorObs.value = (error.toString());
      printError(
          info: 'scenario 2: create queue entry error :' + error.toString());
    });
  }

  void cancelQueue() {
    queueCollection.doc(auth.currentUser?.email).delete().then((value) {
      debugPrint('left queue');
    }).onError((error, stackTrace) {
      errorObs.value = (error.toString());
      printError(info: 'leave queue error :' + error.toString());
    });
  }

  //this method will be triggered if another player is matched with this player
  void observeQueueChanges(BuildContext context) {
    queueEntryListener = queueCollection
        .doc(auth.currentUser?.email)
        .snapshots()
        .listen((queueEntryJson) {
      var queueEntry = QueueEntryModel.fromJson(queueEntryJson.data());
      if (queueEntry.players.length > 1) {
        dialogTypeObs.value = DialogType.FOUND_MATCH;
        startGame();
        debugPrint(
            'scenario 2: another play is add to my entry, match should start');
      } else {
        debugPrint('scenario 2: still one player: ' +
            queueEntry.players.length.toString());
      }
    });

    queueEntryListener?.onError((error, stackTrace) {
      errorObs.value = (error.toString());
      printError(
          info: 'scenario 2: observing my queue entry error :' +
              error.toString());
    });
  }

  //this method will be triggered if this player is matched with another player
  void searchAvailableQueues(BuildContext context) {
    dialogTypeObs.value = DialogType.LOADING;
    //first try to find alreay existing matching queue entry
    // .where('numberOfQuestions', isEqualTo: numOfQuestions.value.toInt())
    queueCollection
        .where('queueEntryId', isNotEqualTo: (auth.currentUser?.email))
        // .where('difficulty', isEqualTo: ((selectedDifficulty.value)))
        // .where('category', isEqualTo: ((selectedCategory.value)))
        .limit(1)
        .get()
        .then((queueEntrysJson) {
      if (queueEntrysJson.docs.isEmpty) {
        debugPrint('Scenario 1: No matches found => Goto scenario 2');
        //no suitable match found
        enterQueue(context);
      } else {
        //found suitable match, add to list of players

        queueEntrysJson.docs.forEach((queueEntryJson) {
          debugPrint('Scenario 1: match found ');
          //found successful match
          var queueEntry = QueueEntryModel.fromJson(queueEntryJson.data());
          queueEntryIdObs.value = queueEntry.queueEntryId;
          addPlayerToGamePlayers(context);
        });
      }
    }).onError((error, stackTrace) {
      errorObs.value = (error.toString());
      printError(info: 'observeOtherQueues error :' + error.toString());
    });
  }

/*  //add the player to the list of players of the found queue entry to begin match
  void addPlayerToGamePlayers(BuildContext context) {
    var players = [
      PlayerModel(playerEmail: auth.currentUser?.email),
      PlayerModel(playerEmail: queueEntryIdObs.value),
    ];

    var queueEntryModel = QueueEntryModel(
        selectedDifficultyObs.value,
        selectedCategoryObs.value,
        numOfQuestionsObs.value.toInt(),
        queueEntryIdObs.value,
        players);

    queueEntryModelObs.value = queueEntryModel;

    var queueEntryModelJson = queueEntryModelToJson(queueEntryModel);

    queueCollection
        .doc(queueEntryModel.queueEntryId)
        .set(queueEntryModelJson)
        .then((value) {
      dialogTypeObs.value = DialogType.FOUND_MATCH;
      startGame();
      debugPrint('Scenario 1: add player to game players now start match');
    }).onError((error, stackTrace) {
      errorObs.value = (error.toString());
      debugPrint(
          'Scenario 1: add player to game players error :' + error.toString());
    });
  }*/

  //add the player to the list of players of the found queue entry to begin match
  void addPlayerToGamePlayers(BuildContext context) {
    FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get the document
      DocumentSnapshot snapshot =
          await transaction.get(queueCollection.doc(queueEntryIdObs.value));

      if (!snapshot.exists) {
        throw Exception("Queue entry does not exist!");
      }

      var _queueEntryModel = QueueEntryModel.fromJson(snapshot.data());

      //this should never happen
      if (_queueEntryModel.players.length >= 2) {
        print("Scenario 1: game is already full");
        return;
      }

      _queueEntryModel.players.add(
        PlayerModel(playerEmail: auth.currentUser?.email),
      );
      queueEntryModelObs.value = _queueEntryModel;

      transaction.update(
          queueCollection.doc(queueEntryModelObs.value?.queueEntryId),
          queueEntryModelToJson(_queueEntryModel));
    }).then((value) {
      dialogTypeObs.value = DialogType.FOUND_MATCH;
      startGame();
      debugPrint('Scenario 1: add player to game players now start match');
    }).catchError((error) {
      errorObs.value = (error.toString());
      printError(
          info: 'Scenario 1: add player to game players error :' +
              error.toString());
    });
  }

  //download quiz and begin match
  void startGame() {
    //both players will call this method, so only the user who created the queueEntry will
    //load quiz from Api then upload it to queueEntry node, and the other player
    // will listen to changes in queueEntry node
    if (queueEntryIdObs.value == auth.currentUser?.email) {
      //stop receiving updates for this queue entry
      queueEntryListener?.cancel();
      fetchQuiz();
    } else {
      //observe to begin match when the questions are loaded
      observeQueueQuestionChanges();
    }
  }

  void fetchQuiz() {
    debugPrint('fetchQuiz');

    var categoryApi;
    var difficultyApi;

    Constants.categoryList.forEach((categoryMap) {
      if (categoryMap['category'] == selectedCategoryObs.value) {
        categoryApi = categoryMap['api'];
      }
    });

    Constants.difficultyList.forEach((difficultyMap) {
      if (difficultyMap['difficulty'] == selectedDifficultyObs.value) {
        difficultyApi = difficultyMap['api'];
      }
    });

    DioHelper.getQuestions(queryParams: {
      'difficulty': difficultyApi,
      'amount': numOfQuestionsObs.value.toInt(),
      'category': categoryApi,
      'type': 'multiple',
    }).then((jsonResponse) {
      ApiModel apiModel = ApiModel.fromJson(jsonResponse.data);
      if (apiModel.responseCode == null && apiModel.responseCode != 0) {
        errorObs.value = 'error_loading_quiz'.tr;

        printError(info: 'error loading questions from API');
      } else {
        uploadQuiz(apiModel.questions);
      }
    }).onError((error, stackTrace) {
      printError(info: 'error loading questions from API' + error.toString());
      errorObs.value =
          'this_error_occurred_while_loading_quiz'.tr + error.toString();
    });
  }

  void uploadQuiz(questions) {
    debugPrint('uploadQuiz');

    var questionsJson = [];
    questions.forEach((question) {
      questionsJson.add(questionModelToJson(question));
    });
    //upload quiz to firestore
    queueCollection.doc(queueEntryIdObs.value).update({
      'questions': questionsJson,
      'createdAt': DateTime.now().millisecondsSinceEpoch
    }).then((value) {
      queueCollection.doc(queueEntryIdObs.value).get().then((value) {
        dialogTypeObs.value = DialogType.HIDE; //hide any dialog alerts
        Get.to(() => VersusRandomQuizScreen(),
            arguments: QueueEntryModel.fromJson(value.data()));
      }).onError((error, stackTrace) {
        printError(
            info: 'firestore get new after add questions error : ' +
                error.toString());

        errorObs.value = (error.toString());
      });
    }).onError((error, stackTrace) {
      errorObs.value = (error.toString());
      printError(info: 'firestore add questions error : ' + error.toString());
    });
  }

  void observeQueueQuestionChanges() {
    observeQueueQuestionChangesStreamSubscription = queueCollection
        .doc(queueEntryIdObs.value)
        .snapshots()
        .listen((queueEntryJson) {
      if (!queueEntryJson.exists) {
        errorObs.value = 'Something went wrong';
      }
      debugPrint('observeQueueQuestionChanges success :');
      var queueEntry = QueueEntryModel.fromJson(queueEntryJson.data());
      if (queueEntry.questions.isNotEmpty) {
        debugPrint('queueEntry.questions.isNotEmpty');
        observeQueueQuestionChangesStreamSubscription?.cancel();
        Get.to(() => VersusRandomQuizScreen(), arguments: queueEntry);
      } else {
        printError(info: 'queueEntry.questions.isEmpty');
      }
    });

    observeQueueQuestionChangesStreamSubscription?.onError((error, stackTrace) {
      errorObs.value = (error.toString());
      printError(
          info: 'observeQueueQuestionChanges error :' + error.toString());
    });
  }
}
