class GameSettings {
  double? numberOfQuestions;
  String? difficulty;
  String? category;
  int? createdAt;

  GameSettings({
    this.numberOfQuestions,
    this.difficulty,
    this.category,
    this.createdAt,
  });

  GameSettings.fromJson(var json) {
    difficulty = json['difficulty'];
    category = json['category'];
    createdAt = json['createdAt'];
    numberOfQuestions = (json['numberOfQuestions']).toDouble();
  }
}

quizSettingsToJson(GameSettings? quizSettings) {
  return {
    'numberOfQuestions': quizSettings?.numberOfQuestions,
    'difficulty': quizSettings?.difficulty,
    'category': quizSettings?.category,
    'createdAt': quizSettings?.createdAt,
  };
}
