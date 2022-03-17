import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:realtime_quizzes/models/quiz_specs.dart';
import 'package:realtime_quizzes/network/dio_helper.dart';
import 'package:realtime_quizzes/screens/single_player_quiz_result.dart';

import '../../models/questions.dart';
import '../../models/single_player_quiz_result.dart';

class SinglePlayerQuizController extends GetxController {
  var questions = [].obs;
  var currentQuestionIndex = 0.obs;
  var currentScore = 0.obs;

  var errorLoadingQuestions = Rxn<String>();

  fetchQuiz(QuizSpecs quizSpecs) {
    print(quizSpecs.selectedDifficulty.difficultyType);
    DioHelper.getQuestions(queryParams: quizSpecs.toMap()).then((json) {
      QuestionsModel questionsModel = QuestionsModel.fromJson(json.data);
      if (questionsModel.questions.isEmpty) {
        errorLoadingQuestions.value = 'error_loading_quiz'.tr;
        //todo show error loading questions
      } else {
        questions.value = questionsModel.questions;
      }
    }).onError((error, stackTrace) {
      //todo show error loading questions
      errorLoadingQuestions.value =
          'this_error_occurred_while_loading_quiz'.tr + error.toString();
    });
  }

  void checkAnswer(String answer, String correctAnswer) {
    if (answer == correctAnswer) {
      currentScore.value++;
    }

    print('currentQuestionIndex' + currentQuestionIndex.toString());
    print('questions.value.length' + questions.value.length.toString());

    if (currentQuestionIndex.value >= questions.value.length - 1) {
      Get.off(() => SinglePlayerQuizResultScreen(),
          arguments: SinglePlayerQuizResult(
              currentScore.value, questions.value.length));
    } else {
      currentQuestionIndex++;
    }
  }
}
