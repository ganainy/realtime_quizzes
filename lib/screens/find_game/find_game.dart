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
        children: [
          Text('Select game settings'),
          Expanded(child: CategoriesListView(findGameController)),
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
          Text('Number of questions:'),
          Slider(
            value: findGameController.numOfQuestionsObs.value,
            max: 20,
            min: 5,
            label: findGameController.numOfQuestionsObs.round().toString(),
            onChanged: (double value) {
              findGameController.numOfQuestionsObs.value = value;
            },
          ),
        ],
      );
    });
  }

  CategoriesListView(FindGameController findGameController) {
    return ListView.builder(
      itemCount: Constants.categoryListTesting.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          child: TextButton(
            child: Text('${Constants.categoryListTesting[index]['category']}'),
            onPressed: () {
              findGameController.selectedCategoryObs.value =
                  Constants.categoryListTesting[index]['category'];
            },
          ),
        );
      },
    );
  }

  DifficultyRow(FindGameController findGameController) {
    return Obx(() {
      return Column(
        children: [
          Text('Difficulty:'),
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
                  //todo handle unselected color in dark mode
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
