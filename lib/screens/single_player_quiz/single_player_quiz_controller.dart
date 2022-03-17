import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:realtime_quizzes/models/quiz_specs.dart';
import 'package:realtime_quizzes/network/dio_helper.dart';

import '../../models/questions.dart';

class SinglePlayerQuizController extends GetxController {
  var questions = [].obs;
  var currentQuestionIndex = 1.obs;

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
}
