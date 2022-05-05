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

//User + Answer + Score
class PlayerModel {
  int score = 0;
  List<AnswerModel?>? answers = [];
  UserModel? user;

  PlayerModel({required this.user});

  PlayerModel.fromJson(json) {
    user = UserModel.fromJson(json['user']);
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
    'user': userModelToJson(playerModel?.user),
    'answers': answersJson,
    'score': playerModel?.score,
  };
}
