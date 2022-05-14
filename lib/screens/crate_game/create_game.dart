import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../../customization/theme.dart';
import '../../main_controller.dart';
import '../../models/game_type.dart';
import '../../shared/components.dart';
import '../../shared/constants.dart';
import 'create_game_controller.dart';

class CreateGameScreen extends StatelessWidget {
  CreateGameScreen({Key? key}) : super(key: key);

  final CreateGameController createGameController =
      Get.put(CreateGameController());
  final MainController mainController = Get.find<MainController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
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
                          Text(
                            'Game settings',
                            textAlign: TextAlign.start,
                            style: Theme.of(context).textTheme.headline1,
                          ),
                          const Text(
                            'Create game and wait for opponent to join',
                            textAlign: TextAlign.start,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    CategoriesView(context),
                    QuestionNumberView(context),
                    DifficultyRowView(context),
                    const SizedBox(
                      height: 8,
                    ),
                    GameModeView(context),
                    const SizedBox(
                      height: 8,
                    ),
                    Container(
                      child: DefaultButton(
                          text: ' Create game',
                          onPressed: () {
                            createGameController.createGame();
                          }),
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }

  CategoriesView(BuildContext context) {
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
            const SizedBox(
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
                              mainController.gameObs.value?.gameSettings
                                  ?.category = category['category'];
                              mainController.forceUpdateUi();
                            },
                          ),
                          color: createGameController
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

  QuestionNumberView(BuildContext context) {
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
              const SizedBox(
                height: 50,
              ),
              SfSliderTheme(
                data: SfSliderThemeData(
                  thumbRadius: 10,
                  inactiveTrackColor: lighterCardColor,
                  activeTrackColor: lightCardColor,
                  tooltipBackgroundColor: lightCardColor,
                ),
                child: Center(
                  child: SfSlider(
                    min: 2,
                    max: 20,
                    interval: 1,
                    shouldAlwaysShowTooltip: true,
                    tooltipShape: const SfPaddleTooltipShape(),
                    enableTooltip: true,
                    value: mainController
                        .gameObs.value?.gameSettings?.numberOfQuestions
                        ?.round(),
                    onChanged: (dynamic newValue) {
                      mainController.gameObs.value?.gameSettings
                          ?.numberOfQuestions = newValue;
                      mainController.forceUpdateUi();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  DifficultyRowView(BuildContext context) {
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
                DifficultySelector('easy'.tr),
                DifficultySelector('medium'.tr),
                DifficultySelector('hard'.tr),
              ]),
            ],
          ),
        ),
      );
    });
  }

  DifficultySelector(String difficulty) {
    return Container(
      margin: const EdgeInsets.all(smallPadding),
      child: InkWell(
        onTap: () {
          mainController.gameObs.value?.gameSettings?.difficulty = difficulty;
          mainController.forceUpdateUi();
        },
        child: CircleAvatar(
          radius: 25.0,
          backgroundColor: difficulty ==
                  mainController.gameObs.value?.gameSettings?.difficulty
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

  GameModeView(BuildContext context) {
    return Card(
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Game mode',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            const SizedBox(
              height: smallPadding,
            ),
            Row(
              children: [
                ...[GameType.MULTI, GameType.SINGLE].map((mode) => Obx(() {
                      var text;
                      switch (mode) {
                        case GameType.SINGLE:
                          text = 'Single player';
                          break;
                        case GameType.MULTI:
                          text = 'Multi player';
                          break;
                      }
                      return Expanded(
                        child: Card(
                          child: TextButton(
                            child: Text('${text}'),
                            onPressed: () {
                              createGameController.gameTypeObs.value = mode;
                            },
                          ),
                          color: createGameController.getModeColor(mode),
                        ),
                      );
                    }))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
