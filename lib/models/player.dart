/*class InviteModel {
  late QuizModelFireStore quiz;
  List<dynamic> players = []; //list of user emails participating in quiz

  InviteModel(this.quiz, this.players);

  InviteModel.fromJson(var json) {
    quiz = QuizModelFireStore.fromJson(json['quiz']);
    json['players'].forEach((playerJson) {
      players.add(PlayerModel.fromJson(playerJson));
    });
  }
}*/

import 'package:realtime_quizzes/models/user.dart';

import 'answer.dart';

class PlayerModel {
  late bool isReady; //this flag will be true if player ready to begin quiz
  int score = 0;
  List<AnswerModel?>? answers = [];
  UserModel? player;
  String? playerEmail;

  PlayerModel({required this.playerEmail, this.isReady = false});

  PlayerModel.fromJson(json) {
    isReady = json['isReady'] ?? false;
    playerEmail = json['playerEmail'];
    player = UserModel.fromJson(json['player']);
    json['answers'].forEach((answerJson) {
      answers?.add(AnswerModel.fromJson(answerJson));
    });
    score = json['score'];
  }
}

playerModelToJson(PlayerModel? playerModel) {
  var answersJson = [];
  playerModel?.answers?.forEach((answer) {
    answersJson.add(answerModelToJson(answer));
  });

  return {
    'isReady': playerModel?.isReady,
    'playerEmail': playerModel?.playerEmail,
    'player': userModelToJson(playerModel?.player),
    'answers': answersJson,
    'score': playerModel?.score,
  };
}
