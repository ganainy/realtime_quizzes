import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:realtime_quizzes/customization/theme.dart';

import '../invite/invite.dart';
import 'history_controller.dart';

class HistoryScreen extends StatelessWidget {
  HistoryScreen({Key? key}) : super(key: key);

  final HistoryController historyController = Get.put(HistoryController())
    ..loadMatchHistory();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Obx(() {
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Your games history',
                style: Theme.of(context).textTheme.headline3,
              ),
              historyController.resultsObs.value == null
                  ? const Center(child: CircularProgressIndicator())
                  : historyController.resultsObs.value!.isNotEmpty
                      ? Obx(() {
                          return Padding(
                            padding: const EdgeInsets.all(MyTheme.smallPadding),
                            child: ListView.builder(
                                itemCount:
                                    historyController.resultsObs.value!.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      Get.to(() => InviteScreen(),
                                          arguments: historyController
                                              .resultsObs.value!
                                              .elementAt(index));
                                    },
                                    child: Card(
                                      color: Colors.grey[200],
                                      child: Padding(
                                        padding: const EdgeInsets.all(
                                            MyTheme.mediumPadding),
                                        child: Wrap(
                                          spacing:
                                              20, // to apply margin in the main axis of the wrap
                                          runSpacing:
                                              20, // to apply margin in the cross axis of the wrap
                                          alignment: WrapAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                'status: ${historyController.resultsObs.value!.elementAt(index).type}'),
                                            Text(
                                                'category: ${historyController.resultsObs.value!.elementAt(index).category}'),
                                            Text(
                                                'difficulty: ${historyController.resultsObs.value!.elementAt(index).difficulty}'),
                                            Text(
                                                'score: ${historyController.resultsObs.value!.elementAt(index).score}/'
                                                '${historyController.resultsObs.value!.elementAt(index).maxScore}'),
                                            Text(
                                                'opponent: ${historyController.resultsObs.value!.elementAt(index).otherPlayerEmail}'),
                                            Text(
                                                'date: ${DateTime.fromMillisecondsSinceEpoch(historyController.resultsObs.value!.elementAt(index).createdAt)}'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          );
                        })
                      : Obx(() {
                          return Text(
                              ' ${historyController.resultsObs.value!.length} still no games played');
                        }),
            ],
          ),
        );
      })),
    );
  }
}
