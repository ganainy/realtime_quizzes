import 'dart:async';

import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:realtime_quizzes/customization/theme.dart';
import 'package:realtime_quizzes/layouts/home/home.dart';
import 'package:realtime_quizzes/models/game_type.dart';
import 'package:realtime_quizzes/models/player.dart';
import 'package:realtime_quizzes/screens/single_player_quiz/single_player_quiz_screen.dart';

import '../../layouts/home/home_controller.dart';
import '../../main_controller.dart';
import '../../models/api.dart';
import '../../models/game.dart';
import '../../shared/shared.dart';

class CreateGameController extends GetxController {
  var gameObs = Rxn<GameModel>();
  StreamSubscription? observeQueueQuestionChangesStreamSubscription;
  var gameTypeObs = GameType.MULTI.obs;

  late MainController mainController;
  late HomeController homeController;

  @override
  void onInit() {
    super.onInit();
    try {
      mainController = Get.find<MainController>();
    } catch (e) {
      mainController = Get.put(MainController());
    }
    homeController = Get.find<HomeController>();
  }

  void createGame() {
    switch (gameTypeObs.value) {
      case GameType.MULTI:
        createOnlineGame();
        break;
      case GameType.SINGLE:
        createOfflineGame();
        break;
    }
  }

  void createOfflineGame() {
    mainController.deleteLoggedUserGame();
    Get.to(() => SinglePlayerQuizScreen());
  }

  void createOnlineGame() {
    mainController.loadingDialog(loadingMessage: 'Creating game...');
    //first load quiz question from api
    mainController.fetchQuiz().then((jsonResponse) {
      ApiModel apiModel = ApiModel.fromJson(jsonResponse.data);

      if (apiModel.responseCode == null || apiModel.responseCode != 0) {
        mainController.errorDialog('error_loading_quiz'.tr);
        mainController.hideCurrentDialog();
      } else {
        //add timestamp to game
        mainController.gameObs.value?.gameSettings?.createdAt =
            DateTime.now().millisecondsSinceEpoch;
        //round the number of questions (ex: 8,9 -> 9,0)
        mainController.gameObs.value?.gameSettings?.numberOfQuestions =
            mainController.gameObs.value?.gameSettings?.numberOfQuestions
                ?.ceil()
                .toDouble();
        var players = [PlayerModel(user: Shared.loggedUser)];
        var game = GameModel(
          gameSettings: mainController.gameObs.value?.gameSettings,
          gameId: Shared.loggedUser?.email,
          players: players,
          questions: apiModel.questions,
          gameStatus: GameStatus.ACTIVE,
        );
        Shared.game = game;

        var gameJson = gameModelToJson(game);

        gameCollection.doc(game.gameId).set(gameJson).then((value) {
          mainController.hideCurrentDialog();
          Get.offAll(() => HomeScreen());
          mainController.showInfoDialog(
              title: 'Hint',
              message:
                  'Game is now available to other player and will start automatically once opponent joins, you can cancel it from friends tab');

          mainController.observeAnotherPlayerJoins();
        }).onError((error, stackTrace) {
          mainController.hideCurrentDialog();
          mainController.errorDialog(error.toString());
          printError(
              info:
                  'scenario 2: create queue entry error :' + error.toString());
        });
      }
    }).onError((error, stackTrace) {
      mainController.hideCurrentDialog();
      printError(info: 'error loading questions from API' + error.toString());
      mainController.errorDialog(error.toString());
    });
  }

  getCategoryColor(String? category) {
    if (category == mainController.gameObs.value?.gameSettings?.category) {
      return darkBg;
    } else {
      return null;
    }
  }

  getModeColor(GameType? gameType) {
    if (gameType == gameTypeObs.value) {
      return darkBg;
    } else {
      return null;
    }
  }
}
