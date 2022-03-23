import 'package:flutter/material.dart';
import 'package:flutter/src/scheduler/ticker.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:realtime_quizzes/customization/theme.dart';
import 'package:realtime_quizzes/models/queue_entry.dart';
import 'package:realtime_quizzes/screens/vs_random_quiz/vs_random_quiz_controller.dart';

import '../../shared/components.dart';

class VersusRandomQuizScreen extends StatelessWidget {
  VersusRandomQuizScreen({Key? key}) : super(key: key);

  final VersusRandomQuizController versusRandomQuizController =
      Get.put(VersusRandomQuizController())
        ..updateValues(Get.arguments)
        ..setPlayerReady(Get.arguments);

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: Obx(() {
        return versusRandomQuizController.questionsObs.value.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Question(versusRandomQuizController, context);
      }),
    ));
  }

  Question(
    VersusRandomQuizController versusRandomQuizController,
    BuildContext context,
  ) {
    var currentQuestion = versusRandomQuizController.currentQuestionObs.value;

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                'Your score: ${versusRandomQuizController.loggedPlayer.value?.score}'),
            const SizedBox(
              height: MyTheme.largePadding,
            ),
            Text(
                'Other player score: ${versusRandomQuizController.otherPlayer.value?.score}'),
            const SizedBox(
              height: MyTheme.largePadding,
            ),
            //add one to index because index starts with 0
            Text(
                'Question: ${(versusRandomQuizController.currentQuestionIndexObs.value + 1)}/${(versusRandomQuizController.questionsObs.value.length)}'),
            const SizedBox(
              height: MyTheme.largePadding,
            ),
            Obx(() {
              return Text('Timer: ' +
                  versusRandomQuizController.timerValueObs.value.toString());
            }),
            Obx(() {
              return Text('Next question in: ' +
                  versusRandomQuizController.nextQuestionTimerValueObs.value.toString());
            }),

            const SizedBox(
              height: MyTheme.largePadding,
            ),
            Text('${currentQuestion?.question}'),
            const SizedBox(
              height: MyTheme.largePadding,
            ),
            ...?currentQuestion?.allAnswers.map((answer) {
              return Answer(
                answer,
                versusRandomQuizController,
              );
            }),
            Text(
                'temporary text right answer: ${currentQuestion?.correctAnswer}'),
            Text(
                'your answer: ${versusRandomQuizController.loggedPlayer.value!.answers.length>versusRandomQuizController.currentQuestionIndexObs.value ? versusRandomQuizController.loggedPlayer.value?.answers.elementAt(versusRandomQuizController.currentQuestionIndexObs.value) : 'asbr'}'),
            Text(
                'other player answer: ${versusRandomQuizController.otherPlayer.value!.answers.length>versusRandomQuizController.currentQuestionIndexObs.value ? versusRandomQuizController.otherPlayer.value?.answers.elementAt(versusRandomQuizController.currentQuestionIndexObs.value) : 'asbr b2a'}'),
          ],
        ),
      ),
    );
  }

  Answer(
    String text /*answer*/,
    VersusRandomQuizController versusRandomQuizController,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          children: [
            versusRandomQuizController.getIsSelectedLoggedPlayer(text)
                ? Text(
                    '${versusRandomQuizController.loggedPlayer.value?.playerEmail}')
                : SizedBox(),

            versusRandomQuizController.getIsSelectedOtherPlayer(text)
                ? Text(
                '${versusRandomQuizController.otherPlayer.value?.playerEmail}')
                : SizedBox(),

            TextButton(
              style: ButtonStyle(
                  backgroundColor:
                      versusRandomQuizController.getIsCorrectAnswer(text)
                          ? MaterialStateProperty.all(Colors.green[200])
                          : versusRandomQuizController
                                  .getIsSelectedWrongAnswer(text)
                              ? MaterialStateProperty.all(Colors.red[200])
                              : versusRandomQuizController.getIsSelectedLocalAnswer(text) ?
                      MaterialStateProperty.all(Colors.orange[200])
                          :
                      null),
              child: Text(text),
              onPressed: () {
                //if question is already answered do nothing
                if (!versusRandomQuizController.isQuestionAnsweredObs.value) {
                  versusRandomQuizController.registerAnswer(
                    text,
                  );
                }
              },
            ),
          ],
        ),
        const SizedBox(
          height: MyTheme.mediumPadding,
        ),
      ],
    );
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    throw UnimplementedError();
  }
}
