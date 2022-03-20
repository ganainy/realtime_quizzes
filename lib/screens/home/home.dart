import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:realtime_quizzes/customization/theme.dart';
import 'package:realtime_quizzes/screens/available_quizzes/available_quizzes.dart';
import 'package:realtime_quizzes/screens/home/home_controller.dart';

import '../create_quiz/create_quiz.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final HomeController homeController = Get.put(HomeController())
    ..getQuizzes()
    ..observeInvites();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quizzes'),
        actions: [
          InkWell(
            onTap: () {
              //show invites
            },
            child: Obx(() {
              return Badge(
                position: BadgePosition.topStart(),
                badgeContent: Text(
                  homeController.invites.value.length.toString(),
                  style: TextStyle(color: Colors.white),
                ),
                child: Icon(
                  Icons.email,
                  size: 30,
                ),
                showBadge: homeController.invites.value.isNotEmpty,
              );
            }),
          )
        ],
      ),
      body: SafeArea(child: Obx(() {
        //todo remove get quizzes button, do it automatic-- why list  no update after create new quiz
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'My Quizezs',
                style: Theme.of(context).textTheme.headline3,
              ),
              Text(
                'Your quizzes are available to other players when you are online,'
                ' wait for another player to join or play alone',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              homeController.quizzes.value.isNotEmpty
                  ? Obx(() {
                      return Padding(
                        padding: const EdgeInsets.all(MyTheme.smallPadding),
                        child: ListView.builder(
                            itemCount: homeController.quizzes.value.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Card(
                                color: Colors.grey[200],
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                      MyTheme.mediumPadding),
                                  child: Wrap(
                                    spacing: 20,
                                    // to apply margin in the main axis of the wrap
                                    runSpacing: 20,
                                    // to apply margin in the cross axis of the wrap
                                    alignment: WrapAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          'category: ${homeController.quizzes.value.elementAt(index).quizSpecs?.selectedCategory?.categoryName}'),
                                      Text(
                                          'num questions: ${homeController.quizzes.value.elementAt(index).quizSpecs?.numberOfQuestions}'),
                                      Text(
                                          'difficulty: ${homeController.quizzes.value.elementAt(index).quizSpecs?.selectedDifficulty?.difficultyType}')
                                    ],
                                  ),
                                ),
                              );
                            }),
                      );
                    })
                  : Obx(() {
                      return Text(
                          'You have created ${homeController.quizzes.value.length} quizzes');
                    }),
              TextButton(
                onPressed: () {
                  Get.to(() => CreateQuizScreen());
                },
                child: Text('create_quiz'.tr),
              ),
              TextButton(
                onPressed: () {
                  Get.to(() => AvailableQuizzesScreen());
                },
                child: Text('find_quiz'.tr),
              ),
            ],
          ),
        );
      })),
    );
  }
}
