import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:realtime_quizzes/models/answer.dart';
import 'package:realtime_quizzes/models/game_type.dart';
import 'package:realtime_quizzes/models/player.dart';
import 'package:realtime_quizzes/models/question.dart';
import 'package:realtime_quizzes/models/queue_entry.dart';
import 'package:realtime_quizzes/shared/shared.dart';

import '../result/result_screen.dart';

class MultiPlayerQuizController extends GetxController {
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
  var isQuestionAnswered = false;
  var isQuestionTimeEndedObs = false.obs;
  var isGameAlreadyStarted = false;
  var selectedAnswerLocalObs =
      Rxn<String?>(); //to show orange background for answer selected by user
  var wrongAnswerObs = Rxn<int>();
  Timer? _timer;
  Timer? _nextQuestionTimer;
  StreamSubscription? observeGameListener;

  QueueEntryModel game;
  MultiPlayerQuizController(this.game);

  //to calculate player score and only update it when different as old score
  var _loggedUserScore = 0;

  @override
  void onInit() {
    moveToRunning(game).then((value) {
      setPlayerReady(game).then((value) {
        print("Player set to ready $value");
      }).catchError((error) {
        printError(info: "error setPlayerReady" + error.toString());
      });
      observeGame(game.queueEntryId);
      deleteFromInvites(game.queueEntryId).onError((error, stackTrace) {
        printError(info: 'error deleteFromInvites' + error.toString());
      });
      deleteFromQueue(game.queueEntryId).onError((error, stackTrace) {
        printError(info: 'error deleteFromQueue' + error.toString());
      });
    }).onError((error, stackTrace) {
      printError(info: 'error moveToRunning' + error.toString());
    });

    super.onInit();
  }

  @override
  void onClose() {
    observeGameListener?.cancel();
    super.onClose();
  }

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
    isQuestionAnswered = true;

    var _isCorrectAnswer = queueEntryModelObs.value?.questions
            .elementAt(currentQuestionIndexObs.value)
            ?.correctAnswer ==
        answer;

    queueEntryModelObs.value?.players.forEach((player) {
      if (player?.playerEmail == auth.currentUser?.email) {
        var answers = addUniqueAnswer(
            answer:
                AnswerModel(answer: answer, isCorrectAnswer: _isCorrectAnswer),
            answers: player?.answers);
        player?.answers = answers;
      }
    });

    runningCollection
        .doc(queueEntryModelObs.value?.queueEntryId)
        .set(queueEntryModelToJson(queueEntryModelObs.value))
        .then((value) {
      debugPrint("added answer to player ");
    }).onError((error, stackTrace) {
      printError(info: "Failed to update player answers: $error");
    });
  }

  List<AnswerModel> addUniqueAnswer(
      {answers: List<AnswerModel>, answer: AnswerModel}) {
    bool isUnique = true;
    answers.forEach((listItem) {
      if (listItem.answer == answer.answer) {
        isUnique = false;
      }
    });
    if (isUnique) {
      answers.add(answer);
    }
    return answers;
  }

  //marks player state as ready- match begins when all players ready
  Future<dynamic> setPlayerReady(QueueEntryModel queueEntryModel) async {
    return await FirebaseFirestore.instance.runTransaction((transaction) async {
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
    });
  }

  //this method will listen to any change in game and update UI accordingly
  void observeGame(String? queueEntryId) {
    observeGameListener =
        runningCollection.doc(queueEntryId).snapshots().listen((event) {
      QueueEntryModel _queueEntryModel = QueueEntryModel.fromJson(event.data());

      updateValues(_queueEntryModel);

      //if game didn't already start, check if all players ready then
      // start game otherwise do nothing
      if (!isGameAlreadyStarted && areAllPlayersReady(_queueEntryModel)) {
        isGameAlreadyStarted = true;
        startQuestionTimer();
      }

      //calculate player score
      var _score = 0;
      _queueEntryModel.players.forEach((player) {
        if (player?.playerEmail == auth.currentUser?.email) {
          player?.answers.forEach((answer) {
            if (answer.isCorrectAnswer) {
              _score++;
            }
          });
        }
      });
      _loggedUserScore = _score;
      updateScore(_loggedUserScore);
    });

    observeGameListener?.onError((error) {
      printError(info: 'listen to ready state error ' + error.toString());
    });
  }

  //this method checks if each player isReady
  bool areAllPlayersReady(QueueEntryModel _queueEntryModel) {
    bool someoneNotReady = false;
    _queueEntryModel.players.forEach((player) {
      if (player != null && !player.isReady) {
        someoneNotReady = true;
      }
    });

    if (someoneNotReady) {
      debugPrint('not all players ready yet');
    }

    return someoneNotReady;
  }

  //update current question index in firestore so game goes to next question
  void updateCurrentQuestionIndex() {
    //reset local selected answer to remove selected answer yellow  background
    selectedAnswerLocalObs.value = null;
    //reset question to not answered to remove red and green answer background
    isQuestionAnswered = false;
    //reset question to not answered to remove red and green answer background
    isQuestionTimeEndedObs.value = false;
    //update current question index to show next question
    currentQuestionIndexObs.value++;
    updateIndex();
    //start timer again for the new question
    startQuestionTimer();
  }

  //this method is called when time runs out and user doesn't select an answer
  void updateScore(int newScore) {
    queueEntryModelObs.value?.players.forEach((player) {
      //increase player score if right answer
      if (player?.playerEmail == auth.currentUser?.email) {
        player?.score = newScore;
      }
    });

    runningCollection
        .doc(queueEntryModelObs.value?.queueEntryId)
        .set(queueEntryModelToJson(queueEntryModelObs.value))
        .then((value) {
      debugPrint(
          "updated player scores ${auth.currentUser!.email}  ${queueEntryModelObs.value?.players.firstWhere((element) {
        return element!.playerEmail == auth.currentUser!.email;
      })?.score}");
    }).catchError((error) {
      printError(info: "Failed to update player scores: $error");
    });
  }

  void showResultScreen() {
    Get.off(() => ResultScreen(), arguments: {
      'queueEntry': queueEntryModelObs.value,
      'gameType': GameType.MULTI,
    });
  }

  // start 10 sec timer as time limit for question && increase index to show
  //next question or result on countdown end
  void startQuestionTimer() {
    debugPrint('startTimer()');
    //reset timer if it was running to begin again from 10
    timerValueObs.value = 10;
    isQuestionTimeEndedObs.value = false;

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (timerValueObs.value == 0) {
          cancelTimer(_timer);
          //register answer as empty if no answer selected
          if (selectedAnswerLocalObs.value == null) {
            registerAnswer('');
          }
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
    //reset next question timer to begin again from 5
    nextQuestionTimerValueObs.value = 10; //todo 5

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
      //show countdown to indicate that new question will be showin in 5 seconds
      startNextQuestionTimer();
      //show next question
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
    debugPrint(
        'anta atbdnt${isQuestionTimeEndedObs.value && currentQuestionObs.value?.correctAnswer == text}');
    return (isQuestionTimeEndedObs.value &&
        currentQuestionObs.value?.correctAnswer == text);
  }

  //return true if answer is wrong and user selected it
  bool getIsSelectedWrongAnswer(String text) {
    return (loggedPlayer.value!.answers.length >
            currentQuestionIndexObs.value &&
        isQuestionTimeEndedObs.value &&
        loggedPlayer.value?.answers
                .elementAt(currentQuestionIndexObs.value)
                .answer ==
            text);
  }

  //this flag used to show logged player avatar beside the selected answer
  bool getIsSelectedLoggedPlayer(String text) {
    return isQuestionTimeEndedObs.value &&
        loggedPlayer.value!.answers.length > currentQuestionIndexObs.value &&
        text ==
            loggedPlayer.value?.answers
                .elementAt(currentQuestionIndexObs.value)
                .answer;
  }

  //this flag used to show other player avatar beside the selected answer
  bool getIsSelectedOtherPlayer(String text) {
    return isQuestionTimeEndedObs.value &&
        otherPlayer.value!.answers.length > currentQuestionIndexObs.value &&
        text ==
            otherPlayer.value?.answers
                .elementAt(currentQuestionIndexObs.value)
                .answer;
  }

  //this flag used to show orange background to indicate that player selected this answer
  getIsSelectedLocalAnswer(String text) {
    return isQuestionAnswered && text == selectedAnswerLocalObs.value;
  }

  //this method moves game to running collection in firebase (only unstarted games should be in queue)
  Future<void> moveToRunning(QueueEntryModel queueEntry) async {
    return await runningCollection
        .doc(queueEntry.queueEntryId)
        .set(queueEntryModelToJson(queueEntry));
  }

  //delete from invites collection (friends game)
  Future<void> deleteFromInvites(String? queueEntryId) async {
    return await invitesCollection.doc(queueEntryId).delete();
  }

  //delete from queue collection (randoms game)
  Future<void> deleteFromQueue(String? queueEntryId) async {
    return await queueCollection.doc(queueEntryId).delete();
  }
}
