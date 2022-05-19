import 'package:flutter/material.dart';
import 'package:flutter/src/scheduler/ticker.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:realtime_quizzes/customization/theme.dart';
import 'package:realtime_quizzes/main_controller.dart';
import 'package:realtime_quizzes/screens/multiplayer_quiz/multiplayer_quiz_controller.dart';
import 'package:realtime_quizzes/shared/components.dart';

class MultiPlayerQuizScreen extends StatelessWidget {
  MultiPlayerQuizScreen({Key? key}) : super(key: key);

  final MultiPlayerQuizController multiPlayerQuizController =
      Get.put(MultiPlayerQuizController());

  final MainController mainController = Get.find<MainController>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        mainController.confirmExitDialog(isOnlineGame: true);
        return Future.value(false);
      },
      child: SafeArea(child: Scaffold(
        body: Obx(() {
          return multiPlayerQuizController.gameObs.value == null
              ? const Center(child: CircularProgressIndicator())
              : Question(multiPlayerQuizController, context);
        }),
      )),
    );
  }

  Question(
    MultiPlayerQuizController multiPlayerQuizController,
    BuildContext context,
  ) {
    var currentQuestion = multiPlayerQuizController.gameObs.value!.questions!
        .elementAt(multiPlayerQuizController.currentQuestionIndexObs.value);

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
                    const SizedBox(height: mediumPadding),
                    DefaultCircularNetworkImage(
                        imageUrl: multiPlayerQuizController
                            .loggedPlayer?.user?.imageUrl),
                    Text(
                        '${multiPlayerQuizController.loggedPlayer?.user?.name} '),
                    Text('${multiPlayerQuizController.loggedPlayer?.score} '),
                  ],
                ),
                Column(
                  children: [
                    Icon(
                      Icons.access_alarm,
                      size: 40,
                      color: darkText,
                    ),
                    Text(
                      multiPlayerQuizController.timerValueObs.value.toString(),
                      style: Theme.of(context).textTheme.subtitle1?.copyWith(
                          color:
                              multiPlayerQuizController.timerValueObs.value <= 3
                                  ? Colors.red
                                  : darkText),
                    ),
                  ],
                ),
                Column(
                  children: [
                    DefaultCircularNetworkImage(
                        imageUrl:
                            multiPlayerQuizController.opponent?.user?.imageUrl),
                    Text('${multiPlayerQuizController.opponent?.user?.name} '),
                    Text('${multiPlayerQuizController.opponent?.score} '),
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
                          'Question: ${(multiPlayerQuizController.currentQuestionIndexObs.value + 1)}'
                          '/${(multiPlayerQuizController.gameObs.value?.questions?.length)}'),
                    ),
                  ),
                ),
              ],
            ),
            ...?currentQuestion?.allAnswers.map((answer) {
              return Answer(answer, multiPlayerQuizController, context);
            }),
            /* Text(
                'temporary text right answer: ${currentQuestion?.correctAnswer}'),*/
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
            multiPlayerQuizController.loggedPlayer?.user?.imageUrl,
        otherPlayerImageUrl: multiPlayerQuizController.opponent?.user?.imageUrl,
        onPressed: () {
          //if question is already answered do nothing
          if (multiPlayerQuizController.isQuestionNotAnswered()) {
            multiPlayerQuizController.registerAnswer(
              text,
            );
          }
        },
        multiPlayerQuizController: multiPlayerQuizController);
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    throw UnimplementedError();
  }
}
