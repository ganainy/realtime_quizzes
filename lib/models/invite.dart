import 'package:realtime_quizzes/models/quiz.dart';

class InviteModel {
  late QuizModelFireStore quiz;
  List<dynamic> players = []; //list of user emails participating in quiz

  InviteModel(this.quiz, this.players);

  InviteModel.fromJson(var json) {
    quiz = QuizModelFireStore.fromJson(json['quiz']);
    json['players'].forEach((player) {
      players.add(player);
    });
  }
}
