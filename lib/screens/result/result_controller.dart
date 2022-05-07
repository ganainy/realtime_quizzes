import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:realtime_quizzes/models/game_type.dart';
import 'package:realtime_quizzes/models/player.dart';
import 'package:realtime_quizzes/models/queue_entry.dart';
import 'package:realtime_quizzes/models/result.dart';
import 'package:realtime_quizzes/models/single_player_quiz_result.dart';
import 'package:realtime_quizzes/models/user.dart';
import 'package:realtime_quizzes/shared/shared.dart';

class ResultController extends GetxController {
  final dynamic arguments;

  ResultController(this.arguments);

  var queueEntryModelObs = Rxn<QueueEntryModel?>();

  SinglePlayerQuizResult? singlePlayerResult;

  @override
  void onInit() {
    if (arguments['gameType'] == GameType.MULTI) {
      queueEntryModelObs.value = arguments['queueEntry'];
      updateUsers();
    } else if (arguments['gameType'] == GameType.SINGLE) {
      singlePlayerResult = arguments['result'];
      updateUser();
    }
  }

  //add match to profile of each player
  updateUsers() {
    //get logged player and other player
    PlayerModel? _loggedPlayer;
    PlayerModel? _otherPlayer;

    queueEntryModelObs.value?.players?.forEach((player) {
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
        maxScore: queueEntryModelObs.value?.numberOfQuestions,
        difficulty: queueEntryModelObs.value?.difficulty,
        category: queueEntryModelObs.value?.category,
        otherPlayerEmail: _otherPlayer?.user?.email,
        createdAt: queueEntryModelObs.value?.createdAt,
        isMultiPlayer: true);
    //update user profile

    FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get the document
      DocumentSnapshot snapshot = await transaction
          .get(usersCollection.doc(_loggedPlayer?.user?.email));

      if (!snapshot.exists) {
        throw Exception("Queue entry does not exist!");
      }

      var _userModel = UserModel.fromJson(snapshot.data());
      _userModel.results.add(_resultModel);

      transaction.update(usersCollection.doc(_loggedPlayer?.user?.email),
          userModelToJson(_userModel));
    }).then((value) {
      debugPrint("user result saved successfully $value");
    }).catchError(
        (error) => printError(info: "Failed to upload player result: $error"));
  }

  //add match to profile of loggedUser
  updateUser() {
    //create result model
    ResultModel _resultModel = ResultModel(
      score: singlePlayerResult?.score,
      maxScore: singlePlayerResult?.numQuestions,
      difficulty: singlePlayerResult?.difficulty,
      category: singlePlayerResult?.category,
      createdAt: singlePlayerResult?.createdAt,
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

  //delete game from queueCollection since its over and reset queueEntryModel
  deleteGame() {
    queueCollection
        .doc(Shared.queueEntryModel.queueEntryId)
        .delete()
        .then((value) {
      debugPrint('removed from queueCollection');
      Shared.resetQueueEntry();
    }).onError((error, stackTrace) {
      printError(info: 'error remove from queueCollection');
      Shared.resetQueueEntry();
    });
  }
}
