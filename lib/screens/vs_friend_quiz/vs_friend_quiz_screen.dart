import 'package:flutter/material.dart';
import 'package:flutter/src/scheduler/ticker.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:realtime_quizzes/customization/theme.dart';
import 'package:realtime_quizzes/screens/vs_friend_quiz/vs_friend_quiz_controller.dart';

class VersusFriendQuizScreen extends StatelessWidget {
  VersusFriendQuizScreen({Key? key}) : super(key: key);

  final VersusFriendQuizController versusFriendQuizController =
      Get.put(VersusFriendQuizController())
        ..loadQuestions(Get.arguments.queueEntryId);

  @override
  Widget build(BuildContext context) {
    debugPrint('$VersusFriendQuizScreen ${Get.arguments.questions.length}');
    return SafeArea(child: Scaffold(
      body: Obx(() {
        return versusFriendQuizController.questionsObs.value.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Question(versusFriendQuizController, context);
      }),
    ));
  }

  Question(
    VersusFriendQuizController versusFriendQuizController,
    BuildContext context,
  ) {
    var currentQuestion = versusFriendQuizController.currentQuestionObs.value;

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                'Your score: ${versusFriendQuizController.loggedPlayer.value?.score}'),
            const SizedBox(
              height: MyTheme.largePadding,
            ),
            Text(
                'Other player score: ${versusFriendQuizController.otherPlayer.value?.score}'),
            const SizedBox(
              height: MyTheme.largePadding,
            ),
            //add one to index because index starts with 0
            Text(
                'Question: ${(versusFriendQuizController.currentQuestionIndexObs.value + 1)}/${(versusFriendQuizController.questionsObs.value.length)}'),
            const SizedBox(
              height: MyTheme.largePadding,
            ),
            versusFriendQuizController.timerValueObs.value > 0
                ? Obx(() {
                    return Text('Timer: ' +
                        versusFriendQuizController.timerValueObs.value
                            .toString());
                  })
                : const SizedBox(),
            versusFriendQuizController.nextQuestionTimerValueObs.value > 0
                ? Obx(() {
                    return Text('Next question in: ' +
                        versusFriendQuizController
                            .nextQuestionTimerValueObs.value
                            .toString());
                  })
                : const SizedBox(),

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
                versusFriendQuizController,
              );
            }),
            Text(
                'temporary text right answer: ${currentQuestion?.correctAnswer}'),
            Text(
                'your answer: ${versusFriendQuizController.loggedPlayer.value!.answers.length > versusFriendQuizController.currentQuestionIndexObs.value ? versusFriendQuizController.loggedPlayer.value?.answers.elementAt(versusFriendQuizController.currentQuestionIndexObs.value) : 'asbr'}'),
            Text(
                'other player answer: ${versusFriendQuizController.otherPlayer.value!.answers.length > versusFriendQuizController.currentQuestionIndexObs.value ? versusFriendQuizController.otherPlayer.value?.answers.elementAt(versusFriendQuizController.currentQuestionIndexObs.value) : 'asbr b2a'}'),
          ],
        ),
      ),
    );
  }

  Answer(
    String text /*answer*/,
    VersusFriendQuizController versusFriendQuizController,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          children: [
            versusFriendQuizController.getIsSelectedLoggedPlayer(text)
                ? Text(
                    '${versusFriendQuizController.loggedPlayer.value?.playerEmail}')
                : SizedBox(),
            versusFriendQuizController.getIsSelectedOtherPlayer(text)
                ? Text(
                    '${versusFriendQuizController.otherPlayer.value?.playerEmail}')
                : SizedBox(),
            TextButton(
              style: ButtonStyle(
                  backgroundColor: versusFriendQuizController
                          .getIsCorrectAnswer(text)
                      ? MaterialStateProperty.all(Colors.green[200])
                      : versusFriendQuizController
                              .getIsSelectedWrongAnswer(text)
                          ? MaterialStateProperty.all(Colors.red[200])
                          : versusFriendQuizController
                                  .getIsSelectedLocalAnswer(text)
                              ? MaterialStateProperty.all(Colors.orange[200])
                              : null),
              child: Text(text),
              onPressed: () {
                //if question is already answered do nothing
                if (!versusFriendQuizController.isQuestionAnsweredObs.value) {
                  versusFriendQuizController.registerAnswer(
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
