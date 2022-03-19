import 'package:flutter/material.dart';
import 'package:flutter/src/scheduler/ticker.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:realtime_quizzes/customization/theme.dart';
import 'package:realtime_quizzes/screens/vs_random_quiz/vs_random_quiz_controller.dart';

import '../../shared/components.dart';

class VersusRandomQuizScreen extends StatelessWidget {
  VersusRandomQuizScreen({Key? key}) : super(key: key);

  final VersusRandomQuizController versusRandomQuizController =
      Get.put(VersusRandomQuizController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: Obx(() {
        return versusRandomQuizController.questions.value.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Question(versusRandomQuizController, context);
      }),
    ));
  }

  Question(
    VersusRandomQuizController versusRandomQuizController,
    BuildContext context,
  ) {
    var currentQuestion = versusRandomQuizController.questions.value
        .elementAt(versusRandomQuizController.currentQuestionIndex.value);
    var shuffledAnswers = currentQuestion.shuffledAnswers;

    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Your score: ' +
              versusRandomQuizController.currentScore.value.toString()),
          const SizedBox(
            height: MyTheme.largePadding,
          ),
          //add one to index because index starts with 0
          Text(
              'Question: ${(versusRandomQuizController.currentQuestionIndex.value + 1)}/${(versusRandomQuizController.questions.value.length)}'),
          const SizedBox(
            height: MyTheme.largePadding,
          ),
          Obx(() {
            return Text('Timer: ' +
                versusRandomQuizController.timerCounter.value.toString());
          }),

          const SizedBox(
            height: MyTheme.largePadding,
          ),
          Text(currentQuestion.question),
          const SizedBox(
            height: MyTheme.largePadding,
          ),
          ...mapIndexed(
              (shuffledAnswers),
              (index, String answer) => Answer(
                    versusRandomQuizController,
                    answer,
                    currentQuestion.correctAnswer,
                  )),
          MaterialButton(
              color: Colors.grey,
              onPressed: () {
                versusRandomQuizController.endQuiz();
              },
              child: Text('END QUIZ')),
          Text('temporary text right answer: ' + currentQuestion.correctAnswer)
        ],
      ),
    );
  }

  //todo color right answer, add timer for questions
  Answer(
    VersusRandomQuizController versusRandomQuizController,
    String answer,
    String correctAnswer,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          style: ButtonStyle(
              backgroundColor: answer == correctAnswer &&
                      versusRandomQuizController.isQuestionAnswered.value
                  ? MaterialStateProperty.all(Colors.green[200])
                  : answer != correctAnswer &&
                          versusRandomQuizController.isQuestionAnswered.value &&
                          versusRandomQuizController.selectedAnswer.value ==
                              answer
                      ? MaterialStateProperty.all(Colors.red[200])
                      : null),
          child: Text(answer),
          onPressed: () {
            //if question is already answered do nothing
            if (!versusRandomQuizController.isQuestionAnswered.value) {
              versusRandomQuizController.checkAnswer(
                answer: answer,
              );
            }
          },
        ),
        const SizedBox(
          height: MyTheme.mediumPadding,
        ),
      ],
    );
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    // TODO: implement createTicker
    throw UnimplementedError();
  }
}
