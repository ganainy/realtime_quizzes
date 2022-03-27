import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:realtime_quizzes/layouts/home/home.dart';
import 'package:realtime_quizzes/models/single_player_quiz_result.dart';
import 'package:realtime_quizzes/screens/result/result_controller.dart';
import 'package:realtime_quizzes/shared/components.dart';

import '../../models/game_type.dart';
import '../../shared/constants.dart';

class ResultScreen extends StatelessWidget {
  ResultScreen({Key? key}) : super(key: key);

  ResultController resultController = Get.put(ResultController(Get.arguments));

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
        child: Get.arguments['gameType'] == GameType.MULTI
            ? MultiPlayerResult()
            : SinglePlayerResult(Get.arguments['result']),
      ),
    );
  }

  Center MultiPlayerResult() {
    var queueEntryModel = resultController.queueEntryModelObs.value;

    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  CachedNetworkImage(
                    width: 100,
                    height: 100,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    imageUrl: queueEntryModel?.players!
                            .elementAt(0)
                            ?.player
                            ?.imageUrl ??
                        Constants.YOU_IMAGE,
                    errorWidget: (context, url, error) =>
                        Icon(Icons.error, size: 100),
                  ),
                  Text(
                      '${queueEntryModel?.players!.elementAt(0)?.player?.name}'),
                  Text('${queueEntryModel?.players!.elementAt(0)?.score}'),
                  (queueEntryModel!.players!.elementAt(0)!.score >
                          queueEntryModel.players!.elementAt(1)!.score)
                      ? const Text('Winner')
                      : SizedBox(),
                ],
              ),
              (queueEntryModel.players!.elementAt(0)!.score ==
                      queueEntryModel.players!.elementAt(1)!.score)
                  ? const Text('Draw')
                  : SizedBox(),
              Column(
                children: [
                  CachedNetworkImage(
                    width: 100,
                    height: 100,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    imageUrl: queueEntryModel.players!
                            .elementAt(1)
                            ?.player
                            ?.imageUrl ??
                        '',
                    errorWidget: (context, url, error) => Icon(
                      Icons.error,
                      size: 100,
                    ),
                  ),
                  Text(
                      '${queueEntryModel.players!.elementAt(1)?.player?.name}'),
                  Text('${queueEntryModel.players!.elementAt(1)?.score}'),
                  (queueEntryModel.players!.elementAt(1)!.score >
                          queueEntryModel.players!.elementAt(0)!.score)
                      ? const Text('Winner')
                      : SizedBox(),
                ],
              )
            ],
          ),
          DefaultButton(
              text: 'back home',
              onPressed: () {
                resultController.deleteGame();
                Get.offAll(() => HomeScreen());
              })
        ],
      ),
    );
  }

  SinglePlayerResult(SinglePlayerQuizResult result) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('score:' +
              result.score.toString() +
              '/' +
              result.numQuestions.toString()),
          Text('difficulty: ${result.difficulty}'),
          Text('category: ${result.category ?? 'Random'}'),
          Text(
              'created at: ${DateTime.fromMillisecondsSinceEpoch(result.createdAt!)}'),
          DefaultButton(
              text: 'back home',
              onPressed: () {
                Get.offAll(() => HomeScreen());
              }),
        ],
      ),
    );
  }
}