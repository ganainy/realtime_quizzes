import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../customization/theme.dart';
import '../../models/difficulty.dart';
import '../../shared/components.dart';
import '../../shared/constants.dart';
import '../../shared/shared.dart';
import 'find_game_controller.dart';

class FindGameScreen extends StatelessWidget {
   FindGameScreen({Key? key}) : super(key: key);

  final FindGameController findGameController = Get.put(FindGameController());


  @override
  Widget build(BuildContext context) {
    return  SafeArea(
      child: Center(
        child: Obx(() {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              findGameController.downloadState.value ==
                  DownloadState.LOADING
                  ? const LinearProgressIndicator()
                  : const SizedBox(),
              Text('Select game settings'),
              Expanded(child: CategoriesListView(findGameController)),
              QuestionNumberSlider(findGameController),
              DifficultyRow(findGameController),
              DefaultButton(text:' Find Game', onPressed: (){  findGameController.enterQueue(context);})
             ,

            ],
          );
        }),
      ),
    );
  }


  QuestionNumberSlider(FindGameController findGameController) {
    return Obx(() {
      return Column(

        children: [
          Text('Number of questions:'),
          Slider(
            value: findGameController.numOfQuestions.value,
            max: 20,
            divisions: 3,
            min: 5,
            label: findGameController.numOfQuestions.round().toString(),
            onChanged: (double value) {
              findGameController.numOfQuestions.value = value;
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
            child: Text('${Constants.categoryListTesting[index].categoryName}'),
            onPressed: () {
              findGameController.selectedCategory.value =
              Constants.categoryListTesting[index];
            },
          ),
        );
      },
    );
  }

  DifficultyRow(FindGameController findGameController) {
    Difficulty easy = Difficulty('easy'.tr, 'easy');
    Difficulty medium = Difficulty('medium'.tr, 'medium');
    Difficulty hard = Difficulty('hard'.tr, 'hard');

    return Obx(() {
      return Column(
        children: [

          Text('Difficulty:'),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            DifficultySelector(easy, findGameController),
            DifficultySelector(medium, findGameController),
            DifficultySelector(hard, findGameController),
          ]),
        ],
      );
    });
  }

   DifficultySelector(
       Difficulty difficulty, FindGameController findGameController) {
     return Container(
       margin:  EdgeInsets.all(MyTheme.smallPadding),
       child: InkWell(
         onTap: () {
           findGameController.selectedDifficulty.value = difficulty;
         },
         child: CircleAvatar(
           radius: 25.0,
           backgroundColor:
           difficulty == findGameController.selectedDifficulty.value
               ? Colors.grey[400]
           //todo handle unselected color in dark mode
               : Colors.white,
           child: CircleAvatar(
             backgroundColor: difficulty.difficultyType == 'easy'.tr
                 ? Colors.green
                 : difficulty.difficultyType == 'medium'.tr
                 ? Colors.yellow
                 : Colors.red,
             radius: 20.0,
           ),
         ),
       ),
     );
   }




}
