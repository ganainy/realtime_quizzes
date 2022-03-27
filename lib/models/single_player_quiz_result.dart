class SinglePlayerQuizResult {
  int? score;
  int? numQuestions;
  String? difficulty;
  String? category;
  int? createdAt;

  SinglePlayerQuizResult(
    this.score,
    this.numQuestions,
    this.difficulty,
    this.category,
    this.createdAt,
  );

  Map<String, dynamic> toMap() {
    return {
      'score': score,
      'numQuestions': numQuestions,
      'difficulty': difficulty,
      'category': category,
      'createdAt': createdAt,
    };
  }
}
