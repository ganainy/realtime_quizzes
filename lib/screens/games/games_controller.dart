import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:realtime_quizzes/main_controller.dart';
import 'package:realtime_quizzes/models/game.dart';

import '../../models/download_state.dart';
import '../../shared/shared.dart';

class GamesController extends GetxController {
  var downloadStateObs = DownloadState.INITIAL.obs;
  var availableGamesObs = [].obs; // list of gameModel

  late MainController mainController;
  @override
  void onInit() {
    mainController = Get.find<MainController>();
    loadAvailableGames();
  }

  //this method will be triggered if this player is matched with another player
  void loadAvailableGames() {
    downloadStateObs.value = DownloadState.LOADING;
    gameCollection.snapshots().listen((event) {
      availableGamesObs.value.clear();
      availableGamesObs.refresh();

      if (event.docs.isEmpty) {
        downloadStateObs.value = DownloadState.EMPTY;
        return;
      }
      downloadStateObs.value = DownloadState.SUCCESS;
      event.docs.forEach((gameJson) {
        var game = GameModel.fromJson(gameJson.data());
        if (game.gameStatus == GameStatus.ACTIVE) {
          availableGamesObs.value.add(game);
          availableGamesObs.refresh();
        }
      });
    }).onError((error, stackTrace) {
      mainController.errorDialog('Error loading games: ' + error.toString());
      printError(
          info: 'Scenario 1: searchAvailableQueues error :' + error.toString());
    });
  }
}
