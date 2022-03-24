import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../layouts/home/home.dart';
import '../../models/single_player_quiz_result.dart';
import '../../shared/components.dart';

class SinglePlayerQuizResultScreen extends StatelessWidget {
  SinglePlayerQuizResultScreen({Key? key}) : super(key: key);

  SinglePlayerQuizResult result = Get.arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('score:' +
                  result.score.toString() +
                  '/' +
                  result.numQuestions.toString()),
              DefaultButton(
                  text: 'back home',
                  onPressed: () {
                    Get.offAll(() => HomeScreen());
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
