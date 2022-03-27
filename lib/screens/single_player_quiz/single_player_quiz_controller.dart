import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:realtime_quizzes/models/game_type.dart';

import '../../models/api.dart';
import '../../models/single_player_quiz_result.dart';
import '../../network/dio_helper.dart';
import '../../shared/constants.dart';
import '../result/result_screen.dart';

class SinglePlayerQuizController extends GetxController {
  var questions = [].obs;
  var currentQuestionIndex = 0.obs;
  var currentScore = 0.obs;
  var isQuestionAnswered = false.obs;
  var timerValue = 0.obs;

  var rightAnswerIndex = Rxn<int>();
  var wrongAnswerIndex = Rxn<int>();
  var selectedAnswer = Rxn<String>();
  var timerCounter = Rxn<int>();

  var numOfQuestionsObs = 10.00.obs;
  var selectedCategoryObs = Rxn<String?>();
  var selectedDifficultyObs = Rxn<String?>();
  var errorObs = Rxn<String?>();

  var createdAt;

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

    var params = {
      'difficulty': difficultyApi,
      'amount': numOfQuestionsObs.value.toInt(),
      'category': categoryApi,
      'type': 'multiple',
    };

    //remove null parameters from queryParams so API call won't fail
    if (params['difficulty'] == null) {
      params.remove('difficulty');
    }
    if (params['category'] == null) {
      params.remove('category');
    }
    if (params['category'] == 'Random'.tr) {
      params.remove('category');
    } //this is not real category its just for UI
    debugPrint('params' + params.length.toString());

    DioHelper.getQuestions(queryParams: params).then((jsonResponse) {
      ApiModel apiModel = ApiModel.fromJson(jsonResponse.data);

      if (apiModel.responseCode == null || apiModel.responseCode != 0) {
        errorObs.value = 'error_loading_quiz'.tr;

        printError(info: 'error loading questions from API');
      } else {
        questions.value = apiModel.questions;
        startTimer();
      }
    }).onError((error, stackTrace) {
      printError(info: 'error loading questions from API' + error.toString());
      errorObs.value =
          'this_error_occurred_while_loading_quiz'.tr + error.toString();
    });
  }

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

    //wait two seconds and show next question or show quiz result if no more questions
    Future.delayed(const Duration(milliseconds: 2000), () {
      //todo remove comment
      if (currentQuestionIndex.value /* >*/ ==
          0 /* questions.value.length - 1*/) {
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
      //todo remove comment
      if (currentQuestionIndex.value /*>*/ ==
          0 /*questions.value.length - 1*/) {
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

    Get.off(() => ResultScreen(), arguments: {
      'result': SinglePlayerQuizResult(
          currentScore.value,
          questions.value.length,
          selectedCategoryObs.value,
          selectedDifficultyObs.value,
          createdAt),
      'gameType': GameType.SINGLE
    });
  }

  Timer? _timer;
  final oneSec = const Duration(seconds: 1);

  // start 10 sec timer as time limit for question
  void startTimer() {
    createdAt = DateTime.now().millisecondsSinceEpoch;
    debugPrint('startTimer()');
    //reset timer if it was running to begin again from 10
    cancelTimer();
    timerCounter.value = 5; //todo 10sec

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

  //get arguments of find game screen(difficulty-category-numOfQuestions
  setInitialData(arguments) {
    selectedCategoryObs.value = arguments['category'];
    selectedDifficultyObs.value = arguments['difficulty'];
    numOfQuestionsObs.value = arguments['numOfQuestions'];
  }
}
