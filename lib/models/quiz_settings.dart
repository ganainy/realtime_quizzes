class QuizSettings {
  int? score;
  double? numberOfQuestions;
  String? difficulty;
  String? category;
  int? createdAt;

  QuizSettings({
    this.score,
    this.numberOfQuestions,
    this.difficulty,
    this.category,
    this.createdAt,
  });

  QuizSettings.fromJson(var json) {
    difficulty = json['difficulty'];
    category = json['category'];
    createdAt = json['createdAt'];
    numberOfQuestions = (json['numberOfQuestions']);
    score = (json['score']);
  }
}

quizSettingsToJson(QuizSettings? quizSettings) {
  return {
    'score': quizSettings?.score,
    'numQuestions': quizSettings?.numberOfQuestions,
    'difficulty': quizSettings?.difficulty,
    'category': quizSettings?.category,
    'createdAt': quizSettings?.createdAt,
  };
}
