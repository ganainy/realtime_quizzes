class QuestionsModel {
  late int responseCode;
  List<QuestionData> questions = [];

  QuestionsModel.fromJson(json) {
    responseCode = json['response_code'];
    //response code == 0 means success
    if (responseCode == 0) {
      json['results'].forEach((questionJson) {
        questions.add(QuestionData.fromJson(questionJson));
      });
    }
  }
}

class QuestionData {
  late String category;
  late String type;
  late String difficulty;
  late String question;
  late String correctAnswer;
  late List<dynamic> incorrectAnswers;
  List<String> allAnswers = [];

  List<String> get shuffledAnswers {
    if (allAnswers.isEmpty) {
      allAnswers = [...incorrectAnswers, correctAnswer];
      allAnswers.shuffle();
    }
    return allAnswers;
  }

  QuestionData.fromJson(questionJson) {
    category = questionJson['category'];
    type = questionJson['type'];
    difficulty = questionJson['difficulty'];
    question = questionJson['question'];
    correctAnswer = questionJson['correct_answer'];
    incorrectAnswers = questionJson['incorrect_answers'];
  }
}
