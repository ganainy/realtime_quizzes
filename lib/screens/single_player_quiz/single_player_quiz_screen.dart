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
        Text('Score: ' +
            singlePlayerQuizController.currentScore.value.toString()),
        const SizedBox(
          height: MyTheme.largePadding,
        ),
        //add one to index because index starts with 0
        Text('Question: ' +
            (singlePlayerQuizController.currentQuestionIndex.value + 1)
                .toString()),
        const SizedBox(
          height: MyTheme.largePadding,
        ),
        Text(currentQuestion.question),
        const SizedBox(
          height: MyTheme.largePadding,
        ),
        ...(shuffledAnswers).map((answer) {
          return Answer(singlePlayerQuizController, answer,
              currentQuestion.correctAnswer);
        }),
        Text('temporary text right answer: ' + currentQuestion.correctAnswer)
      ],
    );
  }

  Answer(SinglePlayerQuizController singlePlayerQuizController, String answer,
      String correctAnswer) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          child: Text(answer),
          onPressed: () {
            singlePlayerQuizController.checkAnswer(answer, correctAnswer);
          },
        ),
        const SizedBox(
          height: MyTheme.mediumPadding,
        ),
      ],
    );
  }
}
