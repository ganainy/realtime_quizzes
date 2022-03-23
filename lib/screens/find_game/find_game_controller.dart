import 'dart:async';

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

  //for the variables that needs to be observed from controller
  var isObserveCalledObs = false.obs; //to make sure observe() called only once
  var dialogTypeObs = Rxn<DialogType?>();
  observe(BuildContext context) {
    var _context =
        context; //to have the most recent context with each build call
    if (isObserveCalledObs.value) return;
    isObserveCalledObs.value = true;

    dialogTypeObs.listen((dialogType) {
      switch (dialogType) {
        case DialogType.IN_QUEUE:
          Get.back();
          inQueueDialog(_context);
          break;
        case DialogType.FOUND_MATCH:
          Get.back();
          foundMatchDialog(_context);
          break;
        case DialogType.LOADING:
          Get.back();
          loadingDialog(_context);
          break;
        case DialogType.HIDE:
          Get.back();
          break;
        default:
          Get.back();
          break;
      }
    });

    errorObs.listen((error) {
      cancelQueue();
      Get.back();
      errorDialog(_context);
    });
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
      debugPrint('scenario 2: create queue entry error :' + error.toString());
    });
  }

  inQueueDialog(BuildContext context) {
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

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("In queue"),
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
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  loadingDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        cancelQueue();
        Get.back();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Looking for games online"),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: const [
          CircularProgressIndicator(),
        ],
      ),
      actions: [
        cancelButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  errorDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Ok"),
      onPressed: () {
        cancelQueue();
        Get.back();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Error"),
      content: Text("${errorObs.value ?? ''}"),
      actions: [
        cancelButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  foundMatchDialog(BuildContext context) {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Found match"),
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
      actions: [],
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void cancelQueue() {
    queueCollection.doc(auth.currentUser?.email).delete().then((value) {
      debugPrint('left queue');
    }).onError((error, stackTrace) {
      errorObs.value = (error.toString());
      debugPrint('leave queue error :' + error.toString());
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
      debugPrint(
          'scenario 2: observing my queue entry error :' + error.toString());
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
          debugPrint('wtf: ${queueEntryJson.data().toString()}');
          addPlayerToGamePlayers(context);
        });
      }
    }).onError((error, stackTrace) {
      errorObs.value = (error.toString());
      debugPrint('observeOtherQueues error :' + error.toString());
    });
  }

  //add the player to the list of players of the found queue entry to begin match
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

        debugPrint('error loading questions from API');
      } else {
        uploadQuiz(apiModel.questions);
      }
    }).onError((error, stackTrace) {
      debugPrint('error loading questions from API' + error.toString());
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
    queueCollection
        .doc(queueEntryIdObs.value)
        .update({'questions': questionsJson}).then((value) {
      queueCollection.doc(queueEntryIdObs.value).get().then((value) {
        dialogTypeObs.value = DialogType.HIDE; //hide any dialog alerts
        Get.to(() => VersusRandomQuizScreen(),
            arguments: QueueEntryModel.fromJson(value.data()));
      }).onError((error, stackTrace) {
        debugPrint('firestore get new after add questions error : ' +
            error.toString());
        errorObs.value = (error.toString());
      });
    }).onError((error, stackTrace) {
      errorObs.value = (error.toString());
      debugPrint('firestore add questions error : ' + error.toString());
    });
  }

  void observeQueueQuestionChanges() {
    StreamSubscription streamSubscription = queueCollection
        .doc(queueEntryIdObs.value)
        .snapshots()
        .listen((queueEntryJson) {
      if (!queueEntryJson.exists) {
        errorObs.value = 'Something went wrong';
      }
      debugPrint('observeQueueQuestionChanges success :' +
          queueEntryJson.data().toString());
      var queueEntry = QueueEntryModel.fromJson(queueEntryJson.data());
      if (queueEntry.questions.isNotEmpty) {
        Get.to(() => VersusRandomQuizScreen(), arguments: queueEntry);
        dialogTypeObs.value = DialogType.HIDE; //hide any dialog alerts
      }
    });

    streamSubscription.onError((error, stackTrace) {
      errorObs.value = (error.toString());
      debugPrint('observeQueueQuestionChanges error :' + error.toString());
    });
  }
}
