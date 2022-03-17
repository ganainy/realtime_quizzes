import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:realtime_quizzes/customization/theme.dart';
import 'package:realtime_quizzes/screens/single_player_quiz/single_player_quiz_controller.dart';

class SinglePlayerQuizScreen extends StatelessWidget {
  SinglePlayerQuizScreen({Key? key}) : super(key: key);

  final SinglePlayerQuizController singlePlayerQuizController =
      Get.put(SinglePlayerQuizController())..fetchQuiz(Get.arguments);

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: Obx(() {
        return singlePlayerQuizController.questions.value.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Question(singlePlayerQuizController);
      }),
    ));
  }

  Question(SinglePlayerQuizController singlePlayerQuizController) {
    var currentQuestion = singlePlayerQuizController.questions.value
        .elementAt(singlePlayerQuizController.currentQuestionIndex.value);
    var shuffledAnswers = currentQuestion.shuffledAnswers;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Question: ' +
            singlePlayerQuizController.currentQuestionIndex.value.toString()),
        const SizedBox(
          height: MyTheme.largePadding,
        ),
        Text(currentQuestion.question),
        const SizedBox(
          height: MyTheme.largePadding,
        ),
        Text(shuffledAnswers[0]),
        const SizedBox(
          height: MyTheme.mediumPadding,
        ),
        Text(shuffledAnswers[1]),
        const SizedBox(
          height: MyTheme.mediumPadding,
        ),
        Text(shuffledAnswers[2]),
        const SizedBox(
          height: MyTheme.mediumPadding,
        ),
        Text(shuffledAnswers[3]),
        const SizedBox(
          height: MyTheme.mediumPadding,
        ),
      ],
    );
  }
}
