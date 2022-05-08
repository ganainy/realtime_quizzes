import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/scheduler/ticker.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:realtime_quizzes/customization/theme.dart';
import 'package:realtime_quizzes/main_controller.dart';
import 'package:realtime_quizzes/screens/multiplayer_quiz/multiplayer_quiz_controller.dart';
import 'package:realtime_quizzes/shared/components.dart';

import '../../layouts/home/home.dart';

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
          return multiPlayerQuizController.queueEntryModelObs.value == null
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
    var currentQuestion = multiPlayerQuizController
        .queueEntryModelObs.value!.questions!
        .elementAt(multiPlayerQuizController.currentQuestionIndexObs.value);

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            multiPlayerQuizController
                    .queueEntryModelObs.value!.hasOpponentLeftGame
                ? Card(
                    margin: const EdgeInsets.all(smallPadding),
                    color: Colors.yellow[200],
                    child: Container(
                        padding: const EdgeInsets.all(smallPadding),
                        child: RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              const TextSpan(
                                text:
                                    'Your opponent has left the game,feel free to continue or ',
                                style: TextStyle(
                                    color: primaryTextColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal),
                              ),
                              TextSpan(
                                  text: 'end game',
                                  style: const TextStyle(
                                      color: Colors.blue, fontSize: 18),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      mainController.deleteGame();
                                      Get.offAll(() => HomeScreen());
                                    }),
                            ],
                          ),
                        )),
                  )
                : const SizedBox(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
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
                          '/${(multiPlayerQuizController.queueEntryModelObs.value?.questions?.length)}'),
                    ),
                  ),
                ),
              ],
            ),
            ...?currentQuestion?.allAnswers.map((answer) {
              return Answer(answer, multiPlayerQuizController, context);
            }),
            //todo remove
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
