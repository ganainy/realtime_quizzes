import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:realtime_quizzes/customization/theme.dart';

import '../create_quiz/create_quiz.dart';
import '../invite/invite.dart';
import 'available_quizzes_controller.dart';

class AvailableQuizzesScreen extends StatelessWidget {
  AvailableQuizzesScreen({Key? key}) : super(key: key);

  final AvailableQuizzesController availableQuizzesController =
      Get.put(AvailableQuizzesController())/*..findActiveQuizzes()*/;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Obx(() {
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Available quizzes',
                style: Theme.of(context).textTheme.headline3,
              ),
              availableQuizzesController.quizzes.value.isNotEmpty
                  ? Obx(() {
                      return Padding(
                        padding: const EdgeInsets.all(MyTheme.smallPadding),
                        child: ListView.builder(
                            itemCount:
                                availableQuizzesController.quizzes.value.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  Get.to(() => InviteScreen(),
                                      arguments: availableQuizzesController
                                          .quizzes.value
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
                                            'category: ${availableQuizzesController.quizzes.value.elementAt(index).quizSpecs?.category?.category}'),
                                        Text(
                                            'num questions: ${availableQuizzesController.quizzes.value.elementAt(index).quizSpecs?.numberOfQuestions}'),
                                        Text(
                                            'difficulty: ${availableQuizzesController.quizzes.value.elementAt(index).quizSpecs?.difficulty?.difficultyType}')
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
                          ' ${availableQuizzesController.quizzes.value.length} quizzes available');
                    }),
              TextButton(
                onPressed: () {
                  Get.to(() => CreateQuizScreen());
                },
                child: Text('create_quiz'.tr),
              ),
            ],
          ),
        );
      })),
    );
  }
}
