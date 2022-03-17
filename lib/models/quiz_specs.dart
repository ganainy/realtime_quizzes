import 'package:realtime_quizzes/models/category.dart';

import 'difficulty.dart';

class QuizSpecs {
  int numberOfQuestions;
  Category selectedCategory;
  Difficulty selectedDifficulty;
  //currently app only supports MCQ questions so this param is fixed
  String quizType = 'multiple';

  QuizSpecs(
      this.numberOfQuestions, this.selectedCategory, this.selectedDifficulty);

  Map<String, dynamic> toMap() {
    return {
      'difficulty': selectedDifficulty.api_param,
      'amount': numberOfQuestions,
      'category': selectedCategory.api_param,
      'type': quizType,
    };
  }
  /* QuizSpecs.toMap(QuizSpecs) {}*/
}
