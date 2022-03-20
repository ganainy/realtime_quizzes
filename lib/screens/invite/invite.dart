import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:realtime_quizzes/customization/theme.dart';

import 'invite_controller.dart';

class InviteScreen extends StatelessWidget {
  InviteScreen({Key? key}) : super(key: key);

  final InviteController inviteController = Get.put(InviteController())
    ..sendPlayInvite(Get.arguments);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            inviteController.cancelTimer();
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
                  'Invite sent, game will start when the other player accept',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                const SizedBox(
                  height: 10,
                ),
                Obx(() {
                  return Text(
                    'Game will end if other player doesnt accept in ${inviteController.timerCounter.value} seconds',
                    style: Theme.of(context).textTheme.subtitle1,
                  );
                }),
                Padding(
                  padding: const EdgeInsets.all(MyTheme.smallPadding),
                  child: Card(
                    color: Colors.grey[200],
                    child: Padding(
                      padding: const EdgeInsets.all(MyTheme.mediumPadding),
                      child: Wrap(
                        spacing:
                            20, // to apply margin in the main axis of the wrap
                        runSpacing:
                            20, // to apply margin in the cross axis of the wrap
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          Obx(() {
                            return Text(
                                'category: ${inviteController.selectedQuizObs.value?.quizSpecs?.selectedCategory?.categoryName}');
                          }),
                          Obx(() {
                            return Text(
                                'num questions: ${inviteController.selectedQuizObs.value?.quizSpecs?.numberOfQuestions}');
                          }),
                          Obx(() {
                            return Text(
                                'difficulty: ${inviteController.selectedQuizObs.value?.quizSpecs?.selectedDifficulty?.difficultyType}');
                          })
                        ],
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    //todo delete invite and back to active quizzes screen
                    //Get.to(() => CreateQuizScreen());
                  },
                  child: Text('find another game'.tr),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
