class QuizSpecs {
  int? numberOfQuestions;
  String? category;
  String? difficulty;
  //currently app only supports MCQ questions so this param is fixed
  String quizType = 'multiple';

  QuizSpecs(this.numberOfQuestions, this.category, this.difficulty);

  QuizSpecs.fromJson(json) {
    numberOfQuestions = json['numberOfQuestions'];
    category = json['category'];
    difficulty = json['difficulty'];
  }

  Map<String, dynamic> toJson() {
    return {
      'difficulty': difficulty,
      'amount': numberOfQuestions,
      'category': category,
      'type': quizType,
    };
  }
  /* QuizSpecs.toMap(QuizSpecs) {}*/
}
