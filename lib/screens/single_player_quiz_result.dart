import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../models/single_player_quiz_result.dart';

class SinglePlayerQuizResultScreen extends StatelessWidget {
  SinglePlayerQuizResultScreen({Key? key}) : super(key: key);

  SinglePlayerQuizResult result = Get.arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Text('score:' +
              result.score.toString() +
              '/' +
              result.numQuestions.toString()),
        ),
      ),
    );
  }
}
