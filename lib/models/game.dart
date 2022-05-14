import 'package:realtime_quizzes/models/question.dart';
import 'package:realtime_quizzes/models/quiz_settings.dart';

import 'player.dart';

//state of the invite that was sent to a friend
enum GameStatus {
  INVITE_ACCEPTED, //someone accepted invite -> game should start
  ACTIVE, //game is active -> anyone can join
  INACTIVE, //this means game is already started or sender canceled
  // invite or creator is offline -> no other players can join
  ABANDONED, // this means notify user that opponent has left the game
}

class GameModel {
  GameStatus? gameStatus;

  GameSettings? gameSettings = GameSettings(
      numberOfQuestions: 10.0, difficulty: "Random", category: "Random");
  String?
      gameId; //this will be also the email of the player to prevent multiple entry to queue by same user

  List<PlayerModel?>? players = [];
  List<QuestionModel?>? questions = [];

  GameModel(
      {this.gameId,
      this.players,
      this.questions,
      this.gameSettings,
      this.gameStatus});

  GameModel.fromJson(var json) {
    gameId = (json['gameId']);
    gameSettings = GameSettings.fromJson(json['gameSettings']);

    json['players']?.forEach((playerJson) {
      players?.add(PlayerModel.fromJson(playerJson));
    });

    json['questions']?.forEach((questionJson) {
      questions?.add(QuestionModel.fromJson(questionJson));
    });

    switch (json['gameStatus']) {
      case "INVITE_ACCEPTED":
        gameStatus = GameStatus.INVITE_ACCEPTED;
        break;
      case "ACTIVE":
        gameStatus = GameStatus.ACTIVE;
        break;
      case "INACTIVE":
        gameStatus = GameStatus.INACTIVE;
        break;
      case "ABANDONED":
        gameStatus = GameStatus.ABANDONED;
        break;
      default:
        break;
    }
  }
}

gameModelToJson(GameModel? gameModel) {
  var playersList = [];
  var questionsList = [];
  gameModel?.players?.forEach((player) {
    playersList.add(playerModelToJson(player));
  });

  gameModel?.questions?.forEach((question) {
    questionsList.add(questionModelToJson(question));
  });

  var gameStatus;

  switch (gameModel?.gameStatus) {
    case GameStatus.INVITE_ACCEPTED:
      gameStatus = "INVITE_ACCEPTED";
      break;
    case GameStatus.INACTIVE:
      gameStatus = "INACTIVE";
      break;
    case GameStatus.ACTIVE:
      gameStatus = "ACTIVE";
      break;
    case GameStatus.ABANDONED:
      gameStatus = "ABANDONED";
      break;
    default:
      break;
  }

  return {
    'gameId': (gameModel?.gameId),
    'gameSettings': quizSettingsToJson(gameModel?.gameSettings),
    'players': playersList,
    'questions': questionsList,
    'gameStatus': gameStatus,
  };
}
