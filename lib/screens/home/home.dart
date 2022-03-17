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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Get.to(() => CreateQuizScreen());
                },
                child: const Text('Create quiz and challenge other players'),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Find quiz'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
