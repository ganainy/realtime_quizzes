import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../customization/theme.dart';
import '../../shared/components.dart';
import '../../shared/constants.dart';
import 'find_game_controller.dart';

class FindGameScreen extends StatelessWidget {
  FindGameScreen({Key? key}) : super(key: key);

  final FindGameController findGameController = Get.put(FindGameController());

  @override
  Widget build(BuildContext context) {
    findGameController.observe();
    return SafeArea(
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Select game settings',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline3,
          ),
          SizedBox(
            height: 100,
          ),
          Categories(findGameController),
          QuestionNumberSlider(findGameController),
          DifficultyRow(findGameController),
          DefaultButton(
              text: ' Find Game',
              onPressed: () {
                findGameController.searchAvailableQueues(context);
              }),
        ],
      )),
    );
  }

  QuestionNumberSlider(FindGameController findGameController) {
    return Obx(() {
      return Column(
        children: [
          Text(
              'Number of questions: ${findGameController.numOfQuestionsObs.value.toInt()}'),
          Slider(
            value: findGameController.numOfQuestionsObs.value,
            max: 20,
            min: 5,
            divisions: 15,
            label: findGameController.numOfQuestionsObs.round().toString(),
            onChanged: (double value) {
              findGameController.numOfQuestionsObs.value = value;
            },
          ),
        ],
      );
    });
  }

  Categories(FindGameController findGameController) {
    return Column(
      children: [
        Text('Select category'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...Constants.categoryList.map((category) => Obx(() {
                    return Card(
                      child: TextButton(
                        child: Text('${category['category']}'),
                        onPressed: () {
                          findGameController.selectedCategoryObs.value =
                              category['category'];
                        },
                      ),
                      color: findGameController
                          .getCategoryColor(category['category']),
                    );
                  }))
            ],
          ),
        ),
      ],
    );
  }

  DifficultyRow(FindGameController findGameController) {
    return Obx(() {
      return Column(
        children: [
          Text(
              'Difficulty: ${findGameController.selectedDifficultyObs.value ?? ''}'),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            DifficultySelector('easy'.tr, findGameController),
            DifficultySelector('medium'.tr, findGameController),
            DifficultySelector('hard'.tr, findGameController),
          ]),
        ],
      );
    });
  }

  DifficultySelector(String difficulty, FindGameController findGameController) {
    return Container(
      margin: EdgeInsets.all(MyTheme.smallPadding),
      child: InkWell(
        onTap: () {
          findGameController.selectedDifficultyObs.value = difficulty;
        },
        child: CircleAvatar(
          radius: 25.0,
          backgroundColor:
              difficulty == findGameController.selectedDifficultyObs.value
                  ? Colors.grey[400]
                  : Colors.white,
          child: CircleAvatar(
            backgroundColor: difficulty == 'easy'.tr
                ? Colors.green
                : difficulty == 'medium'.tr
                    ? Colors.yellow
                    : Colors.red,
            radius: 20.0,
          ),
        ),
      ),
    );
  }
}
