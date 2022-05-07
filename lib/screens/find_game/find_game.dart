import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../customization/theme.dart';
import '../../main_controller.dart';
import '../../shared/components.dart';
import '../../shared/constants.dart';
import 'find_game_controller.dart';

class FindGameScreen extends StatelessWidget {
  FindGameScreen({Key? key}) : super(key: key);

  final FindGameController findGameController = Get.put(FindGameController());
  final MainController mainController = Get.find<MainController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: Container(
              margin: const EdgeInsets.all(smallPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() {
                          return Text(
                            'Welcome, ${mainController.userObs.value?.name ?? ''}',
                            textAlign: TextAlign.start,
                            style: Theme.of(context).textTheme.headline1,
                          );
                        }),
                        Text(
                          'Select game settings then press find game to start.',
                          textAlign: TextAlign.start,
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Categories(findGameController, context),
                  QuestionNumberSlider(findGameController, context),
                  DifficultyRow(findGameController, context),
                  SizedBox(
                    height: 8,
                  ),
                  Container(
                    margin: EdgeInsets.all(2),
                    child: DefaultButton(
                        text: ' Find Game',
                        onPressed: () {
                          findGameController.searchAvailableQueues(context);
                        }),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  Categories(FindGameController findGameController, BuildContext context) {
    return Card(
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(
              height: smallPadding,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...Constants.categoryList.map((category) => Obx(() {
                        return Card(
                          child: TextButton(
                            child: Text('${category['category']}'),
                            onPressed: () {
                              mainController.selectedCategoryObs.value =
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
        ),
      ),
    );
  }

  QuestionNumberSlider(
      FindGameController findGameController, BuildContext context) {
    return Obx(() {
      return Card(
        color: cardColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Question amount ',
                  style: Theme.of(context).textTheme.subtitle1),
              Slider(
                value: mainController.numOfQuestionsObs.value,
                max: 20,
                min: 2,
                divisions: 9,
                thumbColor: lightCardColor,
                activeColor: lightCardColor,
                label: mainController.numOfQuestionsObs.round().toString(),
                onChanged: (double value) {
                  mainController.numOfQuestionsObs.value = value;
                },
              ),
            ],
          ),
        ),
      );
    });
  }

  DifficultyRow(FindGameController findGameController, BuildContext context) {
    return Obx(() {
      return Card(
        color: cardColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Difficulty', style: Theme.of(context).textTheme.subtitle1),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                DifficultySelector('easy'.tr, findGameController),
                DifficultySelector('medium'.tr, findGameController),
                DifficultySelector('hard'.tr, findGameController),
              ]),
            ],
          ),
        ),
      );
    });
  }

  DifficultySelector(String difficulty, FindGameController findGameController) {
    return Container(
      margin: EdgeInsets.all(smallPadding),
      child: InkWell(
        onTap: () {
          mainController.selectedDifficultyObs.value = difficulty;
        },
        child: CircleAvatar(
          radius: 25.0,
          backgroundColor:
              difficulty == mainController.selectedDifficultyObs.value
                  ? secondaryTextColor
                  : lightCardColor,
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
