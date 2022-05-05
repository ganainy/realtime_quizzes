import 'package:flutter/material.dart';
import 'package:flutter/src/scheduler/ticker.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:realtime_quizzes/customization/theme.dart';
import 'package:realtime_quizzes/screens/multiplayer_quiz/multiplayer_quiz_controller.dart';
import 'package:realtime_quizzes/shared/components.dart';

class MultiPlayerQuizScreen extends StatelessWidget {
  MultiPlayerQuizScreen({Key? key}) : super(key: key);

  final MultiPlayerQuizController multiPlayerQuizController =
      Get.put(MultiPlayerQuizController());

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    DefaultCircularNetworkImage(
                        imageUrl: multiPlayerQuizController
                            .loggedPlayer.value?.user?.imageUrl),
                    Text(
                        '${multiPlayerQuizController.loggedPlayer.value?.user?.name} '),
                    Text(
                        '${multiPlayerQuizController.loggedPlayer.value?.score} '),
                  ],
                ),
                Column(
                  children: [
                    Icon(
                      Icons.access_alarm,
                      size: 40,
                      color: primaryTextColor,
                    ),
                    Text(
                      multiPlayerQuizController.timerValueObs.value.toString(),
                      style: Theme.of(context).textTheme.subtitle1?.copyWith(
                          color:
                              multiPlayerQuizController.timerValueObs.value <= 3
                                  ? Colors.red
                                  : primaryTextColor),
                    ),
                  ],
                ),
                Column(
                  children: [
                    DefaultCircularNetworkImage(
                        imageUrl: multiPlayerQuizController
                            .otherPlayer.value?.user?.imageUrl),
                    Text(
                        '${multiPlayerQuizController.otherPlayer.value?.user?.name} '),
                    Text(
                        '${multiPlayerQuizController.otherPlayer.value?.score} '),
                  ],
                ),
              ],
            ),
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(smallPadding),
                  child: Card(
                    color: Colors.yellow[200],
                    child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.all(largePadding),
                        child: Text(
                          '${currentQuestion?.question}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.subtitle1,
                        )),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Card(
                    child: Container(
                      margin: EdgeInsets.all(4),
                      child: Text(
                          'Question: ${(multiPlayerQuizController.currentQuestionIndexObs.value + 1)}/${(multiPlayerQuizController.questionsObs.value.length)}'),
                    ),
                  ),
                ),
              ],
            ),
            ...?currentQuestion?.allAnswers.map((answer) {
              return Answer(answer, multiPlayerQuizController, context);
            }),
            /*   Text(
                'temporary text right answer: ${currentQuestion?.correctAnswer}'),
       */
          ],
        ),
      ),
    );
  }

  Answer(
    String text /*answer*/,
    MultiPlayerQuizController multiPlayerQuizController,
    BuildContext context,
  ) {
    return MultiPlayerAnswerButton(
        text: text,
        context: context,
        loggedPlayerImageUrl:
            multiPlayerQuizController.loggedPlayer.value?.user?.imageUrl,
        otherPlayerImageUrl:
            multiPlayerQuizController.otherPlayer.value?.user?.imageUrl,
        onPressed: () {
          //if question is already answered do nothing
          if (!multiPlayerQuizController.isQuestionAnswered) {
            multiPlayerQuizController.registerAnswer(
              text,
            );
          }
        },
        multiPlayerQuizController: multiPlayerQuizController);

    /*
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          children: [

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
               ,
                child: Text(text),
                onPressed: () {

                },
              );
            }),
          ],
        ),
        const SizedBox(
          height: mediumPadding,
        ),
      ],
    );*/
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    throw UnimplementedError();
  }
}
