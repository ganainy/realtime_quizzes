//used to show match history of each user

class ResultModel {
  String? type; //win-lose-draw
  int? score;
  int? maxScore;
  String? difficulty;
  String? category;
  String? otherPlayerEmail;
  int? createdAt;

  ResultModel(
      {required this.type,
      required this.score,
      required this.maxScore,
      required this.difficulty,
      required this.category,
      required this.otherPlayerEmail,
      this.createdAt});

  ResultModel.fromJson(var json) {
    type = json['type'];
    score = json['score'];
    maxScore = json['maxScore'];
    difficulty = json['difficulty'];
    category = json['category'];
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
    'otherPlayerEmail': resultModel.otherPlayerEmail,
    'createdAt': resultModel.createdAt,
  };
}
