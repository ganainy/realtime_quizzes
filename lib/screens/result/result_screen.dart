import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:realtime_quizzes/layouts/home/home.dart';
import 'package:realtime_quizzes/main_controller.dart';
import 'package:realtime_quizzes/models/quiz_settings.dart';
import 'package:realtime_quizzes/screens/result/result_controller.dart';
import 'package:realtime_quizzes/shared/components.dart';

import '../../customization/theme.dart';
import '../../models/game_type.dart';
import '../../shared/constants.dart';

class ResultScreen extends StatelessWidget {
  ResultScreen({Key? key}) : super(key: key);

  ResultController resultController = Get.put(ResultController(Get.arguments));
  MainController mainController = Get.find<MainController>();

  ///game arguments are different based on if single player or multiplayer game
  ///single
  /*{
      'result':
          SinglePlayerQuizResult(currentScore.value, questions.value.length),
      'gameType':GameType.SINGLE
    }*/

  ///multi
  /*  {
      'queueEntry': queueEntryModelObs.value,
      'gameType':GameType.MULTI,
    }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Get.arguments['gameType'] == GameType.MULTI
            ? MultiPlayerResult(context)
            : SinglePlayerResult(Get.arguments['result'], context),
      )),
    );
  }

  SingleChildScrollView MultiPlayerResult(BuildContext context) {
    var queueEntryModel = resultController.queueEntryModelObs.value;

    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(smallPadding),
                child: Card(
                  color: lightCardColor,
                  child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(largePadding),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Column(
                                children: [
                                  Text(
                                      '${queueEntryModel?.players!.elementAt(0)?.user?.name}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1),
                                  DefaultResultImage(
                                    imageUrl: queueEntryModel?.players!
                                            .elementAt(0)
                                            ?.user
                                            ?.imageUrl ??
                                        Constants.YOU_IMAGE,
                                    isWinner: queueEntryModel!.players!
                                            .elementAt(0)!
                                            .score >
                                        queueEntryModel.players!
                                            .elementAt(1)!
                                            .score,
                                  ),
                                ],
                              ),
                              Card(
                                color: cardColor,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: largePadding,
                                      vertical: smallPadding),
                                  child: Text(
                                      '${queueEntryModel.players!.elementAt(0)?.score}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1),
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            ':',
                            style: TextStyle(color: cardColor, fontSize: 30),
                          ),
                          Column(
                            children: [
                              Text(
                                '${queueEntryModel.players!.elementAt(1)?.user?.name}',
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                              DefaultResultImage(
                                imageUrl: queueEntryModel.players!
                                        .elementAt(1)
                                        ?.user
                                        ?.imageUrl ??
                                    '',
                                isWinner: queueEntryModel.players!
                                        .elementAt(1)!
                                        .score >
                                    queueEntryModel.players!
                                        .elementAt(0)!
                                        .score,
                              ),
                              Card(
                                color: cardColor,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: largePadding,
                                      vertical: smallPadding),
                                  child: Text(
                                      '${queueEntryModel.players!.elementAt(1)?.score}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Card(
                  color: cardColor,
                  child: Container(
                    padding: EdgeInsets.all(smallPadding),
                    child: Text('Final Result'),
                  ),
                ),
              ),
            ],
          ),
          DefaultButton(
              text: 'back home',
              onPressed: () {
                mainController.deleteGame();
                Get.offAll(() => HomeScreen());
              })
        ],
      ),
    );
  }

  SinglePlayerResult(QuizSettings result, BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(smallPadding),
                child: Card(
                  color: lightCardColor,
                  child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(largePadding),
                      child: Column(children: [
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Card(
                              color: cardColor,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: largePadding,
                                    vertical: smallPadding),
                                child: Text('${result.score}',
                                    style:
                                        Theme.of(context).textTheme.subtitle1),
                              ),
                            ),
                            const Text(
                              '/',
                              style: TextStyle(color: cardColor, fontSize: 30),
                            ),
                            Card(
                              color: cardColor,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: largePadding,
                                    vertical: smallPadding),
                                child: Text('${result.numberOfQuestions}',
                                    style:
                                        Theme.of(context).textTheme.subtitle1),
                              ),
                            ),
                          ],
                        ),
                      ])),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Card(
                  color: cardColor,
                  child: Container(
                    padding: EdgeInsets.all(smallPadding),
                    child: Text('Final Result'),
                  ),
                ),
              ),
            ],
          ),
          DefaultButton(
              text: 'back home',
              onPressed: () {
                mainController.deleteGame();
                Get.offAll(() => HomeScreen());
              })
        ],
      ),
    );
  }
}
