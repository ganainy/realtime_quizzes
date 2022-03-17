import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realtime_quizzes/models/difficulty.dart';
import 'package:realtime_quizzes/screens/create_quiz/create_quiz_controller.dart';
import 'package:realtime_quizzes/shared/components.dart';

import '../../shared/constants.dart';

class CreateQuizScreen extends StatelessWidget {
  CreateQuizScreen({Key? key}) : super(key: key);

  final CreateQuizController createQuizController =
      Get.put(CreateQuizController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: CategoriesListView(createQuizController)),
              QuestionNumberSlider(createQuizController),
              DifficultyRow(createQuizController),
              GameTypeWidget(createQuizController),
            ],
          ),
        ),
      ),
    );
  }

  QuestionNumberSlider(CreateQuizController createQuizController) {
    return Obx(() {
      return Slider(
        value: createQuizController.numOfQuestions.value,
        max: 20,
        divisions: 10,
        label: createQuizController.numOfQuestions.round().toString(),
        onChanged: (double value) {
          createQuizController.numOfQuestions.value = value;
        },
      );
    });
  }

  CategoriesListView(CreateQuizController createQuizController) {
    return ListView.builder(
      itemCount: Constants.categoryListTesting.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          child: TextButton(
            child: Text(Constants.categoryListTesting[index].categoryName),
            onPressed: () {
              createQuizController.selectedCategory.value =
                  Constants.categoryListTesting[index];
            },
          ),
        );
      },
    );
  }

  DifficultyRow(CreateQuizController createQuizController) {
    Difficulty easy = Difficulty('easy'.tr, 'easy');
    Difficulty medium = Difficulty('medium'.tr, 'medium');
    Difficulty hard = Difficulty('hard'.tr, 'hard');

    return Obx(() {
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        DifficultySelector(easy, createQuizController),
        DifficultySelector(medium, createQuizController),
        DifficultySelector(hard, createQuizController),
      ]);
    });
  }

  GameTypeWidget(CreateQuizController createQuizController) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      MaterialButton(
        onPressed: () {
          createQuizController.goToQuizScreen(GameType.SINGLE);
        },
        child: Text('Single'),
      ),
      MaterialButton(
        onPressed: () {
          createQuizController.goToQuizScreen(GameType.VS_FRIEND);
        },
        child: Text('Vs friend'),
      ),
      MaterialButton(
        onPressed: () {
          createQuizController.goToQuizScreen(GameType.VS_RANDOM);
        },
        child: Text('vs random'),
      ),
      MaterialButton(
        onPressed: () {
          createQuizController.goToQuizScreen(GameType.VS_RANDOMS);
        },
        child: Text('vs randoms'),
      ),
    ]);
  }
}
