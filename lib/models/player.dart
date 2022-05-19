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

//User + Answer + Score
class PlayerModel {
  int score = 0;
  var answers = [];
  UserModel? user;

  PlayerModel({required this.user});

  PlayerModel.fromJson(json) {
    user = UserModel.fromJson(json['user']);
    answers = json['answers'];
    score = json['score'];
  }
}

playerModelToJson(PlayerModel? playerModel) {
  return {
    'user': userModelToJson(playerModel?.user),
    'answers': playerModel?.answers,
    'score': playerModel?.score,
  };
}
