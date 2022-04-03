import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/scheduler/ticker.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:realtime_quizzes/customization/theme.dart';
import 'package:realtime_quizzes/screens/multiplayer_quiz/multiplayer_quiz_controller.dart';

import '../../shared/constants.dart';

class MultiPlayerQuizScreen extends StatelessWidget {
  MultiPlayerQuizScreen({Key? key}) : super(key: key);

  final MultiPlayerQuizController multiPlayerQuizController =
      Get.put(MultiPlayerQuizController(Get.arguments));

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: Obx(() {
        return multiPlayerQuizController.questionsObs.value.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Question(multiPlayerQuizController, context);
      }),
    ));
  }

  Question(
    MultiPlayerQuizController multiPlayerQuizController,
    BuildContext context,
  ) {
    var currentQuestion = multiPlayerQuizController.currentQuestionObs.value;

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                '${multiPlayerQuizController.loggedPlayer.value?.player?.name} score: ${multiPlayerQuizController.loggedPlayer.value?.score}'),
            const SizedBox(
              height: largePadding,
            ),
            Text(
                '${multiPlayerQuizController.otherPlayer.value?.player?.name} score: ${multiPlayerQuizController.otherPlayer.value?.score}'),
            const SizedBox(
              height: largePadding,
            ),
            //add one to index because index starts with 0
            Text(
                'Question: ${(multiPlayerQuizController.currentQuestionIndexObs.value + 1)}/${(multiPlayerQuizController.questionsObs.value.length)}'),
            const SizedBox(
              height: largePadding,
            ),
            multiPlayerQuizController.timerValueObs.value > 0
                ? Obx(() {
                    return Text('Timer: ' +
                        multiPlayerQuizController.timerValueObs.value
                            .toString());
                  })
                : const SizedBox(),
            multiPlayerQuizController.nextQuestionTimerValueObs.value > 0
                ? Obx(() {
                    return Text('Next question in: ' +
                        multiPlayerQuizController
                            .nextQuestionTimerValueObs.value
                            .toString());
                  })
                : const SizedBox(),

            const SizedBox(
              height: largePadding,
            ),
            Text('${currentQuestion?.question}'),
            const SizedBox(
              height: largePadding,
            ),
            ...?currentQuestion?.allAnswers.map((answer) {
              return Answer(
                answer,
                multiPlayerQuizController,
              );
            }),
            Text(
                'temporary text right answer: ${currentQuestion?.correctAnswer}'),
          ],
        ),
      ),
    );
  }

  Answer(
    String text /*answer*/,
    MultiPlayerQuizController multiPlayerQuizController,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          children: [
            multiPlayerQuizController.getIsSelectedLoggedPlayer(text)
                ? CachedNetworkImage(
                    width: 20,
                    height: 20,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    imageUrl: multiPlayerQuizController
                            .loggedPlayer.value?.player?.imageUrl ??
                        Constants.YOU_IMAGE,
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.account_circle),
                  )
                : SizedBox(),
            multiPlayerQuizController.getIsSelectedOtherPlayer(text)
                ? CachedNetworkImage(
                    width: 20,
                    height: 20,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    imageUrl: multiPlayerQuizController
                            .otherPlayer.value?.player?.imageUrl ??
                        '',
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.account_circle),
                  )
                : SizedBox(),
            Obx(() {
              return TextButton(
                style: ButtonStyle(
                    backgroundColor: multiPlayerQuizController
                            .getIsCorrectAnswer(text)
                        ? MaterialStateProperty.all(Colors.green[200])
                        : multiPlayerQuizController
                                .getIsSelectedWrongAnswer(text)
                            ? MaterialStateProperty.all(Colors.red[200])
                            : multiPlayerQuizController
                                    .getIsSelectedLocalAnswer(text)
                                ? MaterialStateProperty.all(Colors.orange[200])
                                : null),
                child: Text(text),
                onPressed: () {
                  //if question is already answered do nothing
                  if (!multiPlayerQuizController.isQuestionAnswered) {
                    multiPlayerQuizController.registerAnswer(
                      text,
                    );
                  }
                },
              );
            }),
          ],
        ),
        const SizedBox(
          height: mediumPadding,
        ),
      ],
    );
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    throw UnimplementedError();
  }
}
