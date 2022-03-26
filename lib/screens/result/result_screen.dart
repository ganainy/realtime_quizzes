import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:realtime_quizzes/layouts/home/home.dart';
import 'package:realtime_quizzes/models/queue_entry.dart';
import 'package:realtime_quizzes/screens/result/result_controller.dart';
import 'package:realtime_quizzes/shared/components.dart';

class ResultScreen extends StatelessWidget {
  ResultScreen({Key? key}) : super(key: key);

  QueueEntryModel queueEntryModel = Get.arguments;
  ResultController resultController = Get.put(ResultController(Get.arguments))
    ..updateUsers();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                          '${queueEntryModel.players.elementAt(0)?.playerEmail}'),
                      Text('${queueEntryModel.players.elementAt(0)?.score}'),
                      (queueEntryModel.players.elementAt(0)!.score >
                              queueEntryModel.players.elementAt(1)!.score)
                          ? const Text('Winner')
                          : SizedBox(),
                    ],
                  ),
                  (queueEntryModel.players.elementAt(0)!.score ==
                          queueEntryModel.players.elementAt(1)!.score)
                      ? const Text('Draw')
                      : SizedBox(),
                  Column(
                    children: [
                      Text(
                          '${queueEntryModel.players.elementAt(1)?.playerEmail}'),
                      Text('${queueEntryModel.players.elementAt(1)?.score}'),
                      (queueEntryModel.players.elementAt(1)!.score >
                              queueEntryModel.players.elementAt(0)!.score)
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
        ),
      ),
    );
  }
}
