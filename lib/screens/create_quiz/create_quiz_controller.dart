import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:realtime_quizzes/models/category.dart';
import 'package:realtime_quizzes/models/quiz_specs.dart';
import 'package:realtime_quizzes/shared/constants.dart';

import '../../models/difficulty.dart';
import '../single_player_quiz/single_player_quiz_screen.dart';

class CreateQuizController extends GetxController {
  var numOfQuestions = 10.00.obs;
  var selectedCategory = Category('general_knowledge'.tr, 9).obs;
  var selectedDifficulty = Difficulty('medium'.tr, 'medium').obs;

  goToQuizScreen(String gameType) {
    switch (gameType) {
      case GameType.SINGLE:
        {
          Get.to(() => SinglePlayerQuizScreen(),
              arguments: QuizSpecs(numOfQuestions.value.toInt(),
                  selectedCategory.value, selectedDifficulty.value));
        }
        break;

      case GameType.VS_FRIEND:
        {
          //todo
        }
        break;

      case GameType.VS_RANDOM:
        {
          //todo
        }
        break;

      case GameType.VS_RANDOMS:
        {
          //todo
        }
        break;

      default:
        {
          //statements;
        }
        break;
    }
  }
}
