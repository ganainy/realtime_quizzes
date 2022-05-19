import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:realtime_quizzes/layouts/home/home.dart';
import 'package:realtime_quizzes/main_controller.dart';
import 'package:realtime_quizzes/models/game.dart';
import 'package:realtime_quizzes/models/player.dart';
import 'package:realtime_quizzes/shared/shared.dart';

import '../../models/game_type.dart';
import '../result/result_screen.dart';

class MultiPlayerQuizController extends GetxController {
  //fire store
  var gameObs = Rxn<GameModel?>();

  PlayerModel? loggedPlayer;
  PlayerModel? opponent;

  //local
  var timerValueObs = 0.obs; //question timer
  var nextQuestionTimerValueObs = 0.obs; //timer for interval between questions
  var currentQuestionIndexObs = 0.obs;
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
  var rightAnswers; //list of string

  @override
  void onInit() {
    mainController = Get.find<MainController>();

    observeGame();

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
    if (gameObs.value == null) return;

    Shared.game = gameObs.value!;

    rightAnswers =
        gameObs.value?.questions?.map((e) => e?.correctAnswer).toList();

    Shared.game.players?.forEach((player) {
      if (player!.user!.email == Shared.loggedUser!.email) {
        loggedPlayer = player;
      } else {
        opponent = player;
      }
    });
  }

  //save user answer in fire store
  void registerAnswer(String answer) {
    debugPrint('register answer: ${answer} ');

    selectedAnswerLocalObs.value = answer;

    FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get the document
      DocumentSnapshot snapshot =
          await transaction.get(gameCollection.doc(gameObs.value?.gameId));

      if (!snapshot.exists) {
        throw Exception("Game entry does not exist!");
      }

      var game = GameModel.fromJson(snapshot.data());

      //add answer to logged player answers
      game.players?.forEach((player) {
        if (player?.user?.email == Shared.loggedUser?.email) {
          player?.answers.add(answer);

          transaction.update(
              gameCollection.doc(gameObs.value?.gameId), gameModelToJson(game));
        }
      });
    });
  }

  //this method will listen to any change in game and update UI accordingly
  void observeGame() {
    observeGameListener =
        gameCollection.doc(Shared.game.gameId).snapshots().listen((event) {
      gameObs.value = GameModel.fromJson(event.data());
      updateValues();

      //if game didn't already start, check if all players ready then
      // start game && load players profiles otherwise do nothing
      if (!isGameAlreadyStarted) {
        isGameAlreadyStarted = true;
        startQuestionTimer();
      }

      if (gameObs.value!.players!.length > 2) {
        Exception('game has more than 2 players');
      }

      if (gameObs.value?.gameStatus == GameStatus.ABANDONED) {
        mainController.deleteGame(gameObs.value?.gameId);
        observeGameListener?.cancel();
        cancelTimer(_timer);
        Get.to(() => HomeScreen());
        mainController.showInfoDialog(
            title: 'Game terminated', message: 'Reason: player left the game');
      }

      //calculate player score
      var _score = 0;
      Shared.game.players?.forEach((player) {
        if (player?.user?.email == Shared.loggedUser?.email) {
          player?.answers.forEach((answer) {
            if (rightAnswers.contains(answer)) {
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
    isQuestionTimeEndedObs.value = false;
    //update current question index to show next question
    currentQuestionIndexObs.value++;
    //start timer again for the new question
    startQuestionTimer();
  }

  //this method is called when time runs out and user doesn't select an answer
  void updateScore(int newScore) {
    FirebaseFirestore.instance
        .runTransaction((transaction) async {
          // Get the document
          DocumentSnapshot snapshot =
              await transaction.get(gameCollection.doc(gameObs.value?.gameId));

          if (!snapshot.exists) {
            throw Exception("Queue entry does not exist!");
          }

          var _queueEntry = GameModel.fromJson(snapshot.data());

          _queueEntry.players?.forEach((player) {
            if (player?.user?.email == Shared.loggedUser?.email) {
              player?.score = newScore;
            }
          });

          transaction.update(gameCollection.doc(gameObs.value?.gameId),
              gameModelToJson(_queueEntry));
        })
        .then((value) {})
        .catchError((error) =>
            printError(info: "Failed to upload player score: $error"));
  }

  void showResultScreen() {
    Get.off(() => ResultScreen(), arguments: {
      'queueEntry': gameObs.value,
      'gameType': GameType.MULTI,
    });
  }

  // start 10 sec timer as time limit for question && increase index to show
  //next question or result on countdown end
  void startQuestionTimer() {
    //reset timer if it was running to begin again from 10
    timerValueObs.value = 10;
    isQuestionTimeEndedObs.value = false;

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (timerValueObs.value == 0) {
          cancelTimer(_timer);
          //wait two seconds and show next answer or show quiz result if no more questions
          waitThenUpdateQuestionIndex();
        } else {
          timerValueObs.value = timerValueObs.value - 1;
        }
      },
    );
  }

  void startNextQuestionTimer() {
    //reset next question timer to begin again from 5
    nextQuestionTimerValueObs.value = 5;

    _nextQuestionTimer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (nextQuestionTimerValueObs.value == 0) {
          cancelTimer(_nextQuestionTimer);
        } else {
          nextQuestionTimerValueObs.value = nextQuestionTimerValueObs.value - 1;
        }
      },
    );
  }

  void waitThenUpdateQuestionIndex() {
    updateScore(_loggedUserScore);

    isQuestionTimeEndedObs.value = true;
    //no more question show result
    if (currentQuestionIndexObs.value + 1 >= Shared.game.questions!.length) {
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
        Shared.game.questions
                ?.elementAt(currentQuestionIndexObs.value)
                ?.correctAnswer ==
            text);
  }

/*  Future<void> moveGameToQueue() async {
    return await gamesCollection.doc(Shared.game.queueEntryId).set(
          gameToJson(Shared.game),
        );
  }*/

  /// flag functions */

  //this flag used to show orange background to indicate that player selected this answer
  getIsSelectedLocalAnswer(String text) {
    return text == selectedAnswerLocalObs.value;
  }

  bool isQuestionNotAnswered() {
    return selectedAnswerLocalObs.value == null;
  }

  //return true if answer is wrong and user selected it
  bool getIsSelectedWrongAnswer(String text) {
    try {
      return (isQuestionTimeEndedObs.value &&
          !rightAnswers!.contains(text) &&
          loggedPlayer!.answers.contains(text));
    } catch (e) {
      return false;
    }
  }

  //this flag used to show logged player avatar beside the selected answer
  bool getIsSelectedLoggedPlayer(String text) {
    try {
      return isQuestionTimeEndedObs.value &&
          loggedPlayer!.answers.contains(text);
    } catch (e) {
      return false;
    }
  }

  //this flag used to show other player avatar beside the selected answer
  bool getIsSelectedOpponent(String text) {
    try {
      return isQuestionTimeEndedObs.value && opponent!.answers.contains(text);
    } catch (e) {
      return false;
    }
  }
}
