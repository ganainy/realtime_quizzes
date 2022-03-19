import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../create_quiz/create_quiz.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
            ListView.builder(
                itemCount: 5,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.all(8.0),
                    child: Card(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('category: '),
                          Text('num questions: '),
                          Text('difficulty: ')
                        ],
                      ),
                    ),
                  );
                }),
            TextButton(
              onPressed: () {
                Get.to(() => CreateQuizScreen());
              },
              child: Text('create_quiz'.tr),
            ),
            TextButton(
              onPressed: () {},
              child: Text('find_quiz'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
