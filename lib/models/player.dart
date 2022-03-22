import 'package:realtime_quizzes/models/question.dart';

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

class PlayerModel {
  bool? isReady; //this flag will be true if player accept invite
  String? playerEmail;

  PlayerModel({required this.playerEmail, this.isReady = false});

  PlayerModel.fromJson(json) {
    isReady = json['isReady'];
    playerEmail = json['playerEmail'];
  }
}
