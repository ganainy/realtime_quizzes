import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:realtime_quizzes/main_controller.dart';
import 'package:realtime_quizzes/models/game.dart';

import '../../models/download_state.dart';
import '../../shared/shared.dart';

class GamesController extends GetxController {
  var downloadStateObs = DownloadState.INITIAL.obs;
  var availableGamesObs = [].obs; // list of gameModel by strangers
  var friendsGamesObs = [].obs; // list of gameModel by friends

  late MainController mainController;
  @override
  void onInit() {
    mainController = Get.find<MainController>();
    loadAvailableGames();
  }

  //this method will be triggered if this player is matched with another player
  void loadAvailableGames() {
    debugPrint("loadAvailableGames");

    downloadStateObs.value = DownloadState.LOADING;
    gameCollection.snapshots().listen((event) {
      if (event.docs.isEmpty) {
        downloadStateObs.value = DownloadState.EMPTY;
        return;
      }
      downloadStateObs.value = DownloadState.SUCCESS;

      var tempAvailableGames = [];

      event.docs.forEach((gameJson) {
        var game = GameModel.fromJson(gameJson.data());

        // dont show the game that is created by the logged user
        if (game.gameId != Shared.loggedUser?.email) {
          tempAvailableGames.add(game);

          if (game.gameStatus == GameStatus.ACTIVE && !isShowedGame(game)) {
            //this means game was added
            availableGamesObs.value.add(game);
            availableGamesObs.refresh();
          }
        }
      });

      if (tempAvailableGames.length < availableGamesObs.value.length) {
        //this means a game was removed
        availableGamesObs.value = tempAvailableGames;
        availableGamesObs.refresh();
      }

      if (Shared.loggedUser!.connections.isEmpty) {
        //this user has no friends, so no friends games
        return;
      }

      //set friends games
      friendsGamesObs.value.clear();
      friendsGamesObs.refresh();
      availableGamesObs.value.forEach((availableGame) {
        if (Shared.loggedUser!.connections.map((connection) {
          return connection?.email;
        }).contains(availableGame.gameId)) {
          availableGamesObs.value.remove(availableGame);
          availableGamesObs.refresh();
          friendsGamesObs.value.add(availableGame);
          friendsGamesObs.refresh();
        }

        if (availableGamesObs.value.isEmpty && friendsGamesObs.value.isEmpty) {
          //there is only one game and its created by logged user so dont show
          downloadStateObs.value = DownloadState.EMPTY;
        }
      });
    }).onError((error, stackTrace) {
      mainController.errorDialog('Error loading games: ' + error.toString());
      printError(
          info: 'Scenario 1: searchAvailableQueues error :' + error.toString());
    });
  }

  //checks if game is already downloaded
  bool isShowedGame(GameModel newGame) {
    bool isShowed = false;
    availableGamesObs.value.forEach((game) {
      if (newGame.gameId == game.gameId) {
        isShowed = true;
      }
    });
    return isShowed;
  }
}
