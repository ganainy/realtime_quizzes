import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../models/single_player_quiz_result.dart';
import '../single_player_quiz_result.dart';

class VersusRandomQuizController extends GetxController {
  var questions = [].obs;
  var currentQuestionIndex = 0.obs;
  var currentScore = 0.obs;
  var isQuestionAnswered = false.obs;
  var timerValue = 0.obs;

  var rightAnswerIndex = Rxn<int>();
  var wrongAnswerIndex = Rxn<int>();
  var selectedAnswer = Rxn<String>();
  var timerCounter = Rxn<int>();

  void checkAnswer({
    //answer that user selected or null if timer runs out without any answer selected
    required String answer,
  }) {
    //user already selected an answer or time runs out -> stop timer
    cancelTimer();

    String correctAnswer =
        questions.value.elementAt(currentQuestionIndex.value).correctAnswer;

    if (answer == correctAnswer) {
      currentScore.value++;
    } else {
      //this string to only show red background on the selected item
      selectedAnswer.value = answer;
    }

    //this flag used to show green background for right answer
    isQuestionAnswered.value = true;

    //wait two seconds and show next answer or show quiz result if no more questions
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (currentQuestionIndex.value >= questions.value.length - 1) {
        endQuiz();
      } else {
        currentQuestionIndex++;
        //reset
        isQuestionAnswered.value = false;
        startTimer();
      }
    });
  }

  //this method is called when time runs out and user doesn't select an answer
  void showRightAnswer() {
    cancelTimer();

    String correctAnswer =
        questions.value.elementAt(currentQuestionIndex.value).correctAnswer;

    //this flag used to show green background for right answer
    isQuestionAnswered.value = true;

    //wait two seconds and show next answer or show quiz result if no more questions
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (currentQuestionIndex.value >= questions.value.length - 1) {
        endQuiz();
      } else {
        currentQuestionIndex++;
        //reset
        isQuestionAnswered.value = false;
        startTimer();
      }
    });
  }

  //skip remaining questions and jump to result screen
  void endQuiz() {
    cancelTimer();

    Get.off(() => SinglePlayerQuizResultScreen(),
        arguments:
            SinglePlayerQuizResult(currentScore.value, questions.value.length));
  }

  Timer? _timer;
  final oneSec = const Duration(seconds: 1);

  // start 10 sec timer as time limit for question
  void startTimer() {
    debugPrint('startTimer()');
    //reset timer if it was running to begin again from 10
    cancelTimer();
    timerCounter.value = 4; //todo 10sec

    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (timerCounter.value == 0) {
          cancelTimer();
          showRightAnswer();
          debugPrint('timer ended');
        } else {
          timerCounter.value = timerCounter.value! - 1;
          debugPrint('counter:' + timerCounter.toString());
        }
      },
    );
  }

  void cancelTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
  }
}
