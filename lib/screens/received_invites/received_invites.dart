import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:realtime_quizzes/customization/theme.dart';

import 'received_invites_controller.dart';

class ReceivedInviteScreen extends StatelessWidget {
  ReceivedInviteScreen({Key? key}) : super(key: key);

  final ReceivedInviteController receivedInvitesController =
      Get.put(ReceivedInviteController())..setInitialInvites(Get.arguments);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            receivedInvitesController.cancelTimer();
            return true;
          },
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Received invite sent, tap on any to start game',
                  style: Theme.of(context).textTheme.headline5,
                ),
                const SizedBox(
                  height: 10,
                ),
                ListView.builder(
                    shrinkWrap: true,
                    itemCount:
                        receivedInvitesController.receivedInvites.value?.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          //start game
                          receivedInvitesController.acceptInvite(index);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(MyTheme.smallPadding),
                          child: Card(
                            color: Colors.grey[200],
                            child: Padding(
                              padding:
                                  const EdgeInsets.all(MyTheme.mediumPadding),
                              child: Wrap(
                                spacing:
                                    20, // to apply margin in the main axis of the wrap
                                runSpacing:
                                    20, // to apply margin in the cross axis of the wrap
                                alignment: WrapAlignment.spaceBetween,
                                children: [
                                  Obx(() {
                                    return Text(
                                        'category: ${receivedInvitesController.receivedInvites.value?.elementAt(index).quiz?.quizSpecs?.selectedCategory?.categoryName}');
                                  }),
                                  Obx(() {
                                    return Text(
                                        'num questions: ${receivedInvitesController.receivedInvites.value?.elementAt(index).quiz?.quizSpecs?.numberOfQuestions}');
                                  }),
                                  Obx(() {
                                    return Text(
                                        'difficulty: ${receivedInvitesController.receivedInvites.value?.elementAt(index).quiz?.quizSpecs?.selectedDifficulty?.difficultyType}');
                                  })
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
