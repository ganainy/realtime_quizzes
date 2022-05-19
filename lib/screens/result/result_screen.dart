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
import '../../shared/shared.dart';

class ResultScreen extends StatelessWidget {
  ResultScreen({Key? key}) : super(key: key);

  ResultController resultController = Get.put(ResultController(Get.arguments));
  MainController mainController = Get.find<MainController>();

  ///Note: game arguments are different based on if single player or multiplayer game

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Get.arguments['gameType'] == GameType.MULTI
              ? MultiPlayerResult(context)
              : SinglePlayerResult(
                  gameSettings: Get.arguments['gameSettings'],
                  finalScore: Get.arguments['finalScore'],
                  context: context)),
    );
  }

  Widget MultiPlayerResult(BuildContext context) {
    var game = resultController.gameObs.value;

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    right: smallPadding,
                    left: smallPadding,
                    top: 2 * largePadding,
                    bottom: smallPadding),
                child: Card(
                  color: lightBg,
                  child: Container(
                      margin: EdgeInsets.all(largePadding),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                        '${game?.players!.elementAt(0)?.user?.name}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold)),
                                  ),
                                  DefaultResultImage(
                                    imageUrl: game?.players!
                                        .elementAt(0)
                                        ?.user
                                        ?.imageUrl,
                                    isWinner:
                                        game!.players!.elementAt(0)!.score >
                                            game.players!.elementAt(1)!.score,
                                  ),
                                ],
                              ),
                              Card(
                                color: darkBg,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: largePadding,
                                      vertical: smallPadding),
                                  child: Text(
                                      '${game.players!.elementAt(0)?.score}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1
                                          ?.copyWith(color: bgColor)),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            ':',
                            style: TextStyle(color: darkBg, fontSize: 30),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '${game.players!.elementAt(1)?.user?.name}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DefaultResultImage(
                                imageUrl:
                                    game.players!.elementAt(1)?.user?.imageUrl,
                                isWinner: game.players!.elementAt(1)!.score >
                                    game.players!.elementAt(0)!.score,
                              ),
                              Card(
                                color: darkBg,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: largePadding,
                                      vertical: smallPadding),
                                  child: Text(
                                      '${game.players!.elementAt(1)?.score}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1
                                          ?.copyWith(color: bgColor)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: largePadding),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Card(
                    color: darkBg,
                    child: Container(
                      padding: EdgeInsets.all(smallPadding),
                      child: Text(
                        'Final Result',
                        style: Theme.of(context)
                            .textTheme
                            .headline1
                            ?.copyWith(color: bgColor),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        DefaultButton(
            text: 'Return home',
            onPressed: () {
              mainController.deleteGame(game.gameId);
              Get.offAll(() => HomeScreen());
            })
      ],
    );
  }

  SinglePlayerResult(
      {required GameSettings gameSettings,
      required int finalScore,
      required BuildContext context}) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    right: smallPadding,
                    left: smallPadding,
                    top: 2 * largePadding,
                    bottom: smallPadding),
                child: Card(
                  color: lightBg,
                  child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(largePadding),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Card(
                                  color: darkBg,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: largePadding,
                                        vertical: smallPadding),
                                    child: Text('${finalScore}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline1
                                            ?.copyWith(color: bgColor)),
                                  ),
                                ),
                                Text(
                                  '/',
                                  style: TextStyle(color: darkBg, fontSize: 30),
                                ),
                                Card(
                                  color: darkBg,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: largePadding,
                                        vertical: smallPadding),
                                    child: Text(
                                        '${gameSettings.numberOfQuestions!.toInt() + 1}', //todo fix +1 bug
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline1
                                            ?.copyWith(color: bgColor)),
                                  ),
                                ),
                              ],
                            ),
                          ])),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: largePadding),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Card(
                    color: darkBg,
                    child: Container(
                      padding: EdgeInsets.all(smallPadding),
                      child: Text(
                        'Final Result',
                        style: Theme.of(context)
                            .textTheme
                            .headline1
                            ?.copyWith(color: bgColor),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        DefaultButton(
            text: 'Return home',
            onPressed: () {
              mainController.deleteGame(Shared.game.gameId);
              Get.offAll(() => HomeScreen());
            })
      ],
    );
  }
}
