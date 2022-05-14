import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:realtime_quizzes/models/game.dart';
import 'package:realtime_quizzes/models/game_type.dart';
import 'package:realtime_quizzes/models/player.dart';
import 'package:realtime_quizzes/models/quiz_settings.dart';
import 'package:realtime_quizzes/models/result.dart';
import 'package:realtime_quizzes/models/user.dart';
import 'package:realtime_quizzes/shared/shared.dart';

import '../../main_controller.dart';

class ResultController extends GetxController {
  final dynamic arguments;

  ResultController(this.arguments);

  var gameObs = Rxn<GameModel?>();
  late MainController mainController;

  @override
  void onInit() {
    mainController = Get.find<MainController>();

    if (arguments['gameType'] == GameType.MULTI) {
      gameObs.value = arguments['queueEntry'];
      updateUsers();
    } else if (arguments['gameType'] == GameType.SINGLE) {
      var gameSettings = arguments['gameSettings'];
      var finalScore = arguments['finalScore'];
      updateUser(
        gameSettings: gameSettings,
        finalScore: finalScore,
      );
    }
  }

  //add match to profile of each player
  updateUsers() {
    //get logged player and other player
    PlayerModel? _loggedPlayer;
    PlayerModel? _otherPlayer;

    gameObs.value?.players?.forEach((player) {
      if (player?.user?.email == Shared.loggedUser?.email) {
        _loggedPlayer = player;
      } else {
        _otherPlayer = player;
      }
    });

    //calculate type of game
    var _type;
    if (_loggedPlayer!.score > _otherPlayer!.score) {
      _type = 'win';
    } else if (_loggedPlayer!.score < _otherPlayer!.score) {
      _type = 'lose';
    } else {
      _type = 'draw';
    }

    //create result model
    ResultModel _resultModel = ResultModel(
        type: _type,
        score: _loggedPlayer?.score,
        maxScore: gameObs.value?.gameSettings?.numberOfQuestions?.toInt(),
        difficulty: gameObs.value?.gameSettings?.difficulty,
        category: gameObs.value?.gameSettings?.category,
        otherPlayerEmail: _otherPlayer?.user?.email,
        createdAt: gameObs.value?.gameSettings?.createdAt,
        isMultiPlayer: true);
    //add result to user document
    Shared.loggedUser?.results.add(_resultModel);

    usersCollection
        .doc(Shared.loggedUser?.email)
        .update(userModelToJson(Shared.loggedUser));

    //if this is the creator of the game, delete the game
    if (gameObs.value?.gameId == Shared.loggedUser?.email) {
      mainController.deleteLoggedUserGame();
    }
  }

  //add offline match to profile of loggedUser
  updateUser({required GameSettings gameSettings, required int finalScore}) {
    //create result model
    ResultModel _resultModel = ResultModel(
      score: finalScore,
      maxScore: gameSettings.numberOfQuestions?.toInt(),
      difficulty: gameSettings.difficulty,
      category: gameSettings.category,
      createdAt: gameSettings.createdAt,
      isMultiPlayer: false,
    );

    //update user profile
    FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get the document
      DocumentSnapshot snapshot =
          await transaction.get(usersCollection.doc(Shared.loggedUser?.email));

      if (!snapshot.exists) {
        throw Exception("Queue entry does not exist!");
      }

      var _userModel = UserModel.fromJson(snapshot.data());
      _userModel.results.add(_resultModel);

      transaction.update(usersCollection.doc(Shared.loggedUser?.email),
          userModelToJson(_userModel));
    }).then((value) {
      debugPrint("user result saved successfully $value");
    }).catchError(
        (error) => printError(info: "Failed to upload player result: $error"));
  }
}
