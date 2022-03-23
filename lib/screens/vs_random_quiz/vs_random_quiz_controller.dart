import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:realtime_quizzes/models/player.dart';
import 'package:realtime_quizzes/models/question.dart';
import 'package:realtime_quizzes/models/queue_entry.dart';
import 'package:realtime_quizzes/shared/shared.dart';

import '../vs_random_result/vs_random_result_screen.dart';

class VersusRandomQuizController extends GetxController {
  //fire store
  var queueEntryModelObs = Rxn<QueueEntryModel?>();
  var questionsObs = [].obs;
  var currentQuestionObs = Rxn<QuestionModel?>();
  var correctAnswerObs = Rxn<String>();
  var players = Rxn<List<PlayerModel?>>();
  var loggedPlayer = Rxn<PlayerModel?>();
  var otherPlayer = Rxn<PlayerModel?>();

  //local
  var timerValueObs = 0.obs;
  var nextQuestionTimerValueObs = 0.obs;
  var currentQuestionIndexObs = 0.obs;
  var isQuestionAnsweredObs = false.obs;
  var isQuestionTimeEndedObs = false.obs;
  var isGameAlreadyStartedObs = false.obs;
  var selectedAnswerLocalObs =
      Rxn<String?>(); //to show orange background for answer selected by user
  var wrongAnswerObs = Rxn<int>();
  Timer? _timer;
  Timer? _nextQuestionTimer;
  StreamSubscription? observeGameListener;

  //with every read to queue entry we update all values
  void updateValues(QueueEntryModel queueEntryModel) {
    queueEntryModelObs.value = queueEntryModel;
    questionsObs.value = queueEntryModel.questions;
    currentQuestionObs.value =
        questionsObs.value.elementAt(currentQuestionIndexObs.value);
    correctAnswerObs.value = queueEntryModel.questions
        .elementAt(currentQuestionIndexObs.value)
        ?.correctAnswer;
    players.value = queueEntryModel.players;
    queueEntryModel.players.forEach((player) {
      if (player?.playerEmail == auth.currentUser?.email) {
        loggedPlayer.value = player;
      } else {
        otherPlayer.value = player;
      }
    });
  }

  void updateIndex() {
    currentQuestionObs.value =
        questionsObs.value.elementAt(currentQuestionIndexObs.value);
    correctAnswerObs.value = currentQuestionObs.value?.correctAnswer;
  }

  //save user answer in fire store
  void registerAnswer(String answer) {
    selectedAnswerLocalObs.value = answer;
    isQuestionAnsweredObs.value = true;

    FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get the document
      DocumentSnapshot snapshot = await transaction
          .get(runningCollection.doc(queueEntryModelObs.value?.queueEntryId));

      if (!snapshot.exists) {
        throw Exception("Queue entry does not exist!");
      }

      var _queueEntryModel = QueueEntryModel.fromJson(snapshot.data());
      updateValues(_queueEntryModel);

      _queueEntryModel.players.forEach((player) {
        if (player?.playerEmail == auth.currentUser?.email) {
          player?.answers.add(answer);
        }
      });
      transaction.update(
          runningCollection.doc(queueEntryModelObs.value?.queueEntryId),
          queueEntryModelToJson(_queueEntryModel));
    }).then((value) {
      print("added answer to player $value");
    }).catchError((error) => print("Failed to update player answers: $error"));
  }

  //marks player state as ready- match begins when all players ready
  setPlayerReady(QueueEntryModel queueEntryModel) {
    FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get the document
      DocumentSnapshot snapshot = await transaction
          .get(runningCollection.doc(queueEntryModel.queueEntryId));

      if (!snapshot.exists) {
        throw Exception("Queue entry does not exist!");
      }

      var _queueEntryModel = QueueEntryModel.fromJson(snapshot.data());

      _queueEntryModel.players.forEach((player) {
        if (player?.playerEmail == auth.currentUser?.email) {
          player?.isReady = true;
        }
      });
      transaction.update(runningCollection.doc(queueEntryModel.queueEntryId),
          queueEntryModelToJson(_queueEntryModel));
    }).then((value) {
      observeGame(queueEntryModel.queueEntryId);
      print("Player set to ready $value");
    }).catchError(
        (error) => print("Failed to update player ready state: $error"));
  }

  void observeGame(String? queueEntryId) {
    observeGameListener =
        runningCollection.doc(queueEntryId).snapshots().listen((event) {
      QueueEntryModel _queueEntryModel = QueueEntryModel.fromJson(event.data());

      //do nothing if not all players ready
      bool someoneNotReady = false;
      _queueEntryModel.players.forEach((player) {
        if (player != null && !player.isReady) {
          someoneNotReady = true;
        }
      });
      if (someoneNotReady) {
        debugPrint('not all players ready yet');
        return;
      }

      ///
      updateValues(_queueEntryModel);
      if (!isGameAlreadyStartedObs.value) {
        debugPrint('all ready start game');
        startQuestionTimer();
        isGameAlreadyStartedObs.value = true;
      }
    });

    observeGameListener?.onError((error) {
      printError(info: 'listen to ready state error ' + error.toString());
    });
  }

  //update current question index in firestore so game goes to next question
  void updateCurrentQuestionIndex() {
    //reset local selected answer to remove selected answer yellow  background
    selectedAnswerLocalObs.value = null;
    //reset question to not answered to remove red and green answer background
    isQuestionAnsweredObs.value = false;
    //reset question to not answered to remove red and green answer background
    isQuestionTimeEndedObs.value = false;
    //update current question index to show next question
    currentQuestionIndexObs.value++;
    updateIndex();
    //start timer again for the new question
    startQuestionTimer();
  }

  //this method is called when time runs out and user doesn't select an answer
  void updateScores() {
    cancelTimer(_timer);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get the document
      DocumentSnapshot snapshot = await transaction
          .get(runningCollection.doc(queueEntryModelObs.value?.queueEntryId));

      if (!snapshot.exists) {
        throw Exception("Queue entry does not exist!");
      }

      var _queueEntryModel = QueueEntryModel.fromJson(snapshot.data());
      updateValues(_queueEntryModel);

      _queueEntryModel.players.forEach((player) {
        //increase player score if right answer
        if (player?.playerEmail == auth.currentUser?.email &&
            player!.answers.length > currentQuestionIndexObs.value &&
            player.answers.elementAt(currentQuestionIndexObs.value) ==
                currentQuestionObs.value?.correctAnswer) {
          player.score = player.score + 1;
        }
      });
      transaction.update(
          runningCollection.doc(queueEntryModelObs.value?.queueEntryId),
          queueEntryModelToJson(_queueEntryModel));
    }).then((value) {
      print("updated player scores $value");
    }).catchError((error) {
      printError(info: "Failed to update player scores: $error");
    });
  }

  void showResultScreen() {
    observeGameListener?.cancel(); //game is over, stop listening to changes
    Get.off(() => VersusRandomResultScreen(),
        arguments: queueEntryModelObs.value);
  }

  // start 10 sec timer as time limit for question
  void startQuestionTimer() {
    debugPrint('startTimer()');
    //reset timer if it was running to begin again from 10
    cancelTimer(_timer);
    timerValueObs.value = 10;
    isQuestionTimeEndedObs.value = false;

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (timerValueObs.value == 0) {
          cancelTimer(_timer);
          //register answer as empty if no answer selected
          if (selectedAnswerLocalObs.value == null) registerAnswer('');
          //increase score if player got correct answer
          updateScores();
          //wait two seconds and show next answer or show quiz result if no more questions
          waitThenUpdateQuestionIndex();
          debugPrint('timer ended');
        } else {
          timerValueObs.value = timerValueObs.value - 1;
          debugPrint('counter:' + timerValueObs.toString());
        }
      },
    );
  }

  void startNextQuestionTimer() {
    debugPrint('startNextQuestionTimer()');
    //reset timer if it was running to begin again from 10
    cancelTimer(_nextQuestionTimer);
    nextQuestionTimerValueObs.value = 5;

    _nextQuestionTimer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (nextQuestionTimerValueObs.value == 0) {
          cancelTimer(_nextQuestionTimer);
          debugPrint('timer ended');
        } else {
          nextQuestionTimerValueObs.value = nextQuestionTimerValueObs.value - 1;
          debugPrint('counter:' + nextQuestionTimerValueObs.toString());
        }
      },
    );
  }

  void waitThenUpdateQuestionIndex() {
    isQuestionTimeEndedObs.value = true;

    //no more question show result
    if (currentQuestionIndexObs
        .value /*>*/ == /*questionsObs.value.length -*/ 0) {
      Future.delayed(const Duration(seconds: 5), () {
        showResultScreen();
      });
    } else {
      //show next question
      startNextQuestionTimer();

      Future.delayed(const Duration(seconds: 5), () {
        updateCurrentQuestionIndex();
      });
    }
  }

  void cancelTimer(Timer? _timer) {
    if (_timer != null) {
      _timer.cancel();
    }
  }

  //return true if answer is right
  bool getIsCorrectAnswer(String text) {
    return (isQuestionTimeEndedObs.value &&
        currentQuestionObs.value?.correctAnswer == text);
  }

  //return true if answer is wrong and user selected it
  bool getIsSelectedWrongAnswer(String text) {
    return (loggedPlayer.value!.answers.length >
            currentQuestionIndexObs.value &&
        isQuestionTimeEndedObs.value &&
        loggedPlayer.value?.answers.elementAt(currentQuestionIndexObs.value) ==
            text);
  }

  //this flag used to show logged player avatar beside the selected answer
  bool getIsSelectedLoggedPlayer(String text) {
    return isQuestionTimeEndedObs.value &&
        loggedPlayer.value!.answers.length > currentQuestionIndexObs.value &&
        text ==
            loggedPlayer.value?.answers
                .elementAt(currentQuestionIndexObs.value);
  }

  //this flag used to show other player avatar beside the selected answer
  bool getIsSelectedOtherPlayer(String text) {
    return isQuestionTimeEndedObs.value &&
        otherPlayer.value!.answers.length > currentQuestionIndexObs.value &&
        text ==
            otherPlayer.value?.answers.elementAt(currentQuestionIndexObs.value);
  }

  //this flag used to show orange background to indicate that player selected this answer
  getIsSelectedLocalAnswer(String text) {
    return isQuestionAnsweredObs.value && text == selectedAnswerLocalObs.value;
  }

  //this method moves game to running collection in firebase (only unstarted games should be in queue)
  moveToRunning(QueueEntryModel queueEntry) {
    runningCollection
        .doc(queueEntry.queueEntryId)
        .set(queueEntryModelToJson(queueEntry))
        .then((value) {
      debugPrint('added to running collection');
      queueCollection.doc(queueEntry.queueEntryId).delete().then((value) {
        debugPrint('removed from queue collection');
        setPlayerReady(queueEntry);
      }).onError((error, stackTrace) {
        printError(info: 'error remove from queue collection');
      });
    }).onError((error, stackTrace) {
      printError(info: 'error add to running collection');
    });
  }
}
