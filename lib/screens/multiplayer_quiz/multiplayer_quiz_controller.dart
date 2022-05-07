import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:realtime_quizzes/main_controller.dart';
import 'package:realtime_quizzes/models/answer.dart';
import 'package:realtime_quizzes/models/game_type.dart';
import 'package:realtime_quizzes/models/player.dart';
import 'package:realtime_quizzes/models/queue_entry.dart';
import 'package:realtime_quizzes/shared/shared.dart';

import '../result/result_screen.dart';

class MultiPlayerQuizController extends GetxController {
  //fire store
  var queueEntryModelObs = Rxn<QueueEntryModel?>();
/*  var questionsObs = [].obs;
  var currentQuestionObs = Rxn<QuestionModel?>();
  var correctAnswerObs = Rxn<String>();
  var players = Rxn<List<PlayerModel?>>();
  var opponentObs = Rxn<PlayerModel?>();*/
  PlayerModel? loggedPlayer;
  PlayerModel? opponent;

  //local
  var timerValueObs = 0.obs; //question timer
  var nextQuestionTimerValueObs = 0.obs; //timer for interval between questions
  var currentQuestionIndexObs = 0.obs;
  var isQuestionAnswered = false;
  var isQuestionTimeEndedObs =
      false.obs; //flag used to show right answer when time is ended
  var isGameAlreadyStarted = false;
  var selectedAnswerLocalObs =
      Rxn<String?>(); //to show orange background for answer selected by user

  var wrongAnswerObs = Rxn<int>();
  Timer? _timer;
  Timer? _nextQuestionTimer;
  StreamSubscription? observeGameListener;

  //to calculate player score and only update it when different as old score
  var _loggedUserScore = 0;
  late MainController mainController;

  @override
  void onInit() {
    mainController = Get.find<MainController>();

    if (Shared.queueEntryModel.invitedFriend != null &&
        Shared.loggedUser!.email == Shared.queueEntryModel.queueEntryId) {
      //this means that game is between friends
      moveGameToQueue().then((_) {
        //observe game
        observeGame();
        //delete game from invites coming to user since game will begin
        deleteFromInvites().onError((error, stackTrace) {
          printError(info: 'error deleteFromInvites' + error.toString());
        });
      }).onError((error, stackTrace) {
        printError(info: 'error moveGameToQueue' + error.toString());
        mainController.errorDialog('Error starting game');
        deleteFromInvites();
      });
    } else {
      //observe game(this is randoms game)
      observeGame();
    }

    super.onInit();
  }

  @override
  void onClose() {
    observeGameListener?.cancel();
    cancelTimer(_timer);
    super.onClose();
  }

  //with every read to queue entry we update all values
  void updateValues() {
    queueEntryModelObs.value = Shared.queueEntryModel;

    Shared.queueEntryModel.players?.forEach((player) {
      if (player!.user!.email == Shared.loggedUser!.email) {
        loggedPlayer = player;
      } else {
        opponent = player;
      }
    });
  }

  //save user answer in fire store
  void registerAnswer(String answer) {
    selectedAnswerLocalObs.value = answer;
    isQuestionAnswered = true;

    var _isCorrectAnswer = queueEntryModelObs.value?.questions!
            .elementAt(currentQuestionIndexObs.value)
            ?.correctAnswer ==
        answer;

    queueEntryModelObs.value?.players?.forEach((player) {
      if (player?.user?.email == Shared.loggedUser?.email) {
        var answers = addUniqueAnswer(
            answer:
                AnswerModel(answer: answer, isCorrectAnswer: _isCorrectAnswer),
            answers: player?.answers);
        player?.answers = answers;
      }
    });

    queueCollection
        .doc(queueEntryModelObs.value?.queueEntryId)
        .set(queueEntryModelToJson(queueEntryModelObs.value))
        .then((value) {
      debugPrint("added answer to player ");
    }).onError((error, stackTrace) {
      printError(info: "Failed to update player answers: $error");
    });
  }

  List<AnswerModel?> addUniqueAnswer(
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

  //this method will listen to any change in game and update UI accordingly
  void observeGame() {
    observeGameListener = queueCollection
        .doc(Shared.queueEntryModel.queueEntryId)
        .snapshots()
        .listen((event) {
      Shared.queueEntryModel = QueueEntryModel.fromJson(event.data());
      updateValues();

      //if game didn't already start, check if all players ready then
      // start game && load players profiles otherwise do nothing
      if (!isGameAlreadyStarted) {
        isGameAlreadyStarted = true;
        startQuestionTimer();
      }

      //calculate player score
      var _score = 0;
      Shared.queueEntryModel.players?.forEach((player) {
        if (player?.user?.email == Shared.loggedUser?.email) {
          player?.answers?.forEach((answer) {
            if (answer!.isCorrectAnswer) {
              _score++;
            }
          });
        }
      });
      _loggedUserScore = _score;
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
    isQuestionAnswered = false;
    //reset question to not answered to remove red and green answer background
    isQuestionTimeEndedObs.value = false;
    //update current question index to show next question
    currentQuestionIndexObs.value++;
    //start timer again for the new question
    startQuestionTimer();
  }

  //this method is called when time runs out and user doesn't select an answer
  void updateScore(int newScore) {
    FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get the document
      DocumentSnapshot snapshot = await transaction
          .get(queueCollection.doc(queueEntryModelObs.value?.queueEntryId));

      if (!snapshot.exists) {
        throw Exception("Queue entry does not exist!");
      }

      var _queueEntry = QueueEntryModel.fromJson(snapshot.data());

      _queueEntry.players?.forEach((player) {
        if (player?.user?.email == Shared.loggedUser?.email) {
          player?.score = newScore;
        }
      });

      transaction.update(
          queueCollection.doc(queueEntryModelObs.value?.queueEntryId),
          queueEntryModelToJson(_queueEntry));
    }).then((value) {
      debugPrint("updated player scores");
    }).catchError(
        (error) => printError(info: "Failed to upload player score: $error"));
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
    updateScore(_loggedUserScore);

    isQuestionTimeEndedObs.value = true;
    //no more question show result
    if (currentQuestionIndexObs.value + 1 >=
        Shared.queueEntryModel.questions!.length) {
      Future.delayed(const Duration(seconds: 4), () {
        showResultScreen();
      });
    } else {
      //show countdown to indicate that new question will be shown in 5 seconds
      startNextQuestionTimer();
      //show next question
      Future.delayed(const Duration(seconds: 4), () {
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
        Shared.queueEntryModel.questions
                ?.elementAt(currentQuestionIndexObs.value)
                ?.correctAnswer ==
            text);
  }

  //return true if answer is wrong and user selected it
  bool getIsSelectedWrongAnswer(String text) {
    return (loggedPlayer!.answers!.length > currentQuestionIndexObs.value &&
        isQuestionTimeEndedObs.value &&
        loggedPlayer!.answers!
                .elementAt(currentQuestionIndexObs.value)
                ?.answer ==
            text);
  }

  //this flag used to show logged player avatar beside the selected answer
  bool getIsSelectedLoggedPlayer(String text) {
    return isQuestionTimeEndedObs.value &&
        loggedPlayer!.answers!.length > currentQuestionIndexObs.value &&
        text ==
            loggedPlayer!.answers!
                .elementAt(currentQuestionIndexObs.value)
                ?.answer;
  }

  //this flag used to show other player avatar beside the selected answer
  bool getIsSelectedOtherPlayer(String text) {
    return isQuestionTimeEndedObs.value &&
        opponent!.answers!.length > currentQuestionIndexObs.value &&
        text ==
            opponent!.answers!.elementAt(currentQuestionIndexObs.value)?.answer;
  }

  //this flag used to show orange background to indicate that player selected this answer
  getIsSelectedLocalAnswer(String text) {
    return isQuestionAnswered && text == selectedAnswerLocalObs.value;
  }

  //delete from invites collection (friends game)
  Future<void> deleteFromInvites() async {
    return await invitesCollection
        .doc(Shared.queueEntryModel.queueEntryId)
        .delete();
  }

  Future<void> moveGameToQueue() async {
    return await queueCollection.doc(Shared.queueEntryModel.queueEntryId).set(
          queueEntryModelToJson(Shared.queueEntryModel),
        );
  }
}
