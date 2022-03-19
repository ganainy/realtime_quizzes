import 'package:flutter/material.dart';
import 'package:flutter/src/scheduler/ticker.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:realtime_quizzes/customization/theme.dart';
import 'package:realtime_quizzes/screens/single_player_quiz/single_player_quiz_controller.dart';

import '../../shared/components.dart';

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
            : Question(singlePlayerQuizController, context);
      }),
    ));
  }

  Question(
    SinglePlayerQuizController singlePlayerQuizController,
    BuildContext context,
  ) {
    var currentQuestion = singlePlayerQuizController.questions.value
        .elementAt(singlePlayerQuizController.currentQuestionIndex.value);
    var shuffledAnswers = currentQuestion.shuffledAnswers;

    return WillPopScope(
      onWillPop: () async {
        singlePlayerQuizController.cancelTimer();
        return true;
      },
      child: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Your score: ' +
                singlePlayerQuizController.currentScore.value.toString()),
            const SizedBox(
              height: MyTheme.largePadding,
            ),
            //add one to index because index starts with 0
            Text(
                'Question: ${(singlePlayerQuizController.currentQuestionIndex.value + 1)}/${(singlePlayerQuizController.questions.value.length)}'),
            const SizedBox(
              height: MyTheme.largePadding,
            ),
            Obx(() {
              return Text('Timer: ' +
                  singlePlayerQuizController.timerCounter.value.toString());
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
                      singlePlayerQuizController,
                      answer,
                      currentQuestion.correctAnswer,
                    )),
            MaterialButton(
                color: Colors.grey,
                onPressed: () {
                  singlePlayerQuizController.endQuiz();
                },
                child: Text('END QUIZ')),
            Text(
                'temporary text right answer: ' + currentQuestion.correctAnswer)
          ],
        ),
      ),
    );
  }

  //todo color right answer, add timer for questions
  Answer(
    SinglePlayerQuizController singlePlayerQuizController,
    String answer,
    String correctAnswer,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          style: ButtonStyle(
              backgroundColor: answer == correctAnswer &&
                      singlePlayerQuizController.isQuestionAnswered.value
                  ? MaterialStateProperty.all(Colors.green[200])
                  : answer != correctAnswer &&
                          singlePlayerQuizController.isQuestionAnswered.value &&
                          singlePlayerQuizController.selectedAnswer.value ==
                              answer
                      ? MaterialStateProperty.all(Colors.red[200])
                      : null),
          child: Text(answer),
          onPressed: () {
            //if question is already answered do nothing
            if (!singlePlayerQuizController.isQuestionAnswered.value) {
              singlePlayerQuizController.checkAnswer(
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
