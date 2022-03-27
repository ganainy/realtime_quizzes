//used to show match history of each user

class ResultModel {
  String? type; //win-lose-draw
  int? score;
  int? maxScore;
  String? difficulty;
  String? category;
  String? otherPlayerEmail;
  int? createdAt;
  bool? isMultiPlayer;

  ResultModel(
      {this.type,
      required this.score,
      required this.maxScore,
      required this.difficulty,
      required this.category,
      required this.isMultiPlayer,
      this.otherPlayerEmail,
      this.createdAt});

  ResultModel.fromJson(var json) {
    type = json['type'];
    score = json['score'];
    maxScore = json['maxScore'];
    difficulty = json['difficulty'];
    category = json['category'];
    isMultiPlayer = json['isMultiPlayer'];
    otherPlayerEmail = json['otherPlayerEmail'];
    createdAt = json['createdAt'];
  }
}

resultModelToJson(ResultModel resultModel) {
  return {
    'type': resultModel.type,
    'score': resultModel.score,
    'maxScore': resultModel.maxScore,
    'difficulty': resultModel.difficulty,
    'category': resultModel.category,
    'isMultiPlayer': resultModel.isMultiPlayer,
    'otherPlayerEmail': resultModel.otherPlayerEmail,
    'createdAt': resultModel.createdAt,
  };
}
