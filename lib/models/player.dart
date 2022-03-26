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
  late bool isReady; //this flag will be true if player ready to begin quiz
  String? playerEmail;
  String? playerName;
  int score = 0;
  List<dynamic> answers = [];

  PlayerModel({required this.playerEmail, this.isReady = false});

  PlayerModel.fromJson(json) {
    isReady = json['isReady'] ?? false;
    playerEmail = json['playerEmail'];
    playerName = json['playerName'];
    answers = json['answers'];
    score = json['score'];
  }
}

playerModelToJson(PlayerModel? playerModel) {
  return {
    'isReady': playerModel?.isReady,
    'playerEmail': playerModel?.playerEmail,
    'playerName': playerModel?.playerName,
    'answers': playerModel?.answers,
    'score': playerModel?.score,
  };
}
