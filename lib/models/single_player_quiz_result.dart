class SinglePlayerQuizResult {
  int score;
  int numQuestions;

  SinglePlayerQuizResult(
    this.score,
    this.numQuestions,
  );

  Map<String, dynamic> toMap() {
    return {
      'score': score,
      'numQuestions': numQuestions,
    };
  }
}
