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
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(smallPadding),
            child: Obx(() {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${findGameController.userObs.value?.name ?? ''}',
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.headline1,
                        ),
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
              );
            }),
          ),
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
                value: findGameController.numOfQuestionsObs.value,
                max: 20,
                min: 5,
                divisions: 15,
                thumbColor: Color(0xff90e0ef),
                activeColor: Color(0xff90e0ef),
                label: findGameController.numOfQuestionsObs.round().toString(),
                onChanged: (double value) {
                  findGameController.numOfQuestionsObs.value = value;
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
          findGameController.selectedDifficultyObs.value = difficulty;
        },
        child: CircleAvatar(
          radius: 25.0,
          backgroundColor:
              difficulty == findGameController.selectedDifficultyObs.value
                  ? Color(0xff00b4d8)
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
